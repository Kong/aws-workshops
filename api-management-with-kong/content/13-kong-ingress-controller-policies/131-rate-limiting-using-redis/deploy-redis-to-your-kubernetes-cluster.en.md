---
title : "Deploy Redis to your Kubernetes cluster"
weight : 138
---

Let's deploy redis in our Kubernetes cluster

```bash
kubectl create namespace redis
kubectl apply -n redis -f https://bit.ly/k8s-redis
```

**Response**

```
deployment.apps/redis created
service/redis created
```

#### Update KongPlugin resource
Once this is deployed, let's update our Kong Plugin configuration to use Redis as a data store rather than each Kong node storing the counter information in-memory:

```bash
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

**Response**

```
kongplugin.configuration.konghq.com/global-rate-limit configured
```

Notice, how the  policy  is now set to  `redis.redis.svc.cluster.local`  and we have configured Kong to talk to the  `redis`   server available at  `redis.redis.svc.cluster.local` Kubernetes Service FQDN. This is the Redis node you deployed earlier.


#### Test it

Execute the following commands more than 5 times.

What happens?

```bash
curl -I $DATA_PLANE_LB/foo-redis/headers
```

**Response**

```
HTTP/1.1 429 Too Many Requests
Date: Thu, 05 Jan 2023 13:46:33 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
X-RateLimit-Limit-Minute: 5
X-RateLimit-Remaining-Minute: 0
RateLimit-Limit: 5
Retry-After: 27
RateLimit-Reset: 27
RateLimit-Remaining: 0
Content-Length: 41
X-Kong-Response-Latency: 1
Server: kong/3.1.1.1-enterprise-edition
```

#### Results
Because Redis is the data-store for the rate-limiting plugin, you should be able to make only 5 requests in a minute


#### Conclusion
You just configured Redis as a data-store to synchronize information across multiple Kong nodes to enforce the rate-limiting policy.  This can also be used for other plugins which support Redis as a data-store such as proxy-cache.

#### Cleanup

Delete the Kong **Cluster** plugin by running following command. Cleanup ensures that this plugin does not interferes with any other modules in the workshop for demo purposes and each workshop module code continues to function indepdently.

```bash
kubectl delete kongclusterplugin global-rate-limit
```

In real world scenario, you can enable as many plugins as you like depending on your use cases.