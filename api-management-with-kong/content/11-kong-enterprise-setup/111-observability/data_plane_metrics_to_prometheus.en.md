---
title : "Data Plane Metrics to Prometheus"
weight : 116
---



#### Upgrade the Data Plane deployment

In order to monitor the Kong Data Planes replicas we're going to configure a Service Monitor based on a Kubernetes Service created for the Data Planes. We should upgrade the deployment to enable the Service Monitor with two new settings:

```bash
...
--set serviceMonitor.enabled=true \
--set serviceMonitor.labels.release=prometheus
```

The Helm upgrade command is:

```bash
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
--set autoscaling.metrics[0].resource.target.averageUtilization=75 \
--set serviceMonitor.enabled=true \
--set serviceMonitor.labels.release=prometheus
```



#### Check the Kong Service Monitor

The Kong Data Plane Service Monitor is based on port status (8100). Since this is the Kong Data Plane, the cmetrics port (10255), available for the Kong Ingress Controller running on the Control Plane, is not used.

```bash
kubectl describe servicemonitor kong-dp-kong -n kong-dp
```

**Expected Output**

```bash
Name:         kong-dp-kong
Namespace:    kong-dp
Labels:       app.kubernetes.io/instance=kong-dp
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=kong
              app.kubernetes.io/version=3.1
              helm.sh/chart=kong-2.14.0
              release=prometheus
Annotations:  meta.helm.sh/release-name: kong-dp
              meta.helm.sh/release-namespace: kong-dp
API Version:  monitoring.coreos.com/v1
Kind:         ServiceMonitor
Metadata:
  Creation Timestamp:  2023-01-04T15:17:53Z
  Generation:          1
  Managed Fields:
    API Version:  monitoring.coreos.com/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:meta.helm.sh/release-name:
          f:meta.helm.sh/release-namespace:
        f:labels:
          .:
          f:app.kubernetes.io/instance:
          f:app.kubernetes.io/managed-by:
          f:app.kubernetes.io/name:
          f:app.kubernetes.io/version:
          f:helm.sh/chart:
          f:release:
      f:spec:
        .:
        f:endpoints:
        f:jobLabel:
        f:namespaceSelector:
          .:
          f:matchNames:
        f:selector:
    Manager:         helm
    Operation:       Update
    Time:            2023-01-04T15:17:53Z
  Resource Version:  209969
  UID:               024b551a-3485-45ee-9dc1-2ab60d57dee2
Spec:
  Endpoints:
    Scheme:       http
    Target Port:  status
    Scheme:       http
    Target Port:  cmetrics
  Job Label:      kong-dp
  Namespace Selector:
    Match Names:
      kong-dp
  Selector:
    Match Labels:
      app.kubernetes.io/instance:    kong-dp
      app.kubernetes.io/managed-by:  Helm
      app.kubernetes.io/name:        kong
      app.kubernetes.io/version:     3.1
      Enable - Metrics:              true
      helm.sh/chart:                 kong-2.14.0
Events:                              <none>
```



#### Create a Global Prometheus plugin

To check our Service Monitor and Prometheus Operator, we are going to define our first Ingress based on the <b>httpbin.org</b> public service.

First of all we have to configure the specific Prometheus plugin provided by Kong. After submitting the following declaration, all Ingresses defined will have the plugin enabled and, therefore, include their metrics on the Prometheus endpoint exposed by the Kong Data Plane.

Execute the following command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: prometheus
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
config:
  per_consumer: true
  status_code_metrics: true
  latency_metrics: true
  bandwidth_metrics: true
  upstream_health_metrics: true
plugin: prometheus
EOF
```



#### Define a Kubernetes External Service based on the Public Service

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: route1-ext
  namespace: default
spec:
  ports:
  - protocol: TCP
    port: 80
  type: ExternalName
  externalName: httpbin.org
EOF
```


#### Create an Ingress based on an External Service

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: route1
  namespace: default
  annotations:
    konghq.com/strip-path: "true"
spec:
  ingressClassName: kong
  rules:
  - http:
      paths:
      - path: /route1
        pathType: ImplementationSpecific
        backend:
          service:
            name: route1-ext
            port:
              number: 80
EOF
```


#### Consume the Ingress

You can start a loop sending request to the Data Plane:

```bash
while [ 1 ]; do curl $DATA_PLANE_LB/route1/get; echo; done
```



#### Import the Grafana Dashboard

Import the official Kong Grafana Dashboard with id **7424**

To do so, copy the **output** from the following command and open in a browser.

```bash
echo $GRAFANA_LB/dashboard/import
```
Enter **7424** under "Import via grafana.com" > **Load**

![grafana_newdashboard](/static/images/grafana_newdashboard.png)

Set **Prometheus** as the Data Source

You should be able to see Kong Data Plane metrics now:

![grafana_dashboard1](/static/images/grafana_dashboard1.png)

