---
title: "AWS Setup for Hosting Kong"
chapter: true
draft: false
weight: 3
---

# Self-Paced Workshop

Welcome to the Self Guided Setup section! This workshop requires an AWS account where there is IAM user/identity that has proper permissions to set up the necessary AWS components to work through the workshop. Worried about costs associated with this workshop? Don't worry, go to the next page and request some AWS credits to pay for any costs that may be incurred through this workshop!

Here is a preview of what we will be setting up:

1. Creating an AWS account with proper permissions
1. Requesting AWS credit from AWS Marketplace


# Kong Konnect Enterprise Hybrid Mode
One of the most powerful capabilities provided by Kong Konnect Enterprise is the support for Hybrid deployments. In other words, it implements distributed API Gateway Clusters with multiple instances running on several environments at the same time.

Moreover, Kong Konnect Enterprise provides a new topology option, named Hybrid Mode, with a total separation of the Control Plane (CP) and Data Plane (DP). That is, while the Control Plane is responsible for administration tasks, the Data Plane is exclusively used by API Consumers.

Please, refer to the following link to read more about the Hybrid deployment: https://docs.konghq.com/enterprise/2.4.x/deployment/hybrid-mode/

# Reference Architecture
Here's a Reference Architecture implemented in AWS:

![kong](/images/ref_arch.png)

* Both Control Plane and Data Plane run on an Elastic Kubernetes Service (EKS) Cluster in different namespaces.
* PostgreSQL Database is located behind the CP.

Considering the capabilities provided by the Kubernetes platform, running Data Planes on this platform delivers a powerful environment. Here are some capabilities leveraged by the Data Plane on Kubernetes:

*    High Availability: One of the main Kubernetes' capabilities is "Self-Healing". If a "pod" crashes, Kubernetes takes care of it, reinitializing the "pod".

*    Scalability/Elasticity: HPA ("Horizontal Pod Autoscaler") is the capability to initialize and terminate "pod" replicas based on previously defined policies. The policies define "thresholds" to tell Kubernetes the conditions where it should initiate a brand new "pod" replica or terminate a running one.

*     Load Balancing: The Kubernetes Service notion defines an abstraction level on top of the "pod" replicas that might have been up or down (due HPA policies, for instance). Kubernetes keeps all the "pod" replicas hidden from the "callers" through Services.



<b>Important remark #1</b>: this tutorial is intended to be used for labs and PoC only. There are many aspects and processes, typically implemented in production sites, not described here. For example: Digital Certificate issuing, Cluster monitoring, etc.

<b>Important remark #2</b>: the deployment is based on Kong Enterprise 2.4 running on "Free Mode". Please contact Kong to get a Kong Enterprise trial license to use its Enterprise features.