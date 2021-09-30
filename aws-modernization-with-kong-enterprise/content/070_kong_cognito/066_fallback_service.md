---
title: "Configuring a fallback service"
chapter: true
draft: false
weight: 6
---


# Configuring a fallback service

In this learning lab, you will learn how to setup a fallback service using Ingress resource. The fallback service will receive all requests that don't match against any of the defined Ingress rules. 

This can be useful for scenarios where you would like to return a 404 page to the end user if the user clicks on a dead link or inputs an incorrect URL.


## Create the Ingress
We're going to create an Ingress for the Echo Service we deployed previously
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
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
      - path: /cafe
        backend:
          serviceName: echo
          servicePort: 80
EOF
```


## Consume the Ingress
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/cafe/status/200
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:00:59 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 1

Hostname: echo-5fc5b5bc84-vzskb

Pod Information:
	node name:	ip-192-168-29-188.eu-central-1.compute.internal
	pod name:	echo-5fc5b5bc84-vzskb
	pod namespace:	default
	pod IP:	192.168.22.59

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.4.240
	method=GET
	real path=/status/200
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com:8080/status/200

Request Headers:
	accept=*/*  
	accept-encoding=gzip, deflate  
	connection=keep-alive  
	host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	user-agent=HTTPie/2.4.0  
	x-forwarded-for=192.168.29.188  
	x-forwarded-host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	x-forwarded-path=/cafe/status/200  
	x-forwarded-port=80  
	x-forwarded-prefix=/cafe  
	x-forwarded-proto=http  
	x-real-ip=192.168.29.188  

Request Body:
	-no body in request-
```

## Create a Fallback Service
```
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fallback-svc
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fallback-svc
  template:
    metadata:
      labels:
        app: fallback-svc
    spec:
      containers:
      - name: fallback-svc
        image: hashicorp/http-echo
        args:
        - "-text"
        - "This is not the path you are looking for. - Fallback service"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: fallback-svc
  labels:
    app: fallback-svc
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 5678
    protocol: TCP
    name: http
  selector:
    app: fallback-svc
EOF
```

## Create the KongIngress rule
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: fallback
  annotations:
    kubernetes.io/ingress.class: kong
spec:
  backend:
    serviceName: fallback-svc
    servicePort: 80
EOF
```


## Consume the Ingress again
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/asdasd
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 61
Content-Type: text/plain; charset=utf-8
Date: Fri, 09 Jul 2021 12:06:54 GMT
Via: kong/2.4.1.1-enterprise-edition
X-App-Name: http-echo
X-App-Version: 0.2.3
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 0

This is not the path you are looking for. - Fallback service
```

Delete the Ingress and Rule
```
kubectl delete ingress demo fallback
kubectl delete deployment fallback-svc
kubectl delete service fallback-svc
```
