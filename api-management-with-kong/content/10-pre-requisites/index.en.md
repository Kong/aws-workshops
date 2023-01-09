---
title : "Pre-Requisites"
weight : 100
---

* Each Section should include a small introduction and learning objectives

* Sectional contents similar to https://github.com/aws-samples/aws-modernization-with-kong/tree/master/content/pre-requsites

* Use AWS Command Shell instead of Cloud9 in instructions

* Replace https://github.com/aws-samples/aws-modernization-with-kong/tree/master/content/pre-requsites/kong-enterprise-license with Konnect sign up (dont include data plane setup)





This chapter will walk you through the pre-requisites.

## AWS Account

You will need a AWS account to begin with.

During a hosted event such as re\:Invent, Kubecon, Immersion Day, or any other event hosted by  AWS or Kong, you will be provided temporary AWS account. 

If you are NOT in a hosted event, you can also execute this workshop in your organization's AWS Account. 

If you are NOT a part of any organization yet, and dont have an AWS account yet, sign up for one as described [here](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)


## Kong Enterprise License

You will need Kong Enterprise License to execute this workshop.

During a hosted event such as re\:Invent, Kubecon, Immersion Day, or any other event hosted by  AWS or Kong, you will be provided with a temporary License for Kong Enterprise.

If you are NOT in a hosted event, you can get a Kong Enterprise License by contacting Kong Sales [here](https://konghq.com/contact-sales/)

If you DONT supply Kong Enterprise License keys , you may not be able to use all the modules of the workshop as some features will be disabled.


## Command Line Utilities

In this workshop, we will use the following command line utilities

* eksctl (we will install this in subsequent section)
* kubectl (we will install this in subsequent section)
* curl (pre-installed)
* jq (we will install this in subsequent section)

In the instructor led workshop, we will create and use [AWS Cloud9](https://aws.amazon.com/cloud9/) as an integrated development environment (IDE) that lets you write, run, and debug your code with just a browser. 

If you are running the workshop on your own and want to use the IDE of your choice, please ensure the command line utilities mentioned above are installed as the subsequent sections use it in instructions.


## Amazon Elastic Kubernetes Cluster (EKS)

Subsequent section will walk you through the instructions