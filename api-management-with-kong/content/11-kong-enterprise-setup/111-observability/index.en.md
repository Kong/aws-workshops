---
title : "Observability"
weight : 114
---

For observability perspective, we will use the following in this workshop

#### Prometheus and Grafana

* Kubernetes monitoring: Prometheus and Grafana monitor Kong Data Plane Deployment in terms of CPU, memory and networking consumption as well as HPA and the number of Pod replicas, just like any Kubernetes Deployment.
* Kong Data Plane monitoring: Prometheus and Grafana expose metrics the Kong Data Planes replicas provide in terms of API consumption including number of processed requests, etc.


#### AWS CloudWatch

We will configure Kong Enterprise to output metrics and logs to AWS CloudWatch. We will use CloudWatch Agent to Collect Cluster Metrics and FluentBit for logs. We will visualize in CloudWatch Dashboard and query using CloudWatch insights.