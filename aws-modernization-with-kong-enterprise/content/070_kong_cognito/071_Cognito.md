---
title: "AWS Cognito"
chapter: true
draft: false
weight: 1
---



# Creating AWS Cognito
First of all, let's create a Cognito instance using the AWS Console


Create Cognito instance using GUI
Go to Cognito console and click on "Managed User Pools" and on "Create a user pool".

Name your pool as "kongpool" and click on "Step through settings".
Select “Email address or phone number” and, under that, select “Allow email addresses”.
Select the following standard attributes as required
email
family name
given name
Click on "Next step".
For the next pages, "Policies", “MFA and verifications”, “Message customizations” and "Tags", click on "Next step".
In the page "Devices", select “No” for “Do you want to remember your user’s devices” and click on “Next step”.
In the pages "App clients" and "Triggers" click on "Next step".
In the page "Review" click on "Create pool". Take note of the "Pool Id", in our case "us-west-2_4K1BOZQWP".







Application Definition
Click on "App clients" left menu option.
Click on "Add an app client" and enter with the following data:
App client name: kong-api
Refresh token expiration (days): 30
Generate client secret: on
Enable lambda trigger based custom authentication (ALLOW_CUSTOM_AUTH): off
Enable username password based authentication (ALLOW_USER_PASSWORD_AUTH): on
Enable SRP (secure remote password) protocol based authentication (ALLOW_USER_SRP_AUTH): off
Click on "Set attribute read and write permissions"
Uncheck everything except the "email", "family name" and "given name" fields.


Click on "Create app client" and on "Show details"



Take note of the "App client id". In our case, "64m9fjg2p11a988rf9co7vs4a4"
Click on "Details" and take note of the "App client secret". In our case, "dhvrs6csdvkng34bgtmaietqpgfgnp4a0e7hpl9oim5so2r3bf3"







Test the Cognito Endpoint
http --form post https://kongdomain.auth.us-west-2.amazoncognito.com/oauth2/token \
 'grant_type'='client_credentials' \
 'client_id'='5vn857qpcdsoe8eu5hrs7j4pce' \
 'client_secret'='euvj0i44kjv77oelnkeur1bem3qngqhrjubm8nctnhn7jc81e5n' \
 'scope'='http://kongresource/scope1' \
 Content-Type:'application/x-www-form-urlencoded'


curl -X POST --user 5vn857qpcdsoe8eu5hrs7j4pce:euvj0i44kjv77oelnkeur1bem3qngqhrjubm8nctnhn7jc81e5n 'https://kongdomain.auth.us-west-2.amazoncognito.com/oauth2/token?grant_type=client_credentials' -H 'Content-Type: application/x-www-form-urlencoded'

echo -n 5vn857qpcdsoe8eu5hrs7j4pce:euvj0i44kjv77oelnkeur1bem3qngqhrjubm8nctnhn7jc81e5n | base64
NXZuODU3cXBjZHNvZThldTVocnM3ajRwY2U6ZXV2ajBpNDRranY3N29lbG5rZXVyMWJlbTNxbmdxaHJqdWJtOG5jdG5objdqYzgxZTVu


http --form POST https://kongdomain.auth.us-west-2.amazoncognito.com/oauth2/token \
 'grant_type'='client_credentials' \
 Authorization:'Basic NXZuODU3cXBjZHNvZThldTVocnM3ajRwY2U6ZXV2ajBpNDRranY3N29lbG5rZXVyMWJlbTNxbmdxaHJqdWJtOG5jdG5objdqYzgxZTVu' \
 Content-Type:'application/x-www-form-urlencoded'


Create Kong Service and Route
http aafd3df15b5424a5b8ba77ee8d4d9e4e-589123764.us-west-2.elb.amazonaws.com:8001/services name=oidcservice url='http://httpbin.org'

http aafd3df15b5424a5b8ba77ee8d4d9e4e-589123764.us-west-2.elb.amazonaws.com:8001/services/oidcservice/routes name='oidcroute' paths:='["/oidcroute"]'

http 54.189.150.239:30144/oidcroute/get


Apply the OIDC plugin
http post aafd3df15b5424a5b8ba77ee8d4d9e4e-589123764.us-west-2.elb.amazonaws.com:8001/routes/oidcroute/plugins name=openid-connect config:='{"issuer": "https://cognito-idp.us-west-2.amazonaws.com/us-west-2_CG7aNyg9L/.well-known/openid-configuration", "client_id": ["5vn857qpcdsoe8eu5hrs7j4pce"], "client_secret": ["euvj0i44kjv77oelnkeur1bem3qngqhrjubm8nctnhn7jc81e5n"], "scopes": ["http://kongresource/scope1"], "ssl_verify": false }'

http 54.189.150.239:30144/oidcroute/get


http 54.189.150.239:30144/oidcroute/get -a 5vn857qpcdsoe8eu5hrs7j4pce:euvj0i44kjv77oelnkeur1bem3qngqhrjubm8nctnhn7jc81e5n


Observations:
The issuer URL follows the format: https://cognito-idp.{region}.amazonaws.com/{userPoolId}```

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
