---
title : "Sample Application"
weight : 120
---


Start by installing two applications: [echo](https://github.com/kubernetes/kubernetes/blob/master/test/images/echoserver/README.md) and [httpbin](http://httpbin.org/). Both consist of a Kubernetes [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

#### Deploy the echo service

```bash
kubectl apply -f https://bit.ly/sample-echo-service
```

**Response**

```
service/echo created
deployment.apps/echo created
```

#### Deploy the httpbin service

```bash
kubectl apply -f https://bit.ly/sample-httpbin-service
```

**Response**

```
service/httpbin created
deployment.apps/httpbin created
service/httpbin-2 created
deployment.apps/httpbin-2 created
```

#### Verification

Verify that the  echo, httpbin and httpbin-2 deployments are fully rolled out.


```bash
kubectl get deployment --namespace=default
```

**Response**

```
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
echo       2/2     2            2           52s
httpbin    1/1     1            1           33s
httpbin-2  1/1     1            1           33s
```

The ready column displays two numbers: how many pods of a deployment are ready and how many are desired in the <Ready>/<Desired> format. Wait until all the desired pods are ready before proceeding to the next step.