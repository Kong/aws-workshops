---
title : "Kong Enterprise Setup"
weight : 110
---

* Each Section should include a small introduction and learning objectives

* Data plane setup with EKS (Section)
* Data plane setup with ECS (Section), not required for MVP. Should be independelty executable



#### Kong Enterprise Hybrid Mode

One of the most powerful capabilities provided by Kong  Enterprise is the support for Hybrid deployments. In other words, it implements distributed API Gateway Clusters with multiple instances running on several environments at the same time.

Moreover, Kong Gateway Enterprise provides a new topology option, named Hybrid Mode, with a total separation of the Control Plane (CP) and Data Plane (DP). That is, while the Control Plane is responsible for administration tasks, the Data Plane is exclusively used by API Consumers.

Please, refer to the following link to read more about the [Hybrid deployment](https://docs.konghq.com/gateway/latest/production/deployment-topologies/hybrid-mode/)


#### Reference Architecture

Here's a Reference Architecture that will be implemented in this workshop:

![kong](/static/images/ref_arch.png)

* Both Control Plane and Data Plane run on an Elastic Kubernetes Service (EKS) Cluster in different namespaces.
* PostgreSQL Database is located behind the CP and is deployed in the same namespace as the CP. The database is used as the CP metadata repository and it is required for some specific Kong Gateway Enterprise capabilities such as Kong Developer Portal, Kong Vitals, etc. For production-ready deployments we recommend consuming and external [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/) infrastructure.
* Kong Data Planes do not require a database as they are connected to the Kong Control Plane.

Considering the capabilities provided by the Kubernetes platform, running Data Planes on this platform delivers a powerful environment. Here are some capabilities leveraged by the Data Plane on Kubernetes:

* High Availability: One of the main Kubernetes' capabilities is "Self-Healing". If a "pod" crashes, Kubernetes takes care of it, reinitializing the "pod".

* Scalability/Elasticity: HPA ("Horizontal Pod Autoscaler") is the capability to initialize and terminate "pod" replicas based on previously defined policies. The policies define "thresholds" to tell Kubernetes the conditions where it should initiate a brand new "pod" replica or terminate a running one.

* Load Balancing: The Kubernetes Service notion defines an abstraction level on top of the "pod" replicas that might have been up or down (due HPA policies, for instance). Kubernetes keeps all the "pod" replicas hidden from the "callers" through Services.



This tutorial is intended to be used for labs and PoC only. There are many aspects and processes, typically implemented in production sites, not described here. For example: Digital Certificate issuing, Cluster monitoring, etc. For a production ready deployment, refer Kong on AWS CDK Constructs, available [here](https://constructs.dev/search?q=kong&offset=0)
