+++
title = "Learning Objectives"
chapter = true
weight = 10
pre = "<b>1. </b>"
+++

Today we are going to learn the following topics:

* Kong Konnect - An end-to-end SaaS API lifecycle management platform that is designed for the cloud native era and provides the easiest way to get started with Kong Gateway. The global control plane is hosted in the cloud by Kong, while the runtime engine, Kong Gateway, runs within your preferred network environment.
* Kong Gateway - A lightweight API Gateway that lets you secure, manage, and extend APIs and microservices.
* Provision and Configure Kong Gateway in Hybrid Mode in Amazon Elastic Kubernetes Service (EKS)
* Configure telemetry using Prometheus, Grafana, AWS CloudWatch and elasticity
* Use a sample application to expose and learn about Kong Ingress controller policies
    * Rate Limiting using Redis
    * Key Authentication
    * Integrating Kong with AWS Cognito using OpenID connect provider
    * Response transformation
    * Fallback Services
    * HTTP redirects

# Workshop Structure

This workshop is broken into the sections list below.  Estimated time for completing the workshop is 2 hours.

1. Pre-Requisite Environment Setup (10 minutes)
1. Provision Amazon EKS Cluster (15 minutes)
1. Architectural Walkthrough (15 minutes), while we wait for EKS Cluster to get created.
1. Kong Enterprise Setup (30 min)
1. Kong Ingress Controller Policies (40 minutes)
1. Observability (20 minutes)
1. Next Steps and Cleanup (5 min)