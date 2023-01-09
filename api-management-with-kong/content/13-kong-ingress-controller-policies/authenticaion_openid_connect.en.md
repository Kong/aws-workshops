---
title : "Authentication-OpenID Connect"
weight : 137
---

[OpenID Connect plugin](https://docs.konghq.com/hub/kong-inc/openid-connect/) allows the integration with a 3rd party identity provider (IdP) in a standardized way. This plugin can be used to implement Kong as a (proxying) [OAuth 2.0](https://tools.ietf.org/html/rfc6749) resource server (RS) and/or as an OpenID Connect relying party (RP) between the client, and the upstream service.

The plugin supports several types of credentials and grants:

* Signed JWT access tokens (JWS)
* Opaque access tokens
* Refresh tokens
* Authorization code
* Username and password
* Client credentials
* Session cookies

In this workshop, we will configure this plugin to use [Amazon Cognito](https://aws.amazon.com/cognito/) . A detailed integration guide is available [here](https://docs.konghq.com/gateway/latest/kong-plugins/authentication/oidc/cognito/) for future reading.

#### Creating AWS Cognito

Run the following command to create the AWS Cognito Resources using a CloudFormation templates

```bash
curl -O https://raw.githubusercontent.com/aws-samples/aws-modernization-with-kong/master/templates/cognito.yaml
aws cloudformation  deploy --template-file cognito.yaml --stack-name cognito-$C9_PID \
--parameter-overrides ClientName=$C9_PID-client Domain=$C9_PID PoolName=$C9_PID-pool CallBackUrl=https://$DATA_PLANE_LB/bar
echo "export COGNITO_CLIENT_ID=$(aws cloudformation describe-stack-resources --stack-name cognito-$C9_PID | jq -r '.StackResources[] | select(.ResourceType=="AWS::Cognito::UserPoolClient") | .PhysicalResourceId')" >> ~/.bashrc
bash
echo "export COGNITO_POOL_ID=$(aws cloudformation describe-stack-resources --stack-name cognito-$C9_PID | jq -r '.StackResources[] | select(.ResourceType=="AWS::Cognito::UserPool") | .PhysicalResourceId')" >> ~/.bashrc
bash
echo "ISSUER=https://cognito-idp.$AWS_REGION.amazonaws.com/$COGNITO_POOL_ID/.well-known/openid-configuration" >> ~/.bashrc
bash
```

**NOTE** We are using `$C9_PID` environment variable in the above commands, so that each cognito pool created by users of this workshop is unique. If you are running this workshop at your own cadance without AWS Cloud9 environment, ensure to set this environment variable

Fetch the client secret

```bash
echo "export CLIENT_SECRET=$(aws cognito-idp describe-user-pool-client --user-pool-id $COGNITO_POOL_ID --client-id $COGNITO_CLIENT_ID --query 'UserPoolClient.ClientSecret')" >> ~/.bashrc
bash
```
#### Installing OIDC Plugin

```bash
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: oidc
  namespace: default
config:
  client_id: [$COGNITO_CLIENT_ID]
  client_secret: [$CLIENT_SECRET]
  issuer: "$ISSUER"
  cache_ttl: 10
  redirect_uri: ["https://$DATA_PLANE_LB/bar"]
plugin: openid-connect
EOF
```

#### Apply OIDC plugin to the Ingress

```bash
kubectl patch ingress demo -p '{"metadata":{"annotations":{"konghq.com/plugins":"oidc"}}}'
```
#### Verification

Copy output of `echo https://$DATA_PLANE_LB/bar` and paste in browser.

After accepting the Server Certificate, since you haven't been authenticated, you will be redirected to Cognito's Authentication page:

![cognito7](/static/images/cognito7.png)


Click on "Sign up" to register.

![cognito8](/static/images/cognito8.png)


After entering your data click on "Sign Up". Cognito will create a user and request the verification code sent by your email.


After typing the code, Cognito will authenticate you, issues an Authorization Code and redirects you back to the original URL (Data Plane). The Data Plane connects to Cognito with the Authorization Code to get the Access Token and then allows you to consume the URL.


#### Cleanup

Delete the Kong plugin by running following command. Cleanup ensures that this plugin does not interferes with any other modules in the workshop for demo purposes and each workshop module code continues to function indepdently.

```bash
kubectl delete kongplugin oidc
aws cloudformation delete-stack --stack-name cognito-$C9_PID
```

In real world scenario, you can enable as many plugins as you like depending on your use cases.