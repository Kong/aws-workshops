---
title : "Set up ingress rule for Redis"
weight : 135
---


#### Create an Ingress rule to proxy the httpbin service.

Let's add an Ingress rule which proxies requests to /redis to the httpbin-2 service

```bash
echo '
apiVersion: networking.k8s.io/v1
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
        pathType: Prefix
        backend:
          service:
            name: httpbin-2
            port: 
              number: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/demo-redis created
```


#### Verify ingress rule

Test access to the httpbin-2 service

```bash
curl -i $DATA_PLANE_LB/foo-redis/status/200
```


**Response**

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: keep-alive
Server: gunicorn/19.9.0
Date: Thu, 05 Jan 2023 13:38:15 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/3.1.1.1-enterprise-edition
```
