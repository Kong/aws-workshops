---
title: "Proxy Caching"
chapter: true
draft: false
weight: 1
---



# Proxy Caching Policy Definition
Since we have the Microservice exposed through a route defined in the Ingress Controller, let's apply the Proxy Caching plugin to cache the data coming from it.


Create the plugin
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: proxycache
  namespace: default
config:
  cache_ttl: 30
  strategy: memory
  content_type: ["text/html; charset=utf-8"]
plugin: proxy-cache
EOF
```

If you want to delete it run:
```
$ kubectl delete kongplugin proxycache
```

Apply the plugin to the route
```
kubectl patch ingress sampleroute -p '{"metadata":{"annotations":{"konghq.com/plugins":"proxycache"}}}'
```

In case you want to disapply the plugin to the ingress run:
```
$ kubectl annotate ingress sampleroute konghq.com/plugins-
```


Test the plugin. Since our cache is empty the <b>X-Cache-Status</b> header reports a <b>Miss</b> value. On the other hand, the value was stored in our Cache for further requests.
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 08 Jul 2021 19:56:08 GMT
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Cache-Key: f2d45950abe49485a51167bb1d1deae0
X-Cache-Status: Miss
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 1

Hello World, Kong: 2021-07-08 19:56:08.550405
```


If we send another request the Header will show <b>Hit</b> meaning the Gateway didn't have to go to the Upstream to satify the request.
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Age: 2
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 08 Jul 2021 19:56:08 GMT
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Cache-Key: f2d45950abe49485a51167bb1d1deae0
X-Cache-Status: Hit
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 0

Hello World, Kong: 2021-07-08 19:56:08.550405
```


If we wait for the 30 second timeout we configure for the Cache TTL, the Gateway will purge the data from it and respond with a <b>Miss</b> again.
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 08 Jul 2021 19:56:45 GMT
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.4.1.1-enterprise-edition
X-Cache-Key: f2d45950abe49485a51167bb1d1deae0
X-Cache-Status: Miss
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 2

Hello World, Kong: 2021-07-08 19:56:45.227579
```
