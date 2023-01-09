---
title : "Amazon EKS"
weight : 103
---

* Each Section should include a small introduction and learning objectives

* Sectional contents similar to https://github.com/aws-samples/aws-modernization-with-kong/tree/master/content/pre-requsites

* Use AWS Command Shell instead of Cloud9 in instructions

* Replace https://github.com/aws-samples/aws-modernization-with-kong/tree/master/content/pre-requsites/kong-enterprise-license with Konnect sign up (dont include data plane setup)





#### Create a EKS Cluster

Create a Amazon EKS Cluster by running the following command. This command will

1. Create a VPC
2. Create a EKS Cluster in that VPC
3. Add managed nodes to the EKS Cluster created
4. Update kubeconfig, so that you can run `kubectl` commands.

```bash
eksctl create cluster --name kong31 --version 1.24 --nodes 1 --with-oidc
```

**Expected Output - It will take around 15 minutes for the cluster to be created. Please note the name of the EKS cluster that is getting created and save it**
```
2023-01-03 14:24:58 [ℹ]  eksctl version 0.124.0-dev+ac917eb50.2022-12-23T08:02:24Z
2023-01-03 14:24:58 [ℹ]  using region us-east-1
2023-01-03 14:24:59 [ℹ]  setting availability zones to [us-east-1a us-east-1b]
2023-01-03 14:24:59 [ℹ]  subnets for us-east-1a - public:192.168.0.0/19 private:192.168.64.0/19
2023-01-03 14:24:59 [ℹ]  subnets for us-east-1b - public:192.168.32.0/19 private:192.168.96.0/19
2023-01-03 14:24:59 [ℹ]  nodegroup "ng-6eac87e7" will use "" [AmazonLinux2/1.24]
2023-01-03 14:24:59 [ℹ]  using Kubernetes version 1.24
2023-01-03 14:24:59 [ℹ]  creating EKS cluster "kong31" in "us-east-1" region with managed nodes
2023-01-03 14:24:59 [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
2023-01-03 14:24:59 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=kong31'
2023-01-03 14:24:59 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "kong31" in "us-east-1"
2023-01-03 14:24:59 [ℹ]  CloudWatch logging will not be enabled for cluster "kong31" in "us-east-1"
2023-01-03 14:24:59 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=us-east-1 --cluster=kong31'
2023-01-03 14:24:59 [ℹ]  
2 sequential tasks: { create cluster control plane "kong31", 
    2 sequential sub-tasks: { 
        4 sequential sub-tasks: { 
            wait for control plane to become ready,
            associate IAM OIDC provider,
            2 sequential sub-tasks: { 
                create IAM role for serviceaccount "kube-system/aws-node",
                create serviceaccount "kube-system/aws-node",
            },
            restart daemonset "kube-system/aws-node",
        },
        create managed nodegroup "ng-6eac87e7",
    } 
}
2023-01-03 14:24:59 [ℹ]  building cluster stack "eksctl-kong31-cluster"
2023-01-03 14:25:01 [ℹ]  deploying stack "eksctl-kong31-cluster"
2023-01-03 14:25:31 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:26:02 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:27:03 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:28:04 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:29:05 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:30:05 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:31:06 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:32:07 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:33:08 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:34:09 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:35:11 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:36:12 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-cluster"
2023-01-03 14:38:20 [ℹ]  building iamserviceaccount stack "eksctl-kong31-addon-iamserviceaccount-kube-system-aws-node"
2023-01-03 14:38:21 [ℹ]  deploying stack "eksctl-kong31-addon-iamserviceaccount-kube-system-aws-node"
2023-01-03 14:38:22 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-addon-iamserviceaccount-kube-system-aws-node"
2023-01-03 14:38:52 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-addon-iamserviceaccount-kube-system-aws-node"
2023-01-03 14:38:53 [ℹ]  serviceaccount "kube-system/aws-node" already exists
2023-01-03 14:38:53 [ℹ]  updated serviceaccount "kube-system/aws-node"
2023-01-03 14:38:54 [ℹ]  daemonset "kube-system/aws-node" restarted
2023-01-03 14:38:54 [ℹ]  building managed nodegroup stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:38:55 [ℹ]  deploying stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:38:55 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:39:26 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:39:59 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:41:06 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:42:28 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-nodegroup-ng-6eac87e7"
2023-01-03 14:42:28 [ℹ]  waiting for the control plane to become ready
2023-01-03 14:42:28 [✔]  saved kubeconfig as "/Users/claudioacquaviva/.kube/config"
2023-01-03 14:42:28 [ℹ]  no tasks
2023-01-03 14:42:28 [✔]  all EKS cluster resources for "kong31" have been created
2023-01-03 14:42:29 [ℹ]  nodegroup "ng-6eac87e7" has 1 node(s)
2023-01-03 14:42:29 [ℹ]  node "ip-192-168-35-145.ec2.internal" is ready
2023-01-03 14:42:29 [ℹ]  waiting for at least 1 node(s) to become ready in "ng-6eac87e7"
2023-01-03 14:42:29 [ℹ]  nodegroup "ng-6eac87e7" has 1 node(s)
2023-01-03 14:42:29 [ℹ]  node "ip-192-168-35-145.ec2.internal" is ready
2023-01-03 14:42:31 [ℹ]  kubectl command should work with "/Users/claudioacquaviva/.kube/config", try 'kubectl get nodes'
2023-01-03 14:42:31 [✔]  EKS cluster "kong31" in "us-east-1" region is ready
```



