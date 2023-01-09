---
title : "Ingress Rule"
weight : 131
---

Expose the echo and httpbin services outside the Kubernetes cluster by defining Ingress rules.

#### Add ingress resource for echo service
Add an Ingress resource which proxies requests to  /foo to the httpbin service and /bar to the echo service

**NOTE** This is the new syntax for Kubernetes version 1.22 onwards

```bash
echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /foo
        pathType: Prefix
        backend:
          service:
            name: httpbin
            port: 
              number: 80
      - path: /bar
        pathType: Prefix
        backend:
          service:
            name: echo
            port: 
              number: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/demo created
```


#### Verify endpoints
Test access to the http service and echo service

**Request**

```bash
curl -i $DATA_PLANE_LB/foo/status/200
```

**Response**
```bash
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: keep-alive
Server: gunicorn/19.9.0
Date: Thu, 05 Jan 2023 13:15:55 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/3.1.1.1-enterprise-edition
```

**Request**
```bash
curl -i $DATA_PLANE_LB/bar
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
Date: Thu, 05 Jan 2023 13:16:03 GMT
Server: echoserver
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 0
Via: kong/3.1.1.1-enterprise-edition



Hostname: echo-744d654d7b-cd4wp

Pod Information:
	node name:	ip-192-168-55-192.ec2.internal
	pod name:	echo-744d654d7b-cd4wp
	pod namespace:	default
	pod IP:	192.168.34.232

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.43.68
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com:8080/

Request Headers:
	accept=*/*  
	connection=keep-alive  
	host=a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com  
	user-agent=curl/7.85.0  
	x-forwarded-for=192.168.55.192  
	x-forwarded-host=a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com  
	x-forwarded-path=/bar  
	x-forwarded-port=80  
	x-forwarded-prefix=/bar  
	x-forwarded-proto=http  
	x-real-ip=192.168.55.192  

Request Body:
	-no body in request-
```

#### Results

A response with  HTTP/1.1 200 OK proxied Via: kong/3.x for both requests indicates the ingress rule is configured.



#### Add ingress resource for httpbin service
Let's add an Ingress resource which proxies requests to  /baz to the httpbin service. 

We will use this path later.

**NOTE** This is the new syntax for Kubernetes version 1.22 onwards

```bash
echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-2
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /baz
        pathType: Prefix
        backend:
          service:
            name: httpbin
            port: 
              number: 80
' | kubectl apply -f -
```

**Response**
```
ingress.extensions/demo-2 created
```