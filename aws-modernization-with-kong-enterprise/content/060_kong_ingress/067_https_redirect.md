---
title: "HTTP/S Redirect"
chapter: true
draft: false
weight: 7
---


# HTTP/S Redirect

This guide walks through how to configure Kong Ingress Controller to redirect HTTP request to HTTPS so that all communication from the external world to your APIs and micro services is encrypted.


## Create the Ingress
We're going to create an Ingress for the Echo Service we deployed previously
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-redirect
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /foo-redirect
        backend:
          serviceName: echo
          servicePort: 80
EOF
```

## Consume the Ingress
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redirect/status/200
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:13:52 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 4
X-Kong-Upstream-Latency: 0

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
	x-forwarded-path=/foo-redirect/status/200  
	x-forwarded-port=80  
	x-forwarded-prefix=/foo-redirect  
	x-forwarded-proto=http  
	x-real-ip=192.168.29.188  

Request Body:
	-no body in request-
```

## Set up HTTP/S redirect
```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
    name: demo-redirect
route:
  protocols:
  - https
  https_redirect_status_code: 302
EOF
```


## Consume the Ingress again
```
$ http a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redirect/headers
HTTP/1.1 302 Moved Temporarily
Connection: keep-alive
Content-Length: 110
Content-Type: text/html
Date: Fri, 09 Jul 2021 12:15:38 GMT
Location: https://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redirect/headers
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 1

<html>
<head><title>302 Found</title></head>
<body>
<center><h1>302 Found</h1></center>
</body>
</html>
```
The results is a redirect - 302 Moved Temporarily - issued from Kong as expected.

The  Location  header will contain the URL you need to use for an HTTPS request. 

Please note that this URL will be different depending on your installation method. You can also grab the IP address of the load balance  fronting Kong and send a HTTPS request to test it.

Use location header to access the service via HTTPS.  
Remember to replace the Location URL with then one above. 

```
$ http --verify=no https://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com/foo-redirect/headers
HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: text/plain; charset=UTF-8
Date: Fri, 09 Jul 2021 12:19:17 GMT
Server: echoserver
Transfer-Encoding: chunked
Via: kong/2.4.1.1-enterprise-edition
X-Kong-Proxy-Latency: 0
X-Kong-Upstream-Latency: 0

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
	real path=/headers
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com:8080/headers

Request Headers:
	accept=*/*  
	accept-encoding=gzip, deflate  
	connection=keep-alive  
	host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	user-agent=HTTPie/2.4.0  
	x-forwarded-for=192.168.29.188  
	x-forwarded-host=a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com  
	x-forwarded-path=/foo-redirect/headers  
	x-forwarded-port=443  
	x-forwarded-prefix=/foo-redirect  
	x-forwarded-proto=https  
	x-real-ip=192.168.29.188  

Request Body:
	-no body in request-
```




Delete the Ingress and Rule
```
kubectl delete ingress demo-redirect
kubectl delete kongingress demo-redirect
```
