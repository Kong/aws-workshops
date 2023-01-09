---
title : "Fallback service"
weight : 135
---

In this learning lab,  you will learn how to setup a fallback service using Ingress resource. The fallback service will receive all requests that don't match against any of the defined Ingress rules. 

This can be useful for scenarios where you would like to return a 404 page to the end user if the user clicks on a dead link or inputs an incorrect URL.

#### Set up Ingress rule

Add ingress resource for echo  service
Add an Ingress resource which proxies requests to and /cafe to the echo service

```bash
echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-fallback
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /cafe
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

**Verify**

Test the Ingress rule:

```bash
curl -i $DATA_PLANE_LB/cafe/status/200
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
Date: Thu, 05 Jan 2023 13:47:12 GMT
Server: echoserver
X-Kong-Upstream-Latency: 0
X-Kong-Proxy-Latency: 1
Via: kong/3.1.1.1-enterprise-edition



Hostname: echo-744d654d7b-4tkss

Pod Information:
	node name:	ip-192-168-55-192.ec2.internal
	pod name:	echo-744d654d7b-4tkss
	pod namespace:	default
	pod IP:	192.168.46.42

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.63.254
	method=GET
	real path=/status/200
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com:8080/status/200

Request Headers:
	accept=*/*  
	connection=keep-alive  
	host=a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com  
	user-agent=curl/7.85.0  
	x-forwarded-for=192.168.55.192  
	x-forwarded-host=a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com  
	x-forwarded-path=/cafe/status/200  
	x-forwarded-port=80  
	x-forwarded-prefix=/cafe/  
	x-forwarded-proto=http  
	x-real-ip=192.168.55.192  

Request Body:
	-no body in request-
```


#### Create a fallback sample service.

Add a KongPlugin resource for the fallback service

```bash
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

#### Create ingress rule

Set up an Ingress rule to make it the fallback service to send all requests to it that don't match any of our Ingress rules:

```bash
echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fallback
  annotations:
spec:
  ingressClassName: kong
  defaultBackend:
    service:
      name: fallback-svc
      port:
        number: 80
' | kubectl apply -f -
```



**Response**

```
ingress.extensions/fallback created
```

#### Verify fallback service

Now send a request with a request property that doesn't match against any of the defined rules:

```bash
curl $DATA_PLANE_LB/random-path
```

**Response**

```
This is not the path you are looking for. - Fallback service
```

#### Conclusion
Since the request is not part of any defined rule, the fallback service responds with **'This is not the path you are looking for. - Fallback service'**. 


#### Cleanup

Delete the Kong plugin by running following command. Cleanup ensures that this plugin does not interferes with any other modules in the workshop for demo purposes and each workshop module code continues to function indepdently.

```bash
kubectl delete ingress fallback
kubectl delete service fallback-svc
kubectl delete deployment fallback-svc
```

In real world scenario, you can enable as many plugins as you like depending on your use cases.