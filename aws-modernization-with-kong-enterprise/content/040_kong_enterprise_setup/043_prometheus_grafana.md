---
title: "Prometheus and Grafana"
chapter: true
draft: false
weight: 3
---

# Prometheus and Grafana

From the Observability perspective, we're going to use Prometheus and Grafana. Two levels of monitoring are possible:<p>

* Kubernetes monitoring: Prometheus and Grafana monitor Kong Data Plane Deployment in terms of CPU, memory and networking consumption as well as HPA and the number of Pod replicas, just like any Kubernetes Deployment.
* Kong Data Plane monitoring: Prometheus and Grafana expose metrics the Kong Data Planes replicas provide in terms of API consumption including number of processed requests, etc.

We're going to use [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) to address these two monitoring levels. Moreover, to support HPA from the Observability perspective, we're going to configure [Service Monitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md) to monitor the variable number of Pod replicas.



## Prometheus Operator

First of all, let's install Prometheus Operator with its specific Helm Charts. Note we're requesting Load Balancers to expose Prometheus, Grafana and Alert Manager UIs.

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

```
kubectl create namespace prometheus
```

```
helm install prometheus -n prometheus prometheus-community/kube-prometheus-stack \
--set alertmanager.service.type=LoadBalancer \
--set prometheus.service.type=LoadBalancer \
--set grafana.service.type=LoadBalancer
```

Use should see several new Pods and Services after the installations
```
$ kubectl get service -n prometheus
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP                                                                 PORT(S)                      AGE
alertmanager-operated                     ClusterIP      None             <none>                                                                      9093/TCP,9094/TCP,9094/UDP   26m
prometheus-grafana                        LoadBalancer   10.100.204.248   ae1ec0bd5f24349d29915b384b0e357f-301715715.eu-central-1.elb.amazonaws.com   80:31331/TCP                 27m
prometheus-kube-prometheus-alertmanager   LoadBalancer   10.100.98.34     a8bc14bcf3eb34ce4bd6b1607be191f8-225304004.eu-central-1.elb.amazonaws.com   9093:31094/TCP               27m
prometheus-kube-prometheus-operator       ClusterIP      10.100.0.147     <none>                                                                      443/TCP                      27m
prometheus-kube-prometheus-prometheus     LoadBalancer   10.100.160.161   a49dce814ab2f40f3b34ae942e02bf4b-931182925.eu-central-1.elb.amazonaws.com   9090:30701/TCP               27m
prometheus-kube-state-metrics             ClusterIP      10.100.23.71     <none>                                                                      8080/TCP                     27m
prometheus-operated                       ClusterIP      None             <none>                                                                      9090/TCP                     26m
prometheus-prometheus-node-exporter       ClusterIP      10.100.130.95    <none>                                                                      9100/TCP                     27m
```

```
$ kubectl get pod -n prometheus
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          27m
prometheus-grafana-7ff95c75bd-vkkzp                      2/2     Running   0          27m
prometheus-kube-prometheus-operator-59c5dcf5bc-vwbpp     1/1     Running   0          27m
prometheus-kube-state-metrics-84dfc44b69-nl5n9           1/1     Running   0          27m
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   1          27m
prometheus-prometheus-node-exporter-jtzts                1/1     Running   0          27m
```





### Check Prometheus
Get the Prometheus' Load Balancer address
<pre>
$ kubectl get service prometheus-kube-prometheus-prometheus -n prometheus \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a49dce814ab2f40f3b34ae942e02bf4b-931182925.eu-central-1.elb.amazonaws.com
</pre>

Redirect your browser to http://a49dce814ab2f40f3b34ae942e02bf4b-931182925.eu-central-1.elb.amazonaws.com:9090

![prometheus](/images/prometheus.png)



### Check Grafana
Do the same thing for Grafana
<pre>
$ kubectl get service prometheus-grafana -n prometheus \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
ae1ec0bd5f24349d29915b384b0e357f-301715715.eu-central-1.elb.amazonaws.com
</pre>

Get Grafana admin's password:
<pre>
$ kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
</pre>

Redirect your browser to it: http://ae1ec0bd5f24349d29915b384b0e357f-301715715.eu-central-1.elb.amazonaws.com. Use the <b>admin</b> id with the password we got.

![grafana](/images/grafana.png)










## Kong Data Plane and Prometheus Service Monitor
In order to monitor the Kong Data Planes replicas we're going to configure a Service Monitor based on a Kubernetes Service created for the Data Planes. The diagram shows the topology:



### Create a Global Prometheus plugin
First of all we have to configure the specific Prometheus plugin provided by Kong. After submitting the following declaration, all Ingresses defined will have the plugin enabled and, therefore, include their metrics on the Prometheus endpoint exposed by the Kong Data Plane.
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: prometheus
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
plugin: prometheus
EOF
```

### Expose the Data Plane metrics endpoint with a Kubernetes Service
The next thing to do is to expose the Data Plane metrics port as a new Kubernetes Service. The new Kubernetes Service will be consumed by the Prometheus Service Monitor we're going to configure later.

The new Kubernetes Service will be based on the metrics port 8100 provided by the Data Plane. We set the port during the Data Plane installation using the parameter <b>\-\-set env.status_listen=0.0.0.0:8100</b>. You can check the port running:

````
$ kubectl describe pod kong-dp-kong -n kong-dp | grep Ports
    Ports:          8000/TCP, 8443/TCP, 8100/TCP
    Host Ports:     0/TCP, 0/TCP, 0/TCP
````

Here's the new Kubernetes Service declaration:
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kong-dp-monitoring
  namespace: kong-dp
  labels:
    app: kong-dp-monitoring
spec:
  selector:
    app.kubernetes.io/name: kong
  type: ClusterIP
  ports:
  - name: metrics
    protocol: TCP
    port: 8100
    targetPort: 8100
EOF
```

