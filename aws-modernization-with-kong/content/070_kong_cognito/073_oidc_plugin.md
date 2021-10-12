---
title: "OpenId Connect Plugin"
chapter: true
draft: false
weight: 3
---



## Instantiating an OIDC plugin

```
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: oidc
  namespace: default
config:
  client_id: [2pncij68oab2v848bu9682tc9e]
  client_secret: [do88btsf6thn7jg3i1glr43nc7eparuv9p13ap5ecfpujumug77]
  issuer: "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_PNNirRUle/.well-known/openid-configuration"
  cache_ttl: 10
  redirect_uri: ["https://a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com/sampleroute/hello"]
plugin: openid-connect
EOF
```

Observations:

* The issuer URL follows the format: https://cognito-idp.{region}.amazonaws.com/{userPoolId}
OIDC plugin generates, by default the "redirect uri" based on its port (8443).
* The "redirect_uri" parameter defines the URI to be used to redirect the user after getting authenticated. 


## Apply OIDC plugin to the Ingress
<pre>
kubectl patch ingress sampleroute -p '{"metadata":{"annotations":{"konghq.com/plugins":"oidc"}}}'
ingress.extensions/httpbin patched
</pre>

if you want to disable the plugin run:
<pre>
kubectl annotate ingress sampleroute konghq.com/plugins-
</pre>


## Consume the Route with a Browser
https://a946e3cab079a49a1b6661ab62d5585f-2135097986.us-east-1.elb.amazonaws.com/sampleroute/hello


After accepting the Server Certificate, sInce you haven't been authenticated, you will be redirected to Cognito's Authentication page:

![cognito7](/images/cognito7.png)


Click on "Sign up" to register.

![cognito8](/images/cognito8.png)



After entering your data click on "Sign Up". Cognito will create a user and request the verification code sent by your email.


After typing the code, Cognito will authenticate you, issues an Authorization Code and redirects you back to the original URL (Data Plane). The Data Plane connects to Cognito with the Authorization Code to get the Access Token and then allows you to consume the URL.

![cognito9](/images/cognito9.png)
