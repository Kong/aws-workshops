---
title: "Cleanup"
chapter: true
draft: false
weight: 90
---

# Workshop Cleanup

Congratulations on completing the workshop! The next few sections will instruct you how to turn off all the infrastructure you've created in order to work through the material.

## Uninstall ELK
<pre>
helm uninstall elk -n elk
helm uninstall logstash -n elk
helm uninstall kibana -n elk

kubectl delete namespace elk
</pre>

## Uninstall Prometheus Operator
<pre>
kubectl delete kongclusterplugin prometheus
kubectl delete service kong-dp-monitoring -n kong-dp
kubectl delete servicemonitor kong-dp-service-monitor -n kong-dp
kubectl delete serviceaccount kong-prometheus -n kong-dp
kubectl delete clusterrole prometheus
kubectl delete clusterrolebinding prometheus
kubectl delete prometheus kong-dp-prometheus -n kong-dp

helm uninstall prometheus -n prometheus
kubectl delete namespace prometheus
</pre>

## Uninstall Kong for Kubernetes
<pre>
kubectl delete ingress route1
kubectl delete service route1-ext

kubectl delete service sample
kubectl delete deployment sample

kubectl annotate ingress sampleroute konghq.com/plugins-
kubectl delete kongplugin rl-by-minute
kubectl delete kongplugin apikey
kubectl delete secret consumerapikey
kubectl delete kongconsumer consumer1
kubectl delete kongclusterplugin tcp-log


helm uninstall kong -n kong
helm uninstall kong-dp -n kong-dp

kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl delete namespaces kong kong-dp
</pre>

## Delete the EKS Cluster
<pre>
eksctl delete cluster --name K4K8S
</pre>
