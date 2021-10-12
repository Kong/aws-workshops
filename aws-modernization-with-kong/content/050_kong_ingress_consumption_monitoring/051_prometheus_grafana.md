---
title: "Prometheus and Grafana"
chapter: false
weight: 51
---

## Prometheus and Grafana

Since we have Prometheus and Grafana already deployed where going to consume the Data Plane and monitor it from two perspectives:<p>

* Kubernetes monitoring: monitor the Kong Data Plane Deployment in terms of resource consumption (CPU, memory and networking)
* Kong Data Plane monitoring: monitor the Kong Data Plane in terms of API consumption including number of processed requests, latency times, etc.


## Kubernetes Monitoring and HPA

### Fortio
Use Fortio to start injecting some request to the Data Plane
````
$ fortio load -c 120 -qps 2000 -t 0 http://a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com/sampleroute/hello
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
$ curl -gs 'http://a81a086ab48e446d68c35d0bd0e93550-437150660.us-east-1.elb.amazonaws.com:9090/api/v1/query?query=sum(rate(kong_http_status{code="200"}[1m]))' | jq -r .data.result[].value[1]
199.8
````

Get the number of successful processed requests
````
$ curl -gs 'http://a81a086ab48e446d68c35d0bd0e93550-437150660.us-east-1.elb.amazonaws.com:9090/api/v1/query?query=kong_http_status{code="200"}' | jq -r .data.result[].value[1]
669973
````

Check the new Prometheus instance GUI redirecting your browser to http://a81a086ab48e446d68c35d0bd0e93550-437150660.us-east-1.elb.amazonaws.com:9090


![service_monitor2](/images/service_monitor2.png)

````
$ kubectl get hpa -n kong-dp
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
kong-dp-kong   Deployment/kong-dp-kong   66%/75%   1         20        7          80m

$ kubectl get pod -n kong-dp
NAME                              READY   STATUS    RESTARTS   AGE
kong-dp-kong-67995ddc8c-2t2gj     1/1     Running   0          2m44s
kong-dp-kong-67995ddc8c-4vhph     1/1     Running   0          80m
kong-dp-kong-67995ddc8c-4xjv2     1/1     Running   0          2m44s
kong-dp-kong-67995ddc8c-7jsxl     1/1     Running   0          4m30s
kong-dp-kong-67995ddc8c-8k44s     1/1     Running   0          3m44s
kong-dp-kong-67995ddc8c-bpdvh     1/1     Running   0          2m44s
kong-dp-kong-67995ddc8c-npnjf     1/1     Running   0          4m15s
prometheus-kong-dp-prometheus-0   2/2     Running   0          67m
````

## Accessing Grafana

Create a new Grafana Data Source based on the Prometheus Service URL: <b>http://prometheus-operated.kong-dp.svc.cluster.local:9090</b>

![grafana_newdatasource](/images/grafana_newdatasource.png)

Now, based on this new Data Source, import the official Kong Grafana Dashboard with id <b>7424</b>

![grafana_newdashboard](/images/grafana_newdashboard.png)

You should be able to see Kong Data Plane metrics now:

![grafana_dashboard1](/images/grafana_dashboard1.png)

