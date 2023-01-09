---
title : "Kong Data Plane"
weight : 113
---

#### Create Kubernetes Secret for mTLS

Create the secret for the Data Plane using the same Digital Certicate and Private Key pair:

```bash
kubectl create secret tls kong-cluster-cert --cert=./cluster.crt --key=./cluster.key -n kong-dp
```

#### Install the Data Plane


```bash
helm install kong-dp kong/kong -n kong-dp \
--set ingressController.enabled=false \
--set image.repository=kong/kong-gateway \
--set image.tag=3.1.1.1-alpine \
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
--set secretVolumes[0]=kong-cluster-cert
```

**Note we're using the Control Plane's Kubernetes FQDN to get the Data Plane connected to it.**

#### Checking the Installation

```bash
kubectl get all -n kong-dp
```

**Sample Output**

```bash
NAME                               READY   STATUS    RESTARTS   AGE
pod/kong-dp-kong-b98c776fc-87qtf   1/1     Running   0          28s

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
service/kong-dp-kong-proxy   LoadBalancer   10.100.210.146   ab1f04a70e5fe4b7fac778cfff4840ec-1485985339.us-east-1.elb.amazonaws.com   80:32280/TCP,443:32494/TCP   29s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kong-dp-kong   1/1     1            1           29s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/kong-dp-kong-b98c776fc   1         1         1       29s
```


#### Checking the Data Plane from the Control Plane

```bash
curl $CONTROL_PLANE_LB:8001/clustering/status
```

**Expected Output**

```bash
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 178
Content-Type: application/json; charset=utf-8
Date: Wed, 04 Jan 2023 14:09:41 GMT
Deprecation: true
Server: kong/3.1.1.1-enterprise-edition
X-Kong-Admin-Latency: 12
X-Kong-Admin-Request-ID: tkGfCztN6N7YuhQg9ZC0lm3IVD2yGwaj

{
    "43fccc25-1a05-4dce-bf04-dc8841cf8091": {
        "config_hash": "df22b8971e544f31f20e46209f04b6fe",
        "hostname": "kong-dp-kong-b98c776fc-87qtf",
        "ip": "192.168.56.203",
        "last_seen": 1672841370
    }
}
```



#### Checking the Data Plane Proxy

Use the Load Balancer created during the deployment

```bash
echo "export DATA_PLANE_LB=$(kubectl get svc -n kong-dp kong-dp-kong-proxy --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash
```

```bash
echo $DATA_PLANE_LB
```

```bash
curl $DATA_PLANE_LB
```
**NOTE** This step could take 2-3 minutes to show correctly as Kong Data plane try to connect with Kong Control Plane. You may receive `curl: (6) Could not resolve host:`. If you receive such message in output, wait for 2-3 minutes and retry.

**Expected Output**

```bash
HTTP/1.1 404 Not Found
Connection: keep-alive
Content-Length: 48
Content-Type: application/json; charset=utf-8
Date: Wed, 04 Jan 2023 14:10:36 GMT
Server: kong/3.1.1.1-enterprise-edition
X-Kong-Response-Latency: 0

{
    "message": "no Route matched with those values"
}
```

