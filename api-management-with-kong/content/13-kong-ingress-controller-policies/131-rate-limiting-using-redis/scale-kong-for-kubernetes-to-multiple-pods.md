---
title : "Scale Kong for Kubernetes to multiple pods"
weight : 137
---


Let's first ensure HPA is turned off

```bash
kubectl delete hpa kong-dp-kong -n kong-dp
```

Now, let's scale out the Kong Ingress controller deployment to 3 pods, for scalability and redundancy:

```bash
kubectl scale deployment/kong-dp-kong -n kong-dp --replicas=3
```


**Response**

```
deployment.extensions/ingress-kong scaled
```

#### Wait for replicas to deploy
It will take a couple minutes for the new pods to start up. Run the following command to show that the replicas are ready.

```bash
kubectl get pods -n kong-dp
```

```
NAME                           READY   STATUS    RESTARTS   AGE
kong-dp-kong-889d59d8f-847dg   1/1     Running   0          33s
kong-dp-kong-889d59d8f-gxqkw   1/1     Running   0          33s
kong-dp-kong-889d59d8f-szhfh   1/1     Running   0          19h
```

#### Verify traffic control
Test the rate-limiting policy by executing the following command and observing the rate-limit headers.

```bash
curl -I $DATA_PLANE_LB/foo-redis/headers
```

**Response**

```bash
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 387
Connection: keep-alive
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 4
RateLimit-Limit: 5
RateLimit-Reset: 58
RateLimit-Remaining: 4
Server: gunicorn/19.9.0
Date: Thu, 05 Jan 2023 13:44:02 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 3
X-Kong-Proxy-Latency: 1
Via: kong/3.1.1.1-enterprise-edition
```

#### Results
You will observe that the rate-limit is not consistent anymore and you can make more than 5 requests in a minute.

To understand this behavior, we need to understand how we have configured Kong. In the current policy, each Kong node is tracking a rate-limit in-memory and it will allow 5 requests to go through for a client. There is no synchronization of the rate-limit information across Kong nodes. In use-cases where rate-limiting is used as a protection mechanism and to avoid over-loading your services, each Kong node tracking it's own counter for requests is good enough as a malicious user will hit rate-limits on all nodes eventually. Or if the load-balance in-front of Kong is performing some sort of deterministic hashing of requests such that the same Kong node always
receives the requests from a client, then we won't have this problem at all.

#### Whats Next ?
In some cases, a synchronization of information that each Kong node maintains in-memory is needed. For that purpose, Redis can be used. Let's go ahead and set this up next.