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
version.BuildInfo{Version:"v3.7.0", GitCommit:"eeac83883cb4014fe60267ec6373570374ce770b", GitTreeState:"clean", GoVersion:"go1.17"}
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

### Create a Kubernetes secret with the pair
<pre>
kubectl create secret tls kong-cluster-cert \-\-cert=./cluster.crt \-\-key=./cluster.key -n kong
</pre>

### Create a secret with your license file
<pre>
kubectl create secret generic kong-enterprise-license -n kong --from-file=./license
</pre>

### Create a <b>"admin_gui.session_conf"</b> file for Kong Manager session conf.
<pre>
{"cookie_name":"admin_session","cookie_samesite":"off","secret":"kong","cookie_secure":false,"storage":"kong"}
</pre>

### Create a <b>"portal_session_conf"</b> file for for Kong DevPortal session conf
<pre>
{"cookie_name":"portal_session","cookie_samesite":"off","secret":"kong","cookie_secure":false,"storage":"kong"}
</pre>


Create the session conf with kubectl
<pre>
kubectl create secret generic kong-session-config -n kong --from-file=admin_gui_session_conf --from-file=portal_session_conf
</pre>


### Deploy the Control Plane
helm install kong kong/kong -n kong \
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
--set image.repository=kong/kong-gateway \
--set image.tag=2.5.1.0-alpine \
--set admin.enabled=true \
--set admin.http.enabled=true \
--set admin.type=LoadBalancer \
--set proxy.enabled=true \
--set proxy.type=ClusterIP \
--set ingressController.enabled=true \
--set ingressController.installCRDs=false \
--set ingressController.image.repository=kong/kubernetes-ingress-controller \
--set ingressController.image.tag=1.3.2-alpine \
--set postgresql.enabled=true \
--set postgresql.postgresqlUsername=kong \
--set postgresql.postgresqlDatabase=kong \
--set postgresql.postgresqlPassword=kong \
--set enterprise.enabled=true \
--set enterprise.license_secret=kong-enterprise-license \
--set enterprise.rbac.enabled=false \
--set enterprise.smtp.enabled=false \
--set enterprise.portal.enabled=true \
--set manager.enabled=true \
--set manager.type=LoadBalancer \
--set portal.enabled=true \
--set portal.http.enabled=true \
--set env.portal_gui_protocol=http \
--set portal.type=LoadBalancer \
--set portalapi.enabled=true \
--set portalapi.http.enabled=true \
--set portalapi.type=LoadBalancer \
--set secretVolumes[0]=kong-cluster-cert


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

Create a secret with your license file
<pre>
kubectl create secret generic kong-enterprise-license -n kong-dp --from-file=./license
</pre>



Install the Data Plane

<pre>
helm install kong-dp kong/kong -n kong-dp \
--set ingressController.enabled=false \
--set image.repository=kong/kong-gateway \
--set image.tag=2.5.1.0-alpine \
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
--set enterprise.license_secret=kong-enterprise-license \
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
kong-dp       kong-dp-kong   1/1     1            1           2m15s
kong          kong-kong      1/1     1            1           20m
kube-system   coredns        2/2     2            2           15h
</pre>

<pre>
$ kubectl get pod --all-namespaces
NAMESPACE     NAME                              READY   STATUS      RESTARTS   AGE
kong-dp       kong-dp-kong-848f4984dc-zshwv     1/1     Running     0          11m
kong          kong-kong-777b5f56bc-76k5v        2/2     Running     0          19m
kong          kong-kong-init-migrations-fwmg7   0/1     Completed   0          29m
kong          kong-postgresql-0                 1/1     Running     0          29m
kube-system   aws-node-kr2c4                    1/1     Running     0          15h
kube-system   coredns-66cb55d4f4-8pwrn          1/1     Running     0          15h
kube-system   coredns-66cb55d4f4-hw4mq          1/1     Running     0          15h
kube-system   kube-proxy-gb8bc                  1/1     Running     0          15h
</pre>

<pre>
$ kubectl get service --all-namespaces
NAMESPACE     NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                         AGE
default       kubernetes                   ClusterIP      10.100.0.1       <none>                                                                    443/TCP                         15h
kong-dp       kong-dp-kong-proxy           LoadBalancer   10.100.56.103    a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com   80:31032/TCP,443:30651/TCP      11m
kong          kong-kong-admin              LoadBalancer   10.100.124.36    a9ed78cc5bb954931aec1b5bf48298f6-2098365612.us-east-1.elb.amazonaws.com   8001:32155/TCP,8444:32134/TCP   29m
kong          kong-kong-cluster            ClusterIP      10.100.105.110   <none>                                                                    8005/TCP                        29m
kong          kong-kong-clustertelemetry   ClusterIP      10.100.192.124   <none>                                                                    8006/TCP                        29m
kong          kong-kong-manager            LoadBalancer   10.100.212.94    abd76df53f5584e8f800a9f9ac73d5fa-21140374.us-east-1.elb.amazonaws.com     8002:30693/TCP,8445:30219/TCP   29m
kong          kong-kong-portal             LoadBalancer   10.100.135.213   a4d6e108295f5458e9cffa00856c1fb2-1667372698.us-east-1.elb.amazonaws.com   8003:30474/TCP,8446:32207/TCP   29m
kong          kong-kong-portalapi          LoadBalancer   10.100.153.195   a0e9f107ba17749e5ac1542792a049f2-1349476423.us-east-1.elb.amazonaws.com   8004:31298/TCP,8447:30469/TCP   29m
kong          kong-kong-proxy              ClusterIP      10.100.205.134   <none>                                                                    80/TCP,443/TCP                  29m
kong          kong-postgresql              ClusterIP      10.100.10.254    <none>                                                                    5432/TCP                        29m
kong          kong-postgresql-headless     ClusterIP      None             <none>                                                                    5432/TCP                        29m
kube-system   kube-dns                     ClusterIP      10.100.0.10      <none>                                                                    53/UDP,53/TCP                   15h
</pre>






