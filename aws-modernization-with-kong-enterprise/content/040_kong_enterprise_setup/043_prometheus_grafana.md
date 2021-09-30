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
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
alertmanager-operated                     ClusterIP      None             <none>                                                                    9093/TCP,9094/TCP,9094/UDP   55s
prometheus-grafana                        LoadBalancer   10.100.47.13     a5f6d918221a14383813bc2f6b88c6c4-2050279250.us-east-1.elb.amazonaws.com   80:31877/TCP                 59s
prometheus-kube-prometheus-alertmanager   LoadBalancer   10.100.18.20     acb89669ac9a1432b81c25d418832f84-579800983.us-east-1.elb.amazonaws.com    9093:32325/TCP               59s
prometheus-kube-prometheus-operator       ClusterIP      10.100.118.126   <none>                                                                    443/TCP                      59s
prometheus-kube-prometheus-prometheus     LoadBalancer   10.100.19.126    a9a5daa0ee24243dabd0d771f77df7c7-832896403.us-east-1.elb.amazonaws.com    9090:31784/TCP               59s
prometheus-kube-state-metrics             ClusterIP      10.100.254.140   <none>                                                                    8080/TCP                     59s
prometheus-operated                       ClusterIP      None             <none>                                                                    9090/TCP                     55s
prometheus-prometheus-node-exporter       ClusterIP      10.100.8.65      <none>                                                                    9100/TCP                     59s
```

```
$ kubectl get pod -n prometheus
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          86s
prometheus-grafana-756d9b8485-769kp                      2/2     Running   0          89s
prometheus-kube-prometheus-operator-686b89b849-4v25b     1/1     Running   0          90s
prometheus-kube-state-metrics-58c5cd6ddb-mhjpt           1/1     Running   0          90s
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          86s
prometheus-prometheus-node-exporter-8qddg                1/1     Running   0          90s
```





### Check Prometheus
Get the Prometheus' Load Balancer address
<pre>
$ kubectl get service prometheus-kube-prometheus-prometheus -n prometheus \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a9a5daa0ee24243dabd0d771f77df7c7-832896403.us-east-1.elb.amazonaws.com
</pre>

Redirect your browser to http://a9a5daa0ee24243dabd0d771f77df7c7-832896403.us-east-1.elb.amazonaws.com:9090

![prometheus](/images/prometheus.png)



### Check Grafana
Do the same thing for Grafana
<pre>
$ kubectl get service prometheus-grafana -n prometheus \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
a5f6d918221a14383813bc2f6b88c6c4-2050279250.us-east-1.elb.amazonaws.com
</pre>

Get Grafana admin's password:
<pre>
$ kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
</pre>

Redirect your browser to it: http://a5f6d918221a14383813bc2f6b88c6c4-2050279250.us-east-1.elb.amazonaws.com. Use the <b>admin</b> id with the password we got.

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
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE   SELECTOR
kong-dp-kong-proxy   LoadBalancer   10.100.56.103    a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com   80:31032/TCP,443:30651/TCP   38m   app.kubernetes.io/component=app,app.kubernetes.io/instance=kong-dp,app.kubernetes.io/name=kong
kong-dp-monitoring   ClusterIP      10.100.170.163   <none>                                                                    8100/TCP                     6s    app.kubernetes.io/name=kong
```


After submitting the declaration you should see the new Kubernetes Service:
```
$ kubectl get service -n kong-dp
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
kong-dp-kong-proxy   LoadBalancer   10.100.56.103    a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com   80:31032/TCP,443:30651/TCP   38m
kong-dp-monitoring   ClusterIP      10.100.170.163   <none>                                                                    8100/TCP                     34s
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
Date: Thu, 30 Sep 2021 15:25:09 GMT
Server: kong/2.5.1.0-enterprise-edition
Transfer-Encoding: chunked
X-Kong-Admin-Latency: 4
X-Kong-Status-Request-ID: QNX72r2DlUxloZaqoWkMIBBU0Rvug2Jg

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
# HELP kong_memory_lua_shared_dict_bytes Allocated slabs in bytes in a shared_dict
# TYPE kong_memory_lua_shared_dict_bytes gauge
kong_memory_lua_shared_dict_bytes{shared_dict="kong",kong_subsystem="http"} 40960
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
kong-dp-kong-67995ddc8c-4vhph     1/1     Running   0          13m
prometheus-kong-dp-prometheus-0   2/2     Running   0          43s
````

````
$ kubectl get service -n kong-dp
NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
kong-dp-kong-proxy    LoadBalancer   10.100.56.103    a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com   80:31032/TCP,443:30651/TCP   44m
kong-dp-monitoring    ClusterIP      10.100.170.163   <none>                                                                    8100/TCP                     6m38s
prometheus-operated   ClusterIP      None             <none>                                                                    9090/TCP                     4m12s
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
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
kong-dp-kong-proxy       LoadBalancer   10.100.56.103    a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com   80:31032/TCP,443:30651/TCP   45m
kong-dp-monitoring       ClusterIP      10.100.170.163   <none>                                                                    8100/TCP                     7m20s
prometheus-operated      ClusterIP      None             <none>                                                                    9090/TCP                     4m54s
prometheus-operated-lb   LoadBalancer   10.100.77.90     a81a086ab48e446d68c35d0bd0e93550-437150660.us-east-1.elb.amazonaws.com    9090:31798/TCP               14s
````