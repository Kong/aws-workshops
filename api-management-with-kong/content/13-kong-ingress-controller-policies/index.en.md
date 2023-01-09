---
title : "Kong Ingress Controller Policies"
weight : 130
---

####  Learding Objectives

In this chapter, we will learn

* Set up Ingress rule for Kong Ingress
* Configure a fallback service
* Configure HTTPS redirect for services
* Use Redis for rate-limiting


We will use the sample application installed in the previous module.We will achieve this by using following Kong plugins.

* Proxy Caching plugin: it caches and serves commonly requested responses in Kong
* Rate Limiting plugin: it limits how many HTTP requests can be made in a given period of seconds, minutes, hours, days, months, or years. We're going to define a basic 3-request a minute policy
* Key Authentication plugin: also sometimes referred to as an API key, controls the consumers sending requests to the Gateway.

