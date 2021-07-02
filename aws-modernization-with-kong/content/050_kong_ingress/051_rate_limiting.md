---
title: "Rate Limiting Policy Definition"
chapter: true
draft: false
weight: 1
---



# Rate Limiting Policy Definition
Since we have the Microservice exposed through a route defined in the Ingress Controller, let's protect it with a Rate Limiting Policy first.


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
kubectl patch ingress sampleroute -p '{"metadata":{"annotations":{"konghq.com/plugins":"rl-by-minute"}}}'
```

In case you want to disapply the plugin to the ingress run:
```
$ kubectl annotate ingress sampleroute konghq.com/plugins-
```


Test the plugin
```
$ http a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 01 Jul 2021 21:52:22 GMT
RateLimit-Limit: 3
RateLimit-Remaining: 2
RateLimit-Reset: 38
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 2
X-RateLimit-Limit-Minute: 3
X-RateLimit-Remaining-Minute: 2

Hello World, Kong: 2021-07-01 21:52:22.386798
```


As expected, we get an error for the 4th request::
```
$ http a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 429 Too Many Requests
Connection: keep-alive
Content-Length: 41
Content-Type: application/json; charset=utf-8
Date: Thu, 01 Jul 2021 21:52:43 GMT
RateLimit-Limit: 3
RateLimit-Remaining: 0
RateLimit-Reset: 17
Retry-After: 17
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 0
X-RateLimit-Limit-Minute: 3
X-RateLimit-Remaining-Minute: 0

{
    "message": "API rate limit exceeded"
}
```

