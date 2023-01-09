---
title : "Metrics"
weight : 142
---

#### Check Grafana

Direct your browser to Grafana again. You can get the Grafana URL by running `echo $GRAFANA_LB` if required. Click on **Dashboards** and **Manage**. Choose the **Kubernetes/Computer Resources/Namespaces (Pods)** dashboard. Choose the **kong-dp** namespace.

![grafana_pods1](/static/images/grafana_pods1.png)

Now browse to `Kong(Official)` dashboard to explore Request Rates, Latencies, Bandwidth, Caching , Upstream and Nginx specific UI panels

![kong_dashboard](/static/images/kong-dashboard.png)

#### Check HPA

Since we're using HPA, the number of Pods should increase to satify our settings.

![grafana_pods2](/static/images/grafana_pods2.png)

In fact, we can see the new current HPA status with:

```bash
kubectl get hpa -n kong-dp
```

**Expected Output**

```bash
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
kong-dp-kong   Deployment/kong-dp-kong   15%/75%   1         20        3          15h
```