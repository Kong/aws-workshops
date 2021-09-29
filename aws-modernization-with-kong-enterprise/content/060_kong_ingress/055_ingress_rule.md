---
title: "Set up Ingress rule for Kong Ingress"
chapter: true
draft: false
weight: 5
---


# Set up Ingress rule for Kong Ingress

In this learning lab, you will learn how to use the KongIngress resource to control proxy behavior.

## Deploy the new Service
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: echo
  name: echo
spec:
  ports:
  - port: 8080
    name: high
    protocol: TCP
    targetPort: 8080
  - port: 80
    name: low
    protocol: TCP
    targetPort: 8080
  selector:
    app: echo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: echo
  name: echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: echo
    spec:
      containers:
      - image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
        name: echo
        ports:
        - containerPort: 8080
        env:
          - name: NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
        resources: {}
EOF
```

## Create the Ingress
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo
  annotations:
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /foo
        backend:
          serviceName: echo
          servicePort: 80
EOF
```

## Consume the Ingress
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Thu, 08 Jul 2021 23:03:41 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 1
X-Kong-Upstream-Latency: 0

Hostname: echo-5fc5b5bc84-vhs5g

Pod Information:
	node name:	ip-192-168-29-188.eu-central-1.compute.internal
	pod name:	echo-5fc5b5bc84-vhs5g
	pod namespace:	default
	pod IP:	192.168.20.213

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.4.240
	method=GET
	real path=/foo
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com:8080/foo

Request Headers:
	accept=*/*  
	accept-encoding=gzip, deflate  
	connection=keep-alive  
	host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	user-agent=HTTPie/2.4.0  
	x-forwarded-for=192.168.29.188  
	x-forwarded-host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	x-forwarded-path=/foo  
	x-forwarded-port=80  
	x-forwarded-proto=http  
	x-real-ip=192.168.29.188  

Request Body:
	-no body in request-
```

You can try POST also
```
$ http post a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Thu, 08 Jul 2021 23:03:52 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 1
X-Kong-Upstream-Latency: 0

Hostname: echo-5fc5b5bc84-r44tb

Pod Information:
	node name:	ip-192-168-29-188.eu-central-1.compute.internal
	pod name:	echo-5fc5b5bc84-r44tb
	pod namespace:	default
	pod IP:	192.168.22.59

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.4.240
	method=POST
	real path=/foo
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com:8080/foo

Request Headers:
	accept=*/*  
	accept-encoding=gzip, deflate  
	connection=keep-alive  
	content-length=0  
	host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	user-agent=HTTPie/2.4.0  
	x-forwarded-for=192.168.29.188  
	x-forwarded-host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	x-forwarded-path=/foo  
	x-forwarded-port=80  
	x-forwarded-proto=http  
	x-real-ip=192.168.29.188  

Request Body:
	-no body in request-
```

## Create the KongIngress rule
Kong can strip the path defined in the ingress rule before proxying the request to the service. This can be seen in the real <b>path=/</b> value in the response.
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
  name: sample-customization
route:
  methods:
  - GET
  strip_path: true
EOF
```

## Associate ingress resource
```
kubectl patch ingress demo -p '{"metadata":{"annotations":{"konghq.com/override":"sample-customization"}}}'
```

If you want to remove the annotation run:
```
kubectl annotate ingress demo konghq.com/override-
```

Now, Kong will proxy only GET requests on <b>/foo/baz</b> path and strip away <b>/foo</b>:

## Consume the Ingress again
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo/baz
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Thu, 08 Jul 2021 23:13:20 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 1

Hostname: echo-5fc5b5bc84-r44tb

Pod Information:
	node name:	ip-192-168-29-188.eu-central-1.compute.internal
	pod name:	echo-5fc5b5bc84-r44tb
	pod namespace:	default
	pod IP:	192.168.22.59

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.4.240
	method=GET
	real path=/baz
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com:8080/baz

Request Headers:
	accept=*/*  
	accept-encoding=gzip, deflate  
	connection=keep-alive  
	host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	user-agent=HTTPie/2.4.0  
	x-forwarded-for=192.168.29.188  
	x-forwarded-host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	x-forwarded-path=/foo/baz  
	x-forwarded-port=80  
	x-forwarded-prefix=/foo  
	x-forwarded-proto=http  
	x-real-ip=192.168.29.188  

Request Body:
	-no body in request-
```

And if we send a POST, Kong will not route your Ingress
```
$ http post a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo
HTTP/1.1 404 Not Found
Connection: keep-alive
Content-Length: 48
Content-Type: application/json; charset=utf-8
Date: Thu, 08 Jul 2021 23:13:58 GMT
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 1

{
    "message": "no Route matched with those values"
}
```

Delete the Ingress and Rule
```
kubectl delete ingress demo
kubectl delete kongingress sample-customization
```
