---
title: "Kong and AWS Cognito"
chapter: false
weight: 70
---

## Kong OpenId Connect plugin and AWS Cognito

For Enterprise class applications it's highly recommended to externalize the Authentication processes to a specific component called Identity Provider (IdP)

From this perspectivie, IdP are typically responsible for several capabilities:

* User and Application Authentication
* Tokenization
* Multi-factor Authentication
* Credential databases abstraction


The integration between the API Gateway and Identity Provider is implemented with the OpenId Connect standard. You can learn more about it here: https://openid.net/connect/

This section explores such integration with Kong Enterprise through OIDC plugin and AWS Cognito implementing a basic OIDC Authorization Code Grant.