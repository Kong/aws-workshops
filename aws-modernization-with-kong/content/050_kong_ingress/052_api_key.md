---
title: "API Key Policy Definition"
chapter: true
draft: false
weight: 2
---



# API Key Policy Definition
Now, let's add an API Key Policy to this route:

Create the plugin
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: apikey
  namespace: default
plugin: key-auth
EOF
```

If you want to delete it run:
```
$ kubectl delete kongplugin apikey
```

Now, let's add an API Key Policy to this route keeping the original Rate Limiting plugin:

```
kubectl patch ingress sampleroute -p '{"metadata":{"annotations":{"konghq.com/plugins":"apikey, rl-by-minute"}}}'
```

As expected, if we try to consume the route we get an error:
```
$ http a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 401 Unauthorized
Connection: keep-alive
Content-Length: 45
Content-Type: application/json; charset=utf-8
Date: Thu, 01 Jul 2021 21:53:33 GMT
Server: kong/2.4.1.1-enterprise-edition
WWW-Authenticate: Key realm="kong"
X-Kong-Response-Latency: 1

{
    "message": "No API key found in request"
}
```

Provisioning a Key
```
$ kubectl create secret generic consumerapikey --from-literal=kongCredType=key-auth --from-literal=key=kong-secret
```

If you want to delete it run:
```
$ kubectl delete secret consumerapikey
```

Creating a Consumer with the Key
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: consumer1
  namespace: default
  annotations:
    kubernetes.io/ingress.class: kong
username: consumer1
credentials:
- consumerapikey
EOF
```

If you want to delete it run:
```
$ kubectl delete kongconsumer consumer1
```

Consume the route with the API Key
```
$ http a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com/sampleroute/hello apikey:kong-secret
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 01 Jul 2021 21:54:27 GMT
RateLimit-Limit: 3
RateLimit-Remaining: 2
RateLimit-Reset: 33
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 2
X-RateLimit-Limit-Minute: 3
X-RateLimit-Remaining-Minute: 2

Hello World, Kong: 2021-07-01 21:54:27.929739
```

Again, if we try the 4th request in a single minute we get the rate limiting error
```
$ http a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com/sampleroute/hello apikey:kong-secret
HTTP/1.1 429 Too Many Requests
Connection: keep-alive
Content-Length: 41
Content-Type: application/json; charset=utf-8
Date: Thu, 01 Jul 2021 21:54:44 GMT
RateLimit-Limit: 3
RateLimit-Remaining: 0
RateLimit-Reset: 16
Retry-After: 16
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 1
X-RateLimit-Limit-Minute: 3
X-RateLimit-Remaining-Minute: 0

{
    "message": "API rate limit exceeded"
}
```



Disable all plugins on the Ingress
```
$ kubectl annotate ingress sampleroute konghq.com/plugins-
```

You should be able to consume it with no API Key:
```
$ http a709304ada39d4c43a45eb22d27e4b8c-161423680.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 01 Jul 2021 22:11:04 GMT
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 1
X-Kong-Upstream-Latency: 1

Hello World, Kong: 2021-07-01 22:11:04.055864
```