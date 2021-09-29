---
title: "Konnect Control Plane and Data Plane Setup"
chapter: true
draft: false
weight: 1
---



# Konnect Control Plane and Data Plane

## Create the Digital Certificate and Private Key pair
In Hybrid mode, a mutual TLS handshake (mTLS) is used for authentication so the actual private key is never transferred on the network, and communication between CP and DP nodes is secure.<br><br>

Before using Hybrid mode, you need a certificate/key pair. Kong Gateway provides two modes for handling certificate/key pairs:<br><br>

* <b>Shared mode</b>: (Default) Use the Kong CLI to generate a certificate/key pair, then distribute copies across nodes. The certificate/key pair is shared by both CP and DP nodes.<br>
* <b>PKI mode</b>: Provide certificates signed by a central certificate authority (CA). Kong validates both sides by checking if they are from the same CA. This eliminates the risks associated with transporting private keys.<br><br>

To have an easier deployment we're going to use the Shared Mode and OpenSSL to issue the pair. The command below creates two files "cluster.key" and "cluster.crt".

<pre>
openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) \
  -keyout ./cluster.key -out ./cluster.crt \
  -days 1095 -subj "/CN=kong_clustering"
</pre>




## Configure Kong Konnect Helm Charts to install the Control Plane and Data Plane
Before installing the Control Plane make sure you have Helm installed locally:
<pre>
$ helm version
version.BuildInfo{Version:"v3.6.0", GitCommit:"7f2df6467771a75f5646b7f12afb408590ed1755", GitTreeState:"dirty", GoVersion:"go1.16.4"}
</pre>

Now add Kong Helm Charts repo:
<pre>
$ helm repo add kong https://charts.kong.com
"kong" has been added to your repositories
</pre>

You should see it:
<pre>
$ helm repo ls
NAME   	URL                               
kong   	https://charts.konghq.com
</pre>

If you want to update it run:
<pre>
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kong" chart repository
Update Complete. ⎈ Happy Helming!⎈ 
</pre>


## Control Plane
Let's get started deploying the Kong Konnect Control Plane. First of all, create a "kong" namespace:
<pre>
kubectl create namespace kong
</pre>

Create a Kubernetes secret with the pair
<pre>
kubectl create secret tls kong-cluster-cert \-\-cert=./cluster.crt \-\-key=./cluster.key -n kong
</pre>


Install the Control Plane

<pre>
helm install kong kong/kong -n kong \
--set ingressController.enabled=true \
--set ingressController.installCRDs=false \
--set ingressController.image.repository=kong/kubernetes-ingress-controller \
--set ingressController.image.tag=1.3.1-alpine \
--set image.repository=kong/kong-gateway \
--set image.tag=2.4.1.1-alpine \
--set env.database=postgres \
--set env.role=control_plane \
--set env.cluster_cert=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_cert_key=/etc/secrets/kong-cluster-cert/tls.key \
--set cluster.enabled=true \
--set cluster.tls.enabled=true \
--set cluster.tls.servicePort=8005 \
--set cluster.tls.containerPort=8005 \
--set clustertelemetry.enabled=true \
--set clustertelemetry.tls.enabled=true \
--set clustertelemetry.tls.servicePort=8006 \
--set clustertelemetry.tls.containerPort=8006 \
--set proxy.enabled=true \
--set admin.enabled=true \
--set admin.http.enabled=true \
--set admin.type=LoadBalancer \
--set enterprise.enabled=true \
--set enterprise.portal.enabled=false \
--set enterprise.rbac.enabled=false \
--set enterprise.smtp.enabled=false \
--set manager.enabled=true \
--set manager.type=LoadBalancer \
--set secretVolumes[0]=kong-cluster-cert \
--set postgresql.enabled=true \
--set postgresql.postgresqlUsername=kong \
--set postgresql.postgresqlDatabase=kong \
--set postgresql.postgresqlPassword=kong
</pre>

