---
title : "HTTP Redirects"
weight : 136
---

This guide walks through how to configure Kong Ingress Controller  to redirect HTTP request to HTTPS so that all communication from the external world to your APIs and micro services is encrypted.

#### Add ingress resource for httpbin service

Add an Ingress rule to proxy requests  to /foo-redirect to the httpbin  service

```bash
echo '
apiVersion: networking.k8s.io/v1
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
ingress.extensions/demo-redirect created
```

**Verify**

Test the Ingress rule:

```bash
curl -i  $DATA_PLANE_LB/foo-redirect/status/200
```

**Response**
```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: keep-alive
Server: gunicorn/19.9.0
Date: Thu, 05 Jan 2023 13:58:27 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 0
Via: kong/3.1.1.1-enterprise-edition
```

#### Set up HTTPs redirect

Create a KongIngress resource which will enforce a policy on Kong to accept only HTTPS requests for the above Ingress rule and send back a redirect if the request matches the Ingress rule.

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
    name: demo-redirect
route:
  protocols:
  - https
  https_redirect_status_code: 302
' | kubectl apply -f -
```


**Response**

```
kongingress.configuration.konghq.com/https-only created
```


#### Associate the KongIngress resource 

Associate the KongIngress resource with the Ingress resource you created for the service.

```bash
kubectl patch ingress demo-redirect -p '{"metadata":{"annotations":{"konghq.com/override":"https-only"}}}'
```

**Response**

```
ingress.extensions/demo patched
```

#### Test it

Make a plain-text HTTP request to Kong.  

```bash
curl $DATA_PLANE_LB/foo-redirect/headers -I
```

**Response**

```bash
HTTP/1.1 302 Moved Temporarily
Date: Thu, 05 Jan 2023 13:59:26 GMT
Content-Type: text/html
Content-Length: 110
Connection: keep-alive
Location: https://a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com/foo-redirect/headers
X-Kong-Response-Latency: 0
Server: kong/3.1.1.1-enterprise-edition
```

**Results**

The results is a redirect **- 302 Moved Temporarily -**  issued from Kong as expected.

The  **Location**  header will contain the URL you need to use for an HTTPS request. 

**Please note** that this URL will be different depending on your installation method. You can also grab the IP address of the load balance  fronting Kong and send a HTTPS request to test it.


#### Verify HTTPs access

Use **location** header to access the service via HTTPS.  
Remember to replace the **Location URL** with then one above. 

```bash
curl -k <Location URL>
```

**Response**

```
{
  "headers": {
    "Accept": "*/*", 
    "Connection": "keep-alive", 
    "Host": "a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com", 
    "User-Agent": "curl/7.85.0", 
    "X-Forwarded-Host": "a217b4826c66c4bc385432eb8b87be15-1956036113.us-east-1.elb.amazonaws.com", 
    "X-Forwarded-Path": "/foo-redirect/headers", 
    "X-Forwarded-Prefix": "/foo-redirect/"
  }
}
```

#### Results
You can see that Kong correctly serves the request only on HTTPS protocol and redirects the user if plaint-text HTTP protocol is used. We had to use  `-k`  flag in cURL to skip certificate validation as the certificate served by Kong is a self-signed one. If you are serving this traffic via a domain that you control and have configured TLS properties for it, then the flag won't be necessary.


#### Cleanup

Delete the Kong plugin by running following command. Cleanup ensures that this plugin does not interferes with any other modules in the workshop for demo purposes and each workshop module code continues to function indepdently.

```bash
kubectl delete ingress demo-redirect
kubectl delete kongingress demo-redirect
```

In real world scenario, you can enable as many plugins as you like depending on your use cases.