Note that the new Kubernetes Service is selecting the existing Data Plane Kubernetes Service using its specific label <b>app.kubernetes.io/name: kong</b>

Use can check the label running:
```
$ kubectl get service -n kong-dp -o wide
NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP                                                                  PORT(S)                      AGE   SELECTOR
kong-dp-kong-proxy   LoadBalancer   10.100.12.30   a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com   80:32336/TCP,443:31316/TCP   53m   app.kubernetes.io/component=app,app.kubernetes.io/instance=kong-dp,app.kubernetes.io/name=kong
```


After submitting the declaration you should see the new Kubernetes Service:
```
$ kubectl get service -n kong-dp
NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP                                                                  PORT(S)                      AGE
kong-dp-kong-proxy   LoadBalancer   10.100.12.30   a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com   80:32336/TCP,443:31316/TCP   54m
kong-dp-monitoring   ClusterIP      10.100.91.54   <none>                                                                       8100/TCP                     66s
```



### Test the service.

On one local terminal, expose the port 8100 using <b>port-forward</b>
```
$ kubectl port-forward service/kong-dp-monitoring -n kong-dp 8100
Forwarding from 127.0.0.1:8100 -> 8100
Forwarding from [::1]:8100 -> 8100
```

On another terminal send a request to it:

<pre>
$ http :8100/metrics
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Thu, 08 Jul 2021 16:38:26 GMT
Server: kong/2.4.1.1-enterprise-edition
Transfer-Encoding: chunked
X-Kong-Admin-Latency: 3

# HELP kong_datastore_reachable Datastore reachable from Kong, 0 is unreachable
# TYPE kong_datastore_reachable gauge
kong_datastore_reachable 1
# HELP kong_enterprise_license_errors Errors when collecting license info
# TYPE kong_enterprise_license_errors counter
kong_enterprise_license_errors 1
# HELP kong_memory_lua_shared_dict_bytes Allocated slabs in bytes in a shared_dict
# TYPE kong_memory_lua_shared_dict_bytes gauge
kong_memory_lua_shared_dict_bytes{shared_dict="kong"} 40960
………….
</pre>

### Create the Prometheus Service Monitor
Now, let's create the Prometheus Service Monitor collecting metrics from all Data Planes instances. The Service Monitor is based on the new <b>kong-dp-monitoring</b> Kubernetes Service we created before:

```
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kong-dp-service-monitor
  namespace: kong-dp
  labels:
    release: kong-dp
spec:
  namespaceSelector:
    any: true
  endpoints:
  - port: metrics       
  selector:
    matchLabels:
      app: kong-dp-monitoring
EOF
```

### Starting a Prometheus instance for the Kong Data Plane
A specific Prometheus instance will be created to monitor the Kong Data Plane using a specific "kong-prometheus" account. Before doing it, we need to create the account and grant specific permissions.

````
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kong-prometheus
  namespace: kong-dp
EOF
````

````
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
EOF
````

````
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: kong-prometheus
  namespace: kong-dp
EOF
````

Instantiate a Prometheus Service for the Kong Data Plane
````
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: kong-dp-prometheus
  namespace: kong-dp
spec:
  serviceAccountName: kong-prometheus
  serviceMonitorSelector:
    matchLabels:
      release: kong-dp
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: true
EOF
````

Check the Installation
````
$ kubectl get pod -n kong-dp
NAME                              READY   STATUS    RESTARTS   AGE
kong-dp-kong-67c5c7d4c5-n2cv6     1/1     Running   0          44m
prometheus-kong-dp-prometheus-0   2/2     Running   1          3m39s
````

````
$ kubectl get service -n kong-dp
NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP                                                                  PORT(S)                      AGE
kong-dp-kong-proxy    LoadBalancer   10.100.12.30   a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com   80:32336/TCP,443:31316/TCP   61m
kong-dp-monitoring    ClusterIP      10.100.91.54   <none>                                                                       8100/TCP                     7m50s
prometheus-operated   ClusterIP      None           <none>                                                                       9090/TCP                     3m54s
````

````
$ kubectl get prometheus -n kong-dp
NAME                 VERSION   REPLICAS   AGE
kong-dp-prometheus                        4m8s
````


Expose the new Prometheus service
````
$ kubectl expose service prometheus-operated --name prometheus-operated-lb --type=LoadBalancer -n kong-dp
service/prometheus-operated-lb exposed
````

````
$ kubectl get service -n kong-dp
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP                                                                  PORT(S)                      AGE
kong-dp-kong-proxy       LoadBalancer   10.100.12.30    a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com   80:32336/TCP,443:31316/TCP   78m
kong-dp-monitoring       ClusterIP      10.100.91.54    <none>                                                                       8100/TCP                     24m
prometheus-operated      ClusterIP      None            <none>                                                                       9090/TCP                     20m
prometheus-operated-lb   LoadBalancer   10.100.81.131   a6c91b4ef9c9543b285aea42c00fbbb2-2102856654.eu-central-1.elb.amazonaws.com   9090:31259/TCP               4s
````