#### Amazon EBS CSI driver

Since we are going to deploy our Kong Control Plane consuming a local PostgreSQL database, running in the same Kubernetes namespace, we need to add the [Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) add-on](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) to our EKS cluster.


The Amazon EBS CSI plugin requires IAM permissions to make calls to AWS APIs on your behalf.

```
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster kong31 \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole
```

**Expected Output**

```
2023-01-04 10:43:44 [ℹ]  1 existing iamserviceaccount(s) (kube-system/aws-node) will be excluded
2023-01-04 10:43:44 [ℹ]  1 iamserviceaccount (kube-system/ebs-csi-controller-sa) was included (based on the include/exclude rules)
2023-01-04 10:43:44 [!]  serviceaccounts that exist in Kubernetes will be excluded, use --override-existing-serviceaccounts to override
2023-01-04 10:43:44 [ℹ]  1 task: { create IAM role for serviceaccount "kube-system/ebs-csi-controller-sa" }
2023-01-04 10:43:44 [ℹ]  building iamserviceaccount stack "eksctl-kong31-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
2023-01-04 10:43:44 [ℹ]  deploying stack "eksctl-kong31-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
2023-01-04 10:43:44 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
2023-01-04 10:44:16 [ℹ]  waiting for CloudFormation stack "eksctl-kong31-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa"
```


Add the Amazon EBS CSI add-on. Replace <b><AWS_ACCOUNT></b> with your account ID.

```
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster kong31 \
  --service-account-role-arn arn:aws:iam::<AWS_ACCOUNT>:role/AmazonEKS_EBS_CSI_DriverRole
```

**Expected Output**

```
2023-01-04 10:46:55 [ℹ]  Kubernetes version "1.24" in use by cluster "kong31"
2023-01-04 10:46:55 [ℹ]  using provided ServiceAccountRoleARN "arn:aws:iam::<AWS_ACCOUNT>:role/AmazonEKS_EBS_CSI_DriverRole"
2023-01-04 10:46:55 [ℹ]  creating addon
```



#### Verifying the EKS Cluster

```bash
kubectl get pod --all-namespaces
```

**Expected Output**

```
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
kube-system   aws-node-6cv6p                        1/1     Running   0          20h
kube-system   coredns-79989457d9-bwbzr              1/1     Running   0          20h
kube-system   coredns-79989457d9-rm2fk              1/1     Running   0          20h
kube-system   ebs-csi-controller-59c8fb5d88-bqpnj   6/6     Running   0          2m16s
kube-system   ebs-csi-controller-59c8fb5d88-qgms2   6/6     Running   0          2m16s
kube-system   ebs-csi-node-r72f8                    3/3     Running   0          2m17s
kube-system   kube-proxy-sg8mb                      1/1     Running   0          20h
```



#### Export the Worker Role Name for use throughout the workshop


```bash
echo "export EKS_CLUSTERNAME=$(cut -d . -f 1 <<< $(cut -d @ -f 2 <<< $(kubectl config current-context)))" >> ~/.bashrc
bash
echo "export STACK_NAME=$(eksctl get nodegroup --cluster $EKS_CLUSTERNAME -o json | jq -r '.[].StackName')" >> ~/.bashrc
bash
echo "export ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')" >> ~/.bashrc
bash
```

#### Troubleshooting

##### What if i dont see the expected output as above ?

In case you get disconnected from network, AWS Cloud9 may not be able to complete all actions that are executed sequentially using `eksctl create cluster` command. In such event, take the following actions

1. List the cluster created

```bash
eksctl get cluster
```

**Sample Output**

```bash
NAME	REGION		EKSCTL CREATED
kong31	us-east-1	True
```

2. Write to KubeConfig.

```bash
eksctl utils write-kubeconfig --cluster kong31
```


