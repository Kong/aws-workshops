---
title: "Rate Limiting Policy Definition"
chapter: true
draft: false
weight: 3
---



# Rate Limiting Policy Definition
Now let's protect our upstream service with a Rate Limiting policy.


Create the plugin
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rl-by-minute
  namespace: default
config:
  minute: 3
  policy: local
plugin: rate-limiting
EOF
```

If you want to delete it run:
```
$ kubectl delete kongplugin rl-by-minute
```

Apply the plugin to the route
```
kubectl patch ingress sampleroute -p '{"metadata":{"annotations":{"konghq.com/plugins":"proxycache, rl-by-minute"}}}'
```

In case you want to disapply the plugin to the ingress run:
```
$ kubectl annotate ingress sampleroute konghq.com/plugins-
```


Test the plugin
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Age: 6
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 08 Jul 2021 20:53:58 GMT
RateLimit-Limit: 3
RateLimit-Remaining: 2
RateLimit-Reset: 2
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Cache-Key: f2d45950abe49485a51167bb1d1deae0
X-Cache-Status: Hit
X-Kong-Proxy-Latency: 1
X-Kong-Upstream-Latency: 0
X-RateLimit-Limit-Minute: 3
X-RateLimit-Remaining-Minute: 2

Hello World, Kong: 2021-07-08 20:53:58.071403
```


As expected, we get an error for the 4th request::
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 429 Too Many Requests
Connection: keep-alive
Content-Length: 41
Content-Type: application/json; charset=utf-8
Date: Thu, 08 Jul 2021 20:54:09 GMT
RateLimit-Limit: 3
RateLimit-Remaining: 0
RateLimit-Reset: 51
Retry-After: 51
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 1
X-RateLimit-Limit-Minute: 3
X-RateLimit-Remaining-Minute: 0

{
    "message": "API rate limit exceeded"
}
```