Control Plane uses port 8005 to publish any new API configuration it has. On the other hand, Data Plane uses the port 8006 to report back all metrics regarding API Consumption.

## Data Plane
Create another Kubernetes namespace specifically for the Data Plane:
<pre>
kubectl create namespace kong-dp
</pre>

Create the secret for the Data Plane using the same Digital Certicate and Private Key pair:
<pre>
kubectl create secret tls kong-cluster-cert \-\-cert=./cluster.crt \-\-key=./cluster.key -n kong-dp
</pre>

Install the Data Plane

<pre>
helm install kong-dp kong/kong -n kong-dp \
--set ingressController.enabled=false \
--set image.repository=kong/kong-gateway \
--set image.tag=2.4.1.1-alpine \
--set env.database=off \
--set env.role=data_plane \
--set env.cluster_cert=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_cert_key=/etc/secrets/kong-cluster-cert/tls.key \
--set env.lua_ssl_trusted_certificate=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_control_plane=kong-kong-cluster.kong.svc.cluster.local:8005 \
--set env.cluster_telemetry_endpoint=kong-kong-clustertelemetry.kong.svc.cluster.local:8006 \
--set proxy.enabled=true \
--set proxy.type=LoadBalancer \
--set enterprise.enabled=true \
--set enterprise.portal.enabled=false \
--set enterprise.rbac.enabled=false \
--set enterprise.smtp.enabled=false \
--set manager.enabled=false \
--set portal.enabled=false \
--set portalapi.enabled=false \
--set env.status_listen=0.0.0.0:8100 \
--set secretVolumes[0]=kong-cluster-cert
</pre>

Note we're using the Control Plane's Kubernetes FQDN to get the Data Plane connected to it.

## Checking the Installation

<pre>
$ kubectl get deployment --all-namespaces
NAMESPACE     NAME           READY   UP-TO-DATE   AVAILABLE   AGE
default       sample         1/1     1            1           107m
kong-dp       kong-dp-kong   1/1     1            1           30s
kong          kong-kong      1/1     1            1           80s
kube-system   coredns        2/2     2            2           3h40m
</pre>

<pre>
$ kubectl get pod --all-namespaces
NAMESPACE     NAME                              READY   STATUS      RESTARTS   AGE
kong-dp       kong-dp-kong-75478bfcff-sq8f6     1/1     Running     0          37s
kong          kong-kong-5c5cbf7d54-xvszn        2/2     Running     0          101s
kong          kong-kong-init-migrations-plkmh   0/1     Completed   0          101s
kong          kong-postgresql-0                 1/1     Running     0          101s
kube-system   aws-node-kjz2s                    1/1     Running     0          18h
kube-system   coredns-85cc4f6d5-868x9           1/1     Running     0          18h
kube-system   coredns-85cc4f6d5-jjcjq           1/1     Running     0          18h
kube-system   kube-proxy-6gwdp                  1/1     Running     0          18h
</pre>

