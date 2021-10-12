---
title: "Simple Kong Ingress"
chapter: true
draft: false
weight: 7
---

# Kong Ingress

## Create an Ingress CRDs
In order to expose "sample" through K4K8S, we're going to create a specific "/sampleroute" route. Initially, the route is totally open and can be consumed freely. The next sections enable, as the name suggests, an API Key and a Rate Limiting mechanisms to protect the route.

```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: sampleroute
  namespace: default
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
        - path: /sampleroute
          backend:
            serviceName: sample
            servicePort: 5000
EOF
```


## Consume the Ingress
Sending a single request to the Data Plane to test the Ingress using the Kong Data Plane ELB:
```
$ http a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com/sampleroute/hello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 30 Sep 2021 15:41:46 GMT
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.5.1.0-enterprise-edition
X-Kong-Proxy-Latency: 1
X-Kong-Upstream-Latency: 1

Hello World, Kong: 2021-09-30 15:41:46.085222
```