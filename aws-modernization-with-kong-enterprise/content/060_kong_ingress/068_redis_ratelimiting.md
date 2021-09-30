---
title: "Redis for Rate Limiting"
chapter: true
draft: false
weight: 8
---


# Redis for Rate Limiting

Kong can rate-limit your traffic without any external dependency. In such a case, Kong stores the request counters in-memory and each Kong node applies the rate-limiting policy independently. There is no synchronization of information being done in this case. But if Redis is available in your cluster, Kong can take advantage of it and synchronize the rate-limit information across multiple Kong nodes and enforce a slightly different rate-limiting policy.


## Turn HPA off
First of all make sure you don't have HPA set for the Data Plane. You can delete it using:
```
kubectl delete hpa kong-dp-kong -n kong-dp
```


## Create the Ingress
Again, we're going to create an Ingress for the Echo Service we deployed previously
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-redis
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /foo-redis
        backend:
          serviceName: echo
          servicePort: 80
EOF
```

## Consume the Ingress
```
$ http -h a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redis
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:24:51 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 1
```

## Set up Rate Limiting without Redis
As we did before, we are configuring Kong for Kubernetes to rate-limit traffic from any client to 5 requests per minute, applying this policy in a global sense. This means the rate-limit will apply across all services.
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: global-rate-limit
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
config:
  minute: 5
  policy: local
plugin: rate-limiting
EOF
```



## Consume the Ingress again
As expected, the rate-limiting policy execution will return the specific response when processed multiple times:

```
$ http -h a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redis
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:30:04 GMT
RateLimit-Limit: 5
RateLimit-Remaining: 4
RateLimit-Reset: 56
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 0
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 4
```

After 5 resquests:
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redis
HTTP/1.1 429 Too Many Requests
Connection: keep-alive
Content-Length: 41
Content-Type: application/json; charset=utf-8
Date: Fri, 09 Jul 2021 12:30:13 GMT
RateLimit-Limit: 5
RateLimit-Remaining: 0
RateLimit-Reset: 47
Retry-After: 47
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 1
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 0

{
    "message": "API rate limit exceeded"
}
```


## Scale the Data Plane
Now, let's scale up the Kong Data Plane deployment to 3 pods, for scale ability and redundancy:

```
kubectl scale --replicas 3 deployment kong-dp-kong -n kong-dp
```

You can check the pods with:
```
$ kubectl get pod -n kong-dp
NAME                              READY   STATUS    RESTARTS   AGE
kong-dp-kong-67c5c7d4c5-9p8jv     1/1     Running   0          10s
kong-dp-kong-67c5c7d4c5-fd4xd     1/1     Running   0          16h
kong-dp-kong-67c5c7d4c5-ff4zs     1/1     Running   0          10s
prometheus-kong-dp-prometheus-0   2/2     Running   1          19h
```


## Consume the Ingress again
You will observe that the rate-limit is not consistent anymore and you can make more than 5 requests in a minute.

To understand this behavior, we need to understand how we have configured Kong. In the current policy, each Kong node is tracking a rate-limit in-memory and it will allow 5 requests to go through for a client. There is no synchronization of the rate-limit information across Kong nodes. In use-cases where rate-limiting is used as a protection mechanism and to avoid over-loading your services, each Kong node tracking it's own counter for requests is good enough as a malicious user will hit rate-limits on all nodes eventually. Or if the load-balance in-front of Kong is performing some sort of deterministic hashing of requests such that the same Kong node always receives the requests from a client, then we won't have this problem at all.

```
$ http -h a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redis/headers
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:39:42 GMT
RateLimit-Limit: 5
RateLimit-Remaining: 3
RateLimit-Reset: 18
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 0
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 3

$ http -h a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redis/headers
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:39:43 GMT
RateLimit-Limit: 5
RateLimit-Remaining: 4
RateLimit-Reset: 17
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 5
X-Kong-Upstream-Latency: 0
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 4
```

## Update the Kong Plugin to use Redis
Note we're using the Redis Kubernetes Service FQDN for the Redis policy:
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: global-rate-limit
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
config:
  minute: 5
  policy: redis
  redis_host: redis.redis.svc.cluster.local
plugin: rate-limiting
EOF
```

```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redis/headers
HTTP/1.1 429 Too Many Requests
Connection: keep-alive
Content-Length: 41
Content-Type: application/json; charset=utf-8
Date: Fri, 09 Jul 2021 14:03:26 GMT
RateLimit-Limit: 5
RateLimit-Remaining: 0
RateLimit-Reset: 34
Retry-After: 34
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 1
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 0

{
    "message": "API rate limit exceeded"
}
```


Delete the Ingress and Rule
```
kubectl delete ingress demo-redis
kubectl delete kongclusterplugin global-rate-limit
```