<pre>
$ kubectl get service --all-namespaces
NAMESPACE     NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP                                                                  PORT(S)                         AGE
default       kubernetes                   ClusterIP      10.100.0.1       <none>                                                                       443/TCP                         18h
kong-dp       kong-dp-kong-proxy           LoadBalancer   10.100.12.30     a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com   80:32336/TCP,443:31316/TCP      102s
kong          kong-kong-admin              LoadBalancer   10.100.2.114     aeaea72cf7352414ba4ec598c8200f4a-1395366732.eu-central-1.elb.amazonaws.com   8001:32210/TCP,8444:32224/TCP   2m46s
kong          kong-kong-cluster            ClusterIP      10.100.85.183    <none>                                                                       8005/TCP                        2m46s
kong          kong-kong-clustertelemetry   ClusterIP      10.100.155.125   <none>                                                                       8006/TCP                        2m46s
kong          kong-kong-manager            LoadBalancer   10.100.151.102   a9be7d6800a0c4f40b9cfac10c0fd65a-1065253554.eu-central-1.elb.amazonaws.com   8002:30167/TCP,8445:31107/TCP   2m46s
kong          kong-kong-portal             NodePort       10.100.22.46     <none>                                                                       8003:30668/TCP,8446:32649/TCP   2m46s
kong          kong-kong-portalapi          NodePort       10.100.175.163   <none>                                                                       8004:32170/TCP,8447:30569/TCP   2m46s
kong          kong-kong-proxy              LoadBalancer   10.100.36.75     a498d1c494e0949969c0db90b597f609-240139526.eu-central-1.elb.amazonaws.com    80:32441/TCP,443:32727/TCP      2m46s
kong          kong-postgresql              ClusterIP      10.100.70.30     <none>                                                                       5432/TCP                        2m46s
kong          kong-postgresql-headless     ClusterIP      None             <none>                                                                       5432/TCP                        2m46s
kube-system   kube-dns                     ClusterIP      10.100.0.10      <none>                                                                       53/UDP,53/TCP                   18h
</pre>



## Checking the Kong Konnect Rest Admin API port
Use the Load Balancer created during the deployment
<pre>
$ kubectl get service kong-kong-admin \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n kong
aeaea72cf7352414ba4ec598c8200f4a-1395366732.eu-central-1.elb.amazonaws.com
</pre>

<pre>
$ http aeaea72cf7352414ba4ec598c8200f4a-1395366732.eu-central-1.elb.amazonaws.com:8001 | jq .version
"2.4.1.1-enterprise-edition"
</pre>


## Checking the Data Plane from the Control Plane

<pre>
$ http aeaea72cf7352414ba4ec598c8200f4a-1395366732.eu-central-1.elb.amazonaws.com:8001/clustering/status
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 179
Content-Type: application/json; charset=utf-8
Date: Thu, 08 Jul 2021 15:45:38 GMT
Deprecation: true
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Admin-Latency: 3
X-Kong-Admin-Request-ID: rfGHCRf37yxTWX1c4J45IDLSrryfjNHb
vary: Origin

{
    "d1cd7bc3-f6da-4d06-aeea-884894ff4bc7": {
        "config_hash": "66f9770e92cc8e860fd7835e5d4c0adf",
        "hostname": "kong-dp-kong-75478bfcff-sq8f6",
        "ip": "192.168.16.247",
        "last_seen": 1625759130
    }
}
</pre>



## Checking the Data Plane Proxy
Use the Load Balancer created during the deployment

<pre>
$ kubectl get svc -n kong-dp kong-dp-kong-proxy --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com
</pre>

<pre>
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com
HTTP/1.1 404 Not Found
Connection: keep-alive
Content-Length: 48
Content-Type: application/json; charset=utf-8
Date: Thu, 08 Jul 2021 15:47:34 GMT
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 0

{
    "message": "no Route matched with those values"
}
</pre>


## Configuring Kong Manager Service
Kong Manager is the Control Plane Admin GUI. It should get the Admin URI configured with the same Load Balancer address:
<pre>
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_ADMIN_API_URI\", \"value\": \"aeaea72cf7352414ba4ec598c8200f4a-1395366732.eu-central-1.elb.amazonaws.com:8001\" }]}]}}}}"
</pre>

### Logging to Kong Manager
Login to Kong Manager using the specific ELB:

<pre>
$ kubectl get svc -n kong kong-kong-manager --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a9be7d6800a0c4f40b9cfac10c0fd65a-1065253554.eu-central-1.elb.amazonaws.com
</pre>

If you redirect your browser to http://a9be7d6800a0c4f40b9cfac10c0fd65a-1065253554.eu-central-1.elb.amazonaws.com:8002 you should see the Kong Manager landing page:


![kong_manager](/images/kong_manager.png)