## Checking the Kong Konnect Rest Admin API port
Use the Load Balancer created during the deployment
<pre>
$ kubectl get service kong-kong-admin \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n kong
a9ed78cc5bb954931aec1b5bf48298f6-2098365612.us-east-1.elb.amazonaws.com
</pre>

<pre>
$ http a9ed78cc5bb954931aec1b5bf48298f6-2098365612.us-east-1.elb.amazonaws.com:8001 | jq -r .version
2.5.1.0-enterprise-edition"
</pre>


## Checking the Data Plane from the Control Plane

<pre>
$ http a9ed78cc5bb954931aec1b5bf48298f6-2098365612.us-east-1.elb.amazonaws.com:8001/clustering/status
HTTP/1.1 200 OK
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: http://abd76df53f5584e8f800a9f9ac73d5fa-21140374.us-east-1.elb.amazonaws.com:8002
Connection: keep-alive
Content-Length: 177
Content-Type: application/json; charset=utf-8
Date: Thu, 30 Sep 2021 14:59:49 GMT
Deprecation: true
Server: kong/2.5.1.0-enterprise-edition
X-Kong-Admin-Latency: 3
X-Kong-Admin-Request-ID: ZG1HJrWBSgCDc2wz42DkGRwzZEDXF0Ia
vary: Origin

{
    "595ec021-5f64-4a10-ade2-0abdb9ffe444": {
        "config_hash": "b2c946b21b1a3c5bd3bc72ccdfc5cc78",
        "hostname": "kong-dp-kong-848f4984dc-zshwv",
        "ip": "192.168.32.5",
        "last_seen": 1633013975
    }
}
</pre>



## Checking the Data Plane Proxy
Use the Load Balancer created during the deployment

<pre>
$ kubectl get svc -n kong-dp kong-dp-kong-proxy --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com
</pre>

<pre>
$ http a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com
HTTP/1.1 404 Not Found
Connection: keep-alive
Content-Length: 48
Content-Type: application/json; charset=utf-8
Date: Thu, 30 Sep 2021 15:00:35 GMT
Server: kong/2.5.1.0-enterprise-edition
X-Kong-Response-Latency: 0

{
    "message": "no Route matched with those values"
}
</pre>


## Configuring Kong Manager Service
Kong Manager is the Control Plane Admin GUI. It should get the Admin URI configured with the same Load Balancer address:
<pre>
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_ADMIN_API_URI\", \"value\": \"a9ed78cc5bb954931aec1b5bf48298f6-2098365612.us-east-1.elb.amazonaws.com:8001\" }]}]}}}}"
</pre>

<pre>
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_ADMIN_GUI_URL\", \"value\": \"http:\/\/abd76df53f5584e8f800a9f9ac73d5fa-21140374.us-east-1.elb.amazonaws.com:8002\" }]}]}}}}"
</pre>




### Configuring Kong Dev Portal
<pre>
$ kubectl get service kong-kong-portalapi -n kong --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a0e9f107ba17749e5ac1542792a049f2-1349476423.us-east-1.elb.amazonaws.com
</pre>

<pre>
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_PORTAL_API_URL\", \"value\": \"http://a0e9f107ba17749e5ac1542792a049f2-1349476423.us-east-1.elb.amazonaws.com:8004\" }]}]}}}}"
</pre>


<pre>
$ kubectl get service kong-kong-portal -n kong --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a4d6e108295f5458e9cffa00856c1fb2-1667372698.us-east-1.elb.amazonaws.com
</pre>

<pre>
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_PORTAL_GUI_HOST\", \"value\": \"a4d6e108295f5458e9cffa00856c1fb2-1667372698.us-east-1.elb.amazonaws.com:8003\" }]}]}}}}"
</pre>





### Logging to Kong Manager
Login to Kong Manager using the specific ELB:

<pre>
$ kubectl get service kong-kong-manager -n kong --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
abd76df53f5584e8f800a9f9ac73d5fa-21140374.us-east-1.elb.amazonaws.com
</pre>

If you redirect your browser to http://abd76df53f5584e8f800a9f9ac73d5fa-21140374.us-east-1.elb.amazonaws.com:8002 you should see the Kong Manager landing page:

![kong_manager](/images/kong_manager.png)



### Go to Kong Developer Portal
Login to Kong Manager using the specific ELB:

