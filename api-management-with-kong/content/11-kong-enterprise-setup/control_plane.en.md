---
title : "Kong Control Plane"
weight : 112
---

#### Install Helm charts

Add Kong's Helm repository

```bash
helm repo add kong https://charts.konghq.com
helm repo update
```

#### Install the Control Plane

Install the helm chart using the following command. 

```bash
helm install kong kong/kong -n kong \
--set ingressController.enabled=true \
--set ingressController.installCRDs=false \
--set ingressController.image.repository=kong/kubernetes-ingress-controller \
--set ingressController.image.tag=2.8 \
--set image.repository=kong/kong-gateway \
--set image.tag=3.1.1.1-alpine \
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
--set enterprise.license_secret=kong-enterprise-license \
--set manager.enabled=true \
--set manager.type=LoadBalancer \
--set secretVolumes[0]=kong-cluster-cert \
--set postgresql.enabled=true \
--set postgresql.postgresqlUsername=kong \
--set postgresql.postgresqlDatabase=kong \
--set postgresql.postgresqlPassword=kong
```

Control Plane uses port 8005 to publish any new API configuration it has. 

#### Validating the Installation

```bash
kubectl get all -n kong
```

**Expected Output: Completing the Kong control plane installation may take 2-3 minutes to complete.You should see output similar to following, with pods in *Running* State**


```bash
NAME                                  READY   STATUS      RESTARTS   AGE
pod/kong-kong-74557454fc-wlhjs        2/2     Running     0          42s
pod/kong-kong-init-migrations-27dwk   0/1     Completed   0          42s
pod/kong-postgresql-0                 1/1     Running     0          42s

NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)                         AGE
service/kong-kong-admin              LoadBalancer   10.100.91.71     a7be2711e233545bea1f782b8b9a2309-264700326.us-east-1.elb.amazonaws.com   8001:31289/TCP,8444:31214/TCP   42s
service/kong-kong-cluster            ClusterIP      10.100.146.81    <none>                                                                   8005/TCP                        42s
service/kong-kong-clustertelemetry   ClusterIP      10.100.139.225   <none>                                                                   8006/TCP                        42s
service/kong-kong-manager            LoadBalancer   10.100.138.99    aa1f5a3f441674a23b5badcea19fda4a-668602520.us-east-1.elb.amazonaws.com   8002:32533/TCP,8445:30547/TCP   42s
service/kong-kong-portal             NodePort       10.100.34.148    <none>                                                                   8003:30389/TCP,8446:30193/TCP   42s
service/kong-kong-portalapi          NodePort       10.100.158.236   <none>                                                                   8004:31747/TCP,8447:30134/TCP   42s
service/kong-kong-proxy              LoadBalancer   10.100.30.255    a0e22846a474949bba1da31964d3591d-905024952.us-east-1.elb.amazonaws.com   80:32472/TCP,443:30142/TCP      42s
service/kong-postgresql              ClusterIP      10.100.47.150    <none>                                                                   5432/TCP                        42s
service/kong-postgresql-hl           ClusterIP      None             <none>                                                                   5432/TCP                        42s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kong-kong   1/1     1            1           43s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/kong-kong-74557454fc   1         1         1       43s

NAME                               READY   AGE
statefulset.apps/kong-postgresql   1/1     43s

NAME                                  COMPLETIONS   DURATION   AGE
job.batch/kong-kong-init-migrations   1/1           32s        43s
```

#### Checking the Kong Gateway Enterprise Rest Admin API port

Use the Load Balancer created during the deployment


```bash
echo "export CONTROL_PLANE_LB=$(kubectl get service kong-kong-admin \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n kong)" >> ~/.bashrc
bash
```

**NOTE: Dont miss running `bash` at the end of command above, else the value of `CONTROL_PLANE_LB` will not get loaded.**

```bash
echo $CONTROL_PLANE_LB
```

```bash
curl $CONTROL_PLANE_LB:8001 | jq .version
```

**Expected Output**

```
"3.1.1.1"
```
#### Configuring Kong Manager Service

Kong Manager is the Control Plane Admin GUI. It should get the Admin URI configured with the same Load Balancer address:

```bash
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_ADMIN_API_URI\", \"value\": \"$CONTROL_PLANE_LB:8001\" }]}]}}}}"
```

#### Logging to Kong Manager

Login to Kong Manager using the specific load balancer:

```bash
echo "export KONG_MANAGER=$(kubectl get svc -n kong kong-kong-manager --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash
```

```
echo $KONG_MANAGER:8002
```

Copy the output from above in a browser locally and you should see the Kong Manager landing page.

**NOTE: Some VPNs may prevent you from viewing the landing page. If you get a white screen in browser, try disconnecting from your VPN.** 

![kong_manager](/static/images/kong_manager.png)

