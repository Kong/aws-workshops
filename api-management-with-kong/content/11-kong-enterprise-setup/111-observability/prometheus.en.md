---
title : "Creating Prometheus and Grafana"
weight : 115
---


We will use [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) for Kubernetes monitoring and Kong Data Plane monitoring. 

To support HPA from the Observability perspective, we're going to configure [Service Monitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md) to monitor the variable number of Pod replicas.

#### Prometheus Operator

First of all, let's install Prometheus Operator with its specific Helm Charts. Note we're requesting Load Balancers to expose Prometheus and Grafana UIs as well as installing the Kong dashboard for Grafana.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```


```bash
kubectl create namespace prometheus
```

```bash
helm install prometheus -n prometheus prometheus-community/kube-prometheus-stack \
--set alertmanager.enabled=false \
--set grafana.service.type=LoadBalancer
```

Use should now see several new Pods and Services after the installations

```bash
kubectl get service -n prometheus
```

**Expected Output**

```bash
NAME                                    TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
prometheus-grafana                      LoadBalancer   10.100.131.236   a02fb0e85c3d34db8b13aa67a487207f-1905633611.us-east-1.elb.amazonaws.com   80:32740/TCP   40s
prometheus-kube-prometheus-operator     ClusterIP      10.100.96.45     <none>                                                                    443/TCP        40s
prometheus-kube-prometheus-prometheus   ClusterIP      10.100.93.196    <none>                                                                    9090/TCP       40s
prometheus-kube-state-metrics           ClusterIP      10.100.165.194   <none>                                                                    8080/TCP       40s
prometheus-operated                     ClusterIP      None             <none>                                                                    9090/TCP       36s
prometheus-prometheus-node-exporter     ClusterIP      10.100.115.73    <none>                                                                    9100/TCP       40s
```

```bash
kubectl get pod -n prometheus
```

**Expected Output**

```bash
NAME                                                   READY   STATUS    RESTARTS   AGE
prometheus-grafana-b54559ffd-r8cnh                     3/3     Running   0          77s
prometheus-kube-prometheus-operator-7679f7fddb-d7gzq   1/1     Running   0          77s
prometheus-kube-state-metrics-675b965b4c-jr59g         1/1     Running   0          77s
prometheus-prometheus-kube-prometheus-prometheus-0     2/2     Running   0          74s
prometheus-prometheus-node-exporter-vdx8k              1/1     Running   0          78s
```


#### Check Grafana

Export the load balancer for Grafana

```bash
echo "export GRAFANA_LB=$(kubectl get service prometheus-grafana -n prometheus \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash
```

```bash
echo $GRAFANA_LB
```

Copy the output and open in your browser

Enter username as `admin` and get Grafana admin's password from the following command

```bash
kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

![grafana](/static/images/grafana.png)


