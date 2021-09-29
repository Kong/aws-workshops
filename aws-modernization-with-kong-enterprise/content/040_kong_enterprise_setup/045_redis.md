---
title: "Redis"
chapter: true
draft: false
weight: 5
---

# Redis

Redis can be consumed by Kong Data Plane for two use cases:

* Caching: data coming from the upstream services can be cached to provide even better response and latence times
* Rate Limiting: to allow the multiple instances of the Kong Data Plane to process the same rate limiting counters

We're going to explore Kong Data Plane and Redis integration in the next sections of the workshop.

## Install Redis

<pre>
kubectl create namespace redis
</pre>

```
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: redis
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: redis
  labels:
    app: redis
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
EOF
```


## Check the installation
<pre>
$ kubectl get pod -n redis
NAME                    READY   STATUS    RESTARTS   AGE
redis-fd794cd65-t42r9   1/1     Running   0          8s
</pre>

<pre>
$ kubectl get service -n redis
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
redis   ClusterIP   10.100.195.86   <none>        6379/TCP   14s
</pre>
