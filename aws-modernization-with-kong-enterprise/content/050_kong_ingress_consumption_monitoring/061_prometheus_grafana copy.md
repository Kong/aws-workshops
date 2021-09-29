---
title: "Prometheus and Grafana"
chapter: false
weight: 61
---

## Prometheus and Grafana

Since we have Prometheus and Grafana already deployed where going to consume the Data Plane and monitor it from two perspectives:<p>

* Kubernetes monitoring: monitor the Kong Data Plane Deployment in terms of resource consumption (CPU, memory and networking)
* Kong Data Plane monitoring: monitor the Kong Data Plane in terms of API consumption including number of processed requests, latency times, etc.


## Kubernetes Monitoring and HPA

### Fortio
Use Fortio to start injecting some request to the Data Plane
````
$ fortio load -c 120 -qps 2000 -t 0 http://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/sampleroute/hello
````

### Check Grafana
Direct your browser to Grafana again. Click on <b>"Dashboards"</b> and <b>"Manage"</b>. Choose the <b>"Kubernetes/Computer Resources/Namespaces (Pods)"</b> dashboard. Choose the <b>"kong-dp"</b> namespace.

![grafana_pods1](/images/grafana_pods1.png)


### Check HPA
Since we're using HPA, the number of Pods should increase to satify our settings.

![grafana_pods2](/images/grafana_pods2.png)

In fact, we can see the new current HPA status with:

````
$ kubectl get hpa -n kong-dp
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
kong-dp-kong   Deployment/kong-dp-kong   15%/75%   1         20        3          15h
````





## Kong Data Plane Monitoring

### Consume the new Prometheus Service
Get the API consumption rate
````
$ curl -gs 'http://a6c91b4ef9c9543b285aea42c00fbbb2-2102856654.eu-central-1.elb.amazonaws.com:9090/api/v1/query?query=sum(rate(kong_http_status{code="200"}[1m]))' | jq -r .data.result[].value[1]
199.8
````

Get the number of successful processed requests
````
$ curl -gs 'http://a6c91b4ef9c9543b285aea42c00fbbb2-2102856654.eu-central-1.elb.amazonaws.com:9090/api/v1/query?query=kong_http_status{code="200"}' | jq -r .data.result[].value[1]
669973
````

Check the new Prometheus instance GUI redirecting your browser to http://a6c91b4ef9c9543b285aea42c00fbbb2-2102856654.eu-central-1.elb.amazonaws.com:9090


![service_monitor2](/images/service_monitor2.png)

````
$ kubectl get hpa -n kong-dp
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
kong-dp-kong   Deployment/kong-dp-kong   40%/75%   1         20        4          17h

$ kubectl get pod -n kong-dp
NAME                              READY   STATUS    RESTARTS   AGE
kong-dp-kong-58f7b865fb-584km     1/1     Running   0          98s
kong-dp-kong-58f7b865fb-btktv     1/1     Running   0          17h
kong-dp-kong-58f7b865fb-s2bhh     1/1     Running   0          98s
kong-dp-kong-58f7b865fb-t9n9p     1/1     Running   0          98s
prometheus-kong-dp-prometheus-0   2/2     Running   1          13m
````

## Accessing Grafana

Create a new Grafana Data Source based on the Prometheus Service URL: <b>http://prometheus-operated.kong-dp.svc.cluster.local:9090</b>

![grafana_newdatasource](/images/grafana_newdatasource.png)

Now, based on this new Data Source, import the official Kong Grafana Dashboard with id <b>7424</b>

![grafana_newdashboard](/images/grafana_newdashboard.png)

You should be able to see Kong Data Plane metrics now:

![grafana_dashboard1](/images/grafana_dashboard1.png)

