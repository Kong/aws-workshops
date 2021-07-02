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

kubectl create namespace prometheus

helm install prometheus -n prometheus prometheus-community/kube-prometheus-stack \
--set alertmanager.service.type=LoadBalancer \
--set prometheus.service.type=LoadBalancer \
--set grafana.service.type=LoadBalancer
```

Use should see several new Pods and Services after the installations
```
$ kubectl get service -n prometheus
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP                                                                  PORT(S)                      AGE
alertmanager-operated                     ClusterIP      None             <none>                                                                       9093/TCP,9094/TCP,9094/UDP   14h
prometheus-grafana                        LoadBalancer   10.100.52.93     a3231e63c5f284371b28348dddccc3e9-1485311067.eu-central-1.elb.amazonaws.com   80:30939/TCP                 14h
prometheus-kube-prometheus-alertmanager   LoadBalancer   10.100.163.45    aa657c68605e641febc82f2dc667e749-371854775.eu-central-1.elb.amazonaws.com    9093:32157/TCP               14h
prometheus-kube-prometheus-operator       ClusterIP      10.100.238.255   <none>                                                                       443/TCP                      14h
prometheus-kube-prometheus-prometheus     LoadBalancer   10.100.89.207    a6392e24d9988443bbf880c07183ae2d-181425551.eu-central-1.elb.amazonaws.com    9090:31791/TCP               14h
prometheus-kube-state-metrics             ClusterIP      10.100.136.77    <none>                                                                       8080/TCP                     14h
prometheus-operated                       ClusterIP      None             <none>                                                                       9090/TCP                     14h
prometheus-prometheus-node-exporter       ClusterIP      10.100.219.251   <none>                                                                       9100/TCP                     14h
```

```
$ kubectl get pod -n prometheus
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          14h
prometheus-grafana-7ff95c75bd-5bx7x                      2/2     Running   0          14h
prometheus-kube-prometheus-operator-59c5dcf5bc-h4glf     1/1     Running   0          14h
prometheus-kube-state-metrics-84dfc44b69-5hplx           1/1     Running   0          14h
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   1          14h
prometheus-prometheus-node-exporter-sn66l                1/1     Running   0          14h
```





### Check Prometheus
Get the Prometheus' Load Balancer address
<pre>
kubectl get service prometheus-kube-prometheus-prometheus -n prometheus --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a6392e24d9988443bbf880c07183ae2d-181425551.eu-central-1.elb.amazonaws.com
</pre>

Redirect your browser to [it](http://a6392e24d9988443bbf880c07183ae2d-181425551.eu-central-1.elb.amazonaws.com:9090)

![prometheus](/images/prometheus.png)



### Check Grafana
Do the same thing for Grafana
<pre>
kubectl get service prometheus-grafana -n prometheus --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a3231e63c5f284371b28348dddccc3e9-1485311067.eu-central-1.elb.amazonaws.com
</pre>

Get Grafana admin's password:
<pre>
$ kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
</pre>

Redirect your browser to [it](http://a3231e63c5f284371b28348dddccc3e9-1485311067.eu-central-1.elb.amazonaws.com). Use the <b>admin</b> id with the password we got.

![grafana](/images/grafana.png)










## Kong Data Plane and Prometheus Service Monitor
In order to monitor the Kong Data Planes replicas we're going to configure a Service Monitor based on a Kubernetes Service created for the Data Planes. The diagram shows the topology:



### Create a Global Prometheus plugin
First of all we have to configure the specific Prometheus plugin provided by Kong. After submitting the following declaration, all Ingresses defined will have the plugin enabled and, therefore, include their metrics on the Prometheus endpoint exposed by Kong Data Plane.
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: prometheus-plugin
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
plugin: prometheus
EOF
```

### Expose the Data Plane metrics endpoint with a Kubernetes Service
The first thing to do is to expose the Data Plane metrics port as a new Kubernetes Service. The new Kubernetes Service will be consumed by the Prometheus Service Monitor we're going to configure later.

The new Kubernetes Service will consume the metrics port 8100 provided by the Data Plane. We set the port during the Data Plane installation using the parameter <b>--set env.status_listen=0.0.0.0:8100</b>. You can check the port running:

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
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                 PORT(S)                      AGE   SELECTOR
kong-dp-kong-proxy   LoadBalancer   10.100.169.234   a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com   80:32203/TCP,443:30361/TCP   18h   app.kubernetes.io/component=app,app.kubernetes.io/instance=kong-dp,app.kubernetes.io/name=kong
```


After submitting the declaration you should see the new Kubernetes Service:
```
$ kubectl get service -n kong-dp
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                 PORT(S)                      AGE
kong-dp-kong-proxy   LoadBalancer   10.100.169.234   a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com   80:32203/TCP,443:30361/TCP   19h
kong-dp-monitoring   ClusterIP      10.100.212.247   <none>                                                                      8100/TCP                     2s
```



### Test the service.

Expose the port 8100 using <b>port-forward</b>
```
$ kubectl port-forward service/kong-dp-monitoring -n kong-dp 8100
Forwarding from 127.0.0.1:8100 -> 8100
Forwarding from [::1]:8100 -> 8100
```

<pre>
$ http :8100/metrics
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Wed, 30 Jun 2021 19:02:57 GMT
Server: kong/2.4.1.1-enterprise-edition
Transfer-Encoding: chunked
X-Kong-Admin-Latency: 3

# HELP kong_bandwidth Total bandwidth in bytes consumed per service/route in Kong
# TYPE kong_bandwidth counter
kong_bandwidth{service="default.route1-ext.pnum-80",route="default.route1.00",type="egress"} 0
kong_bandwidth{service="default.route1-ext.pnum-80",route="default.route1.00",type="ingress"} 0
# HELP kong_datastore_reachable Datastore reachable from Kong, 0 is unreachable
# TYPE kong_datastore_reachable gauge
kong_datastore_reachable 1
# HELP kong_enterprise_license_expiration Unix epoch time when the license expires, the timestamp is substracted by 24 hours to avoid difference in timezone
# TYPE kong_enterprise_license_expiration gauge
kong_enterprise_license_expiration 1653998400
# HELP kong_enterprise_license_features License features features
# TYPE kong_enterprise_license_features gauge
kong_enterprise_license_features{feature="ee_plugins"} 1
kong_enterprise_license_features{feature="write_admin_api"} 1
# HELP kong_enterprise_license_signature Last 32 bytes of the license signautre in number
# TYPE kong_enterprise_license_signature gauge
kong_enterprise_license_signature 3.5512300986528e+40
# HELP kong_http_status HTTP status codes per service/route in Kong
# TYPE kong_http_status counter
kong_http_status{service="default.route1-ext.pnum-80",route="default.route1.00",code="200"} 0
# HELP kong_latency Latency added by Kong, total request time and upstream latency for each service/route in Kong
………….
</pre>

### Create the Prometheus Service Monitor
Now, let's create the Prometheus Service Monitor collecting metrics from all Data Planes instances:

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
The Prometheus instance will be created using a specific "kong-prometheus" account. Before doing it, we need to create the account and grant specific permissions.

````
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kong-prometheus
  namespace: kong-dp
EOF

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
kong-dp-kong-58f7b865fb-btktv     1/1     Running   0          16h
prometheus-kong-dp-prometheus-0   2/2     Running   1          22s

$ kubectl get service -n kong-dp
NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                                 PORT(S)                      AGE
kong-dp-kong-proxy    LoadBalancer   10.100.169.234   a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com   80:32203/TCP,443:30361/TCP   19h
kong-dp-monitoring    ClusterIP      10.100.212.247   <none>                                                                      8100/TCP                     9m55s
prometheus-operated   ClusterIP      None             <none>                                                                      9090/TCP                     2m7s

$ kubectl get prometheus -n kong-dp
NAME                 VERSION   REPLICAS   AGE
kong-dp-prometheus                        2m21s
````
