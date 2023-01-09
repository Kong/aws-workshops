---
title : "Key Authentication"
weight : 133
---

Add key authentication (also sometimes referred to as an API key) to a Service or a Route. Consumers then add their API key either in a query string parameter, a header, or a request body to authenticate their requests.

For more details, refer [Key Authentication plugin](https://docs.konghq.com/hub/kong-inc/key-auth/).

In this section, you will configure the  Key-Auth  plugin on a service resource. Specifically, you will configure Kong to require requests to the httpbin service to authenticate using an API key.

#### Add Kong Key Authentication plugin
Add a KongPlugin resource for authentication, specifically the key-auth plugin

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: httpbin-auth
plugin: key-auth
' | kubectl apply -f -
```


**Response**

```
kongplugin.configuration.konghq.com/httpbin-auth created
```

#### Associate plugin to service
Associate key-auth plugin to the service httpbin running in the cluster. Apply  this patch. 

```bash
kubectl patch service httpbin -p '{"metadata":{"annotations":{"konghq.com/plugins":"httpbin-auth"}}}'
```

**Response**

```
service/httpbin patched
```

#### Verify authentication is required
Send a request to the httpbin service, via the endpoints  /baz and /foo.  It now requires authentication, no matter which ingress rule it matches. 

**Request 1**

```bash
curl -I $DATA_PLANE_LB/baz
```

**Response**

```
HTTP/1.1 401 Unauthorized
Date: Thu, 05 Jan 2023 13:33:13 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
WWW-Authenticate: Key realm="kong"
Content-Length: 45
X-Kong-Response-Latency: 0
Server: kong/3.1.1.1-enterprise-edition
```


**Request 2**

```
curl -I $DATA_PLANE_LB/foo
```

**Response**

```
HTTP/1.1 401 Unauthorized
Date: Thu, 05 Jan 2023 13:33:45 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
WWW-Authenticate: Key realm="kong"
Content-Length: 45
demo:  injected-by-kong
X-Kong-Response-Latency: 1
Server: kong/3.1.1.1-enterprise-edition
```

**Results**

For both requests, the response is a HTTP/1.1 401 Unauthorized. The httpbin service requires authentication. 

Notice in the last request the header "demo: injected-by-kong" is injected. This request also matches one of the rules defined in the demo ingress resource (previously configured). 

Now you will configure KongConsumer and KongCredential resources to provision. These resources can be used to provision Consumers and associated credentials in Kong.

Specifically, you will configure a KongConsumer: **harry** with a key: **my-sooper-secret-key**. 

#### Create a KongConsumer
Create a KongConsumer resource

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: harry
  annotations:
    kubernetes.io/ingress.class: kong
username: harry
' | kubectl apply -f -
```


**Response**

```
kongconsumer.configuration.konghq.com/harry created
```

#### Create a Secret resource with an API-key inside it

Create a Secret resource with an API-key inside it. Specify to include:
1. The type of credential as key-auth
2. The API key using the key configuration value e.g. my-sooper-secret-key

```bash
kubectl create secret generic harry-apikey  \
  --from-literal=kongCredType=key-auth  \
  --from-literal=key=my-sooper-secret-key
```

**Response**

```
secret/harry-apikey created
```

The type of credential is specified via kongCredType. You can create the Secret using any other method as well.

Since we are using the Secret resource, Kubernetes will encrypt and store this API-key for us.

#### Associate API-key with the Consumer

Next, associate this API-key with the consumer we created previously.

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongConsumer
metadata:
  name: harry
  annotations:
    kubernetes.io/ingress.class: kong
username: harry
credentials:
- harry-apikey
' | kubectl apply -f -
```

Please note that we are not re-creating the KongConsumer resource but only updating it to add the credentials array:

**Response**

```
kongconsumer.configuration.konghq.com/harry configured
```

#### Verify API key

Use the apikey to pass authentication to access the services.

**Request 1**

```bash
curl -I $DATA_PLANE_LB/foo -H 'apikey: my-sooper-secret-key'
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 9593
Connection: keep-alive
Server: gunicorn/19.9.0
Date: Thu, 05 Jan 2023 13:34:43 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
demo:  injected-by-kong
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/3.1.1.1-enterprise-edition
```
**Request 2**

```bash
curl -I $DATA_PLANE_LB/baz -H 'apikey: my-sooper-secret-key'
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 9593
Connection: keep-alive
Server: gunicorn/19.9.0
Date: Thu, 05 Jan 2023 13:35:15 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 2
X-Kong-Proxy-Latency: 0
Via: kong/3.1.1.1-enterprise-edition
```

**Results**

Both requests should now respond with a  **HTTP/1.1 200 OK**.

The apikey: my-sooper-secret-key associated with the consumer: harry passes the authentication imposed by Kong on httpbin service.  

Notice the Access-Control-Allow-Credentials: true response that indicates this. 


#### Conclusion

You have leveraged the key-authentication plugin in Kong and provisioned a consumer with credentials. This enables you to offload authentication into your Ingress layer and keeps the application logic simple.

All other authentication plugins bundled with Kong work in this way and can be used to quickly add an authentication layer on top of your microservices

#### Cleanup

Delete the Kong plugin by running following command. Cleanup ensures that this plugin does not interferes with any other modules in the workshop for demo purposes and each workshop module code continues to function indepdently.

```bash
kubectl delete kongplugin httpbin-auth
```

In real world scenario, you can enable as many plugins as you like depending on your use cases.