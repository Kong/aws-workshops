---
title: "Kong Ingress Controller Policies"
chapter: false
weight: 60
---

## Kong Ingress Controller Policies

Since we have an sample application deployed and an Ingress exposing it, it's time to control such exposure.

To get started, we're going to use three fundamental plugins provided by Kong:

* Proxy Caching plugin: it caches and serves commonly requested responses in Kong

* Rate Limiting plugin: it limits how many HTTP requests can be made in a given period of seconds, minutes, hours, days, months, or years. We're going to define a basic 3-request a minute policy

* Key Authentication plugin: also sometimes referred to as an API key, controls the consumers sending requests to the Gateway.

Feel free to change the policies used and experiment further implementing policies like caching OIDC-based authentication, canary, GraphQL integration, and more with the extensive list of plugins provided by Kong. Check the list over here: https://docs.konghq.com/hub/


Then we're going to apply other policies to our previously created Ingress

* Set up Ingress rule for Kong Ingress

* Configuring a fallback service

* Configuring HTTPS redirect for services

* Using Redis for rate-limiting

