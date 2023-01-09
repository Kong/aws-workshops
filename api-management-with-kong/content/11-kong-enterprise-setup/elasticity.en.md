---
title : "Data Plane Elasticity"
weight : 14
---


One of the most important capabilities provided by Kubernetes is to easily scale out a Deployment. With a single command we can create or terminate pod replicas in order to optimaly support a given throughtput. 

This capability is specially interesting for Kubernetes applications like Kong for Kubernetes Ingress Controller.

Here's our deployment before scaling it out:

```bash
kubectl get service -n kong-dp
```

**Sample Output**

```bash
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
kong-dp-kong-proxy   LoadBalancer   10.100.210.146   ab1f04a70e5fe4b7fac778cfff4840ec-1485985339.us-east-1.elb.amazonaws.com   80:32280/TCP,443:32494/TCP   6m59s
```

Notice, at this point in the workshop, there is only one pod taking data plane traffic.


```bash
kubectl get pod -n kong-dp -o wide
```

**Sample Output**

```bash
NAME                           READY   STATUS    RESTARTS   AGE     IP               NODE                             NOMINATED NODE   READINESS GATES
kong-dp-kong-b98c776fc-87qtf   1/1     Running   0          7m51s   192.168.56.203   ip-192-168-35-145.ec2.internal   <none>           <none>
```

#### Manual Scaling Out

Now, let's scale the deployment out creating 3 replicas of the pod

```bash
kubectl scale deployment.v1.apps/kong-dp-kong -n kong-dp --replicas=3
```

Check the Deployment again and now you should see 3 replicas of the pod.

```bash
kubectl get pod -n kong-dp -o wide
```

**Sample Output**

```bash
NAME                           READY   STATUS    RESTARTS   AGE     IP               NODE                             NOMINATED NODE   READINESS GATES
kong-dp-kong-b98c776fc-6gwgh   1/1     Running   0          12s     192.168.46.35    ip-192-168-35-145.ec2.internal   <none>           <none>
kong-dp-kong-b98c776fc-87qtf   1/1     Running   0          8m22s   192.168.56.203   ip-192-168-35-145.ec2.internal   <none>           <none>
kong-dp-kong-b98c776fc-8q9bg   1/1     Running   0          12s     192.168.52.71    ip-192-168-35-145.ec2.internal   <none>           <none>
```

As we can see, the 2 new Pods have been created and are up and running. If we check our Kubernetes Service again, we will see it has been updated with the new IP addresses. That allows the Service to implement Load Balancing across the Pod replicas.

```bash
kubectl describe service kong-dp-kong-proxy -n kong-dp
```

**Sample Output**

```bash
Name:                     kong-dp-kong-proxy
Namespace:                kong-dp
Labels:                   app.kubernetes.io/instance=kong-dp
                          app.kubernetes.io/managed-by=Helm
                          app.kubernetes.io/name=kong
                          app.kubernetes.io/version=3.1
                          enable-metrics=true
                          helm.sh/chart=kong-2.14.0
Annotations:              meta.helm.sh/release-name: kong-dp
                          meta.helm.sh/release-namespace: kong-dp
Selector:                 app.kubernetes.io/component=app,app.kubernetes.io/instance=kong-dp,app.kubernetes.io/name=kong
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.100.210.146
IPs:                      10.100.210.146
LoadBalancer Ingress:     ab1f04a70e5fe4b7fac778cfff4840ec-1485985339.us-east-1.elb.amazonaws.com
Port:                     kong-proxy  80/TCP
TargetPort:               8000/TCP
NodePort:                 kong-proxy  32280/TCP
Endpoints:                192.168.46.35:8000,192.168.52.71:8000,192.168.56.203:8000
Port:                     kong-proxy-tls  443/TCP
TargetPort:               8443/TCP
NodePort:                 kong-proxy-tls  32494/TCP
Endpoints:                192.168.46.35:8443,192.168.52.71:8443,192.168.56.203:8443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age    From                Message
  ----    ------                ----   ----                -------
  Normal  EnsuringLoadBalancer  8m46s  service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   8m44s  service-controller  Ensured load balancer
```

Reduce the number of Pods to 1 again running as now we will turn on Horizontal pod autoscalar.

```bash
kubectl scale deployment.v1.apps/kong-dp-kong -n kong-dp --replicas=1
```


#### HPA - Horizontal Autoscaler

HPA (“Horizontal Pod Autoscaler”) is the Kubernetes resource to automatically control the number of replicas of Pods. With HPA, Kubernetes is able to support the requests produced by the consumers, keeping a given Service Level.

Based on CPU utilization or custom metrics, HPA starts and terminates Pods replicas updating all service data to help on the load balancing policies over those replicas.

HPA is described at https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/. Also, there's a nice walkthrough at https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

Kubernetes defines its own units for cpu and memory. You can read more about it at: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/. We use these units to set our Deployments with HPA.

### Install Metrics Server

Installation of metrics server is required for HPA to work. Install metrics server as follows

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

And test it as follows

```bash
kubectl get pod -n kube-system
```

Now you should see a new pod *metrics-server-* in *Running* state

**Sample Output**

```bash
NAME                                  READY   STATUS    RESTARTS   AGE
aws-node-6cv6p                        1/1     Running   0          20h
coredns-79989457d9-bwbzr              1/1     Running   0          20h
coredns-79989457d9-rm2fk              1/1     Running   0          20h
ebs-csi-controller-59c8fb5d88-bqpnj   6/6     Running   0          28m
ebs-csi-controller-59c8fb5d88-qgms2   6/6     Running   0          28m
ebs-csi-node-r72f8                    3/3     Running   0          28m
kube-proxy-sg8mb                      1/1     Running   0          20h
metrics-server-679799879f-wvlns       1/1     Running   0          35s
```

### Turn HPA on

Still using Helm, let's upgrade our Data Plane deployment including new and specific settings for HPA:
```
....
--set resources.requests.cpu="300m" \
--set resources.requests.memory="300Mi" \
--set resources.limits.cpu="1200m" \
--set resources.limits.memory="800Mi" \
--set autoscaling.enabled=true \
--set autoscaling.minReplicas=1 \
--set autoscaling.maxReplicas=20 \
--set autoscaling.metrics[0].type=Resource \
--set autoscaling.metrics[0].resource.name=cpu \
--set autoscaling.metrics[0].resource.target.type=Utilization \
--set autoscaling.metrics[0].resource.target.averageUtilization=75
```
The new settings are defining the ammount of CPU and memory each Pod should allocate. At the same time, the "autoscaling" sets are telling HPA how to proceed to instantiate new Pod replicas.


Here's the final Helm command:
```
helm upgrade kong-dp kong/kong -n kong-dp \
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
--set secretVolumes[0]=kong-cluster-cert \
--set resources.requests.cpu="300m" \
--set resources.requests.memory="300Mi" \
--set resources.limits.cpu="1200m" \
--set resources.limits.memory="800Mi" \
--set autoscaling.enabled=true \
--set autoscaling.minReplicas=1 \
--set autoscaling.maxReplicas=5 \
--set autoscaling.metrics[0].type=Resource \
--set autoscaling.metrics[0].resource.name=cpu \
--set autoscaling.metrics[0].resource.target.type=Utilization \
--set autoscaling.metrics[0].resource.target.averageUtilization=75
```

### Checking HPA

After submitting the command check the Deployment again. Since we're not consume the Data Plane, we are supposed to see a single Pod running. In the next sections we're going to send requests to the Data Plane and new Pod will get created to handle them.

```bash
kubectl get pod -n kong-dp
```

**Sample Output**

```bash
NAME                           READY   STATUS    RESTARTS   AGE
kong-dp-kong-889d59d8f-qfmxl   1/1     Running   0          44s
```

You can check the HPA status with:

```bash
kubectl get hpa -n kong-dp
```

**Sample Output**

```bash
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
kong-dp-kong   Deployment/kong-dp-kong   0%/75%    1         5         1          2m24s
```

Leave the HPA set so we can see it in action when sending requests to the Data Plane.