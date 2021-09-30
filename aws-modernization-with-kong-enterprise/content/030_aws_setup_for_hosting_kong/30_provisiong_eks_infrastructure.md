---
title: "Provisioning EKS infrastructure"
chapter: true
weight: 10
---

## Creating an EKS Cluster
Before getting started with the workshop, we recommend to have an EKS Cluster already available. If you don't have one, please, follow these instructions.

## Creating an EKS Cluster
We're going to use [eksctl](https://eksctl.io/) to create our EKS Cluster.

<pre>
$ eksctl create cluster --name K4K8S --version 1.21 --region us-east-1 --without-nodegroup
2021-09-29 20:23:41 [ℹ]  eksctl version 0.67.0
2021-09-29 20:23:41 [ℹ]  using region us-east-1
2021-09-29 20:23:43 [ℹ]  setting availability zones to [us-east-1f us-east-1c]
2021-09-29 20:23:43 [ℹ]  subnets for us-east-1f - public:192.168.0.0/19 private:192.168.64.0/19
2021-09-29 20:23:43 [ℹ]  subnets for us-east-1c - public:192.168.32.0/19 private:192.168.96.0/19
2021-09-29 20:23:43 [ℹ]  using Kubernetes version 1.21
2021-09-29 20:23:43 [ℹ]  creating EKS cluster "K4K8S" in "us-east-1" region with 
2021-09-29 20:23:43 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=K4K8S'
2021-09-29 20:23:43 [ℹ]  CloudWatch logging will not be enabled for cluster "K4K8S" in "us-east-1"
2021-09-29 20:23:43 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=us-east-1 --cluster=K4K8S'
2021-09-29 20:23:43 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "K4K8S" in "us-east-1"
2021-09-29 20:23:43 [ℹ]  2 sequential tasks: { create cluster control plane "K4K8S", 2 sequential sub-tasks: { wait for control plane to become ready, 1 task: { create addons } } }
2021-09-29 20:23:43 [ℹ]  building cluster stack "eksctl-K4K8S-cluster"
2021-09-29 20:23:45 [ℹ]  deploying stack "eksctl-K4K8S-cluster"
2021-09-29 20:24:15 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:24:45 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:25:46 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:26:47 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:27:48 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:28:48 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:29:49 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:30:50 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:31:51 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:32:51 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:33:52 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:34:53 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:35:54 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:36:54 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:37:56 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:38:57 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-09-29 20:43:05 [ℹ]  waiting for the control plane availability...
2021-09-29 20:43:05 [✔]  saved kubeconfig as "/Users/claudio/.kube/config"
2021-09-29 20:43:05 [ℹ]  no tasks
2021-09-29 20:43:05 [✔]  all EKS cluster resources for "K4K8S" have been created
2021-09-29 20:45:11 [ℹ]  kubectl command should work with "/Users/claudio/.kube/config", try 'kubectl get nodes'
2021-09-29 20:45:11 [✔]  EKS cluster "K4K8S" in "us-east-1" region is ready
</pre>

<pre>
$ eksctl get cluster
2021-09-29 20:46:49 [ℹ]  eksctl version 0.67.0
2021-09-29 20:46:49 [ℹ]  using region us-east-1
NAME		REGION		EKSCTL CREATED
K4K8S		us-east-1	True
</pre>

## Creating the NodeGroup
Now let's add a NodeGroup in our Cluster.

<pre>
$ kubectl get node
No resources found
</pre>

<pre>
$ eksctl create nodegroup --cluster K4K8S --name K4K8S-node --region us-east-1 --node-type m5.2xlarge --nodes 1 --max-pods-per-node 50
2021-09-29 20:47:28 [ℹ]  eksctl version 0.67.0
2021-09-29 20:47:28 [ℹ]  using region us-east-1
2021-09-29 20:47:28 [ℹ]  will use version 1.21 for new nodegroup(s) based on control plane version
2021-09-29 20:47:33 [ℹ]  nodegroup "K4K8S-node" will use "" [AmazonLinux2/1.21]
2021-09-29 20:47:34 [ℹ]  1 nodegroup (K4K8S-node) was included (based on the include/exclude rules)
2021-09-29 20:47:34 [ℹ]  will create a CloudFormation stack for each of 1 managed nodegroups in cluster "K4K8S"
2021-09-29 20:47:35 [ℹ]  2 sequential tasks: { fix cluster compatibility, 1 task: { 1 task: { create managed nodegroup "K4K8S-node" } } }
2021-09-29 20:47:35 [ℹ]  checking cluster stack for missing resources
2021-09-29 20:47:35 [ℹ]  cluster stack has all required resources
2021-09-29 20:47:35 [ℹ]  building managed nodegroup stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:47:36 [ℹ]  deploying stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:47:36 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:47:52 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:48:10 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:48:30 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:48:48 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:49:09 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:49:29 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:49:49 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:50:42 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:51:00 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-09-29 20:51:01 [ℹ]  no tasks
2021-09-29 20:51:01 [✔]  created 0 nodegroup(s) in cluster "K4K8S"
2021-09-29 20:51:02 [ℹ]  nodegroup "K4K8S-node" has 1 node(s)
2021-09-29 20:51:02 [ℹ]  node "ip-192-168-42-135.ec2.internal" is ready
2021-09-29 20:51:02 [ℹ]  waiting for at least 1 node(s) to become ready in "K4K8S-node"
2021-09-29 20:51:02 [ℹ]  nodegroup "K4K8S-node" has 1 node(s)
2021-09-29 20:51:02 [ℹ]  node "ip-192-168-42-135.ec2.internal" is ready
2021-09-29 20:51:02 [✔]  created 1 managed nodegroup(s) in cluster "K4K8S"
2021-09-29 20:51:03 [ℹ]  checking security group configuration for all nodegroups
2021-09-29 20:51:03 [ℹ]  all nodegroups have up-to-date configuration
</pre>

<pre>
$ kubectl get node
NAME                             STATUS   ROLES    AGE   VERSION
ip-192-168-42-135.ec2.internal   Ready    <none>   93s   v1.21.2-eks-55daa9d
</pre>

<pre>
$ kubectl describe node
Name:               ip-192-168-42-135.ec2.internal
Roles:              <none>
Labels:             alpha.eksctl.io/cluster-name=K4K8S
                    alpha.eksctl.io/nodegroup-name=K4K8S-node
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=m5.2xlarge
                    beta.kubernetes.io/os=linux
                    eks.amazonaws.com/capacityType=ON_DEMAND
                    eks.amazonaws.com/nodegroup=K4K8S-node
                    eks.amazonaws.com/nodegroup-image=ami-0a99721a12001ebd4
                    eks.amazonaws.com/sourceLaunchTemplateId=lt-068b814fdb07dd19a
                    eks.amazonaws.com/sourceLaunchTemplateVersion=1
                    failure-domain.beta.kubernetes.io/region=us-east-1
                    failure-domain.beta.kubernetes.io/zone=us-east-1c
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-192-168-42-135.ec2.internal
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=m5.2xlarge
                    topology.kubernetes.io/region=us-east-1
                    topology.kubernetes.io/zone=us-east-1c
Annotations:        node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Wed, 29 Sep 2021 20:50:12 -0300
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  ip-192-168-42-135.ec2.internal
  AcquireTime:     <unset>
  RenewTime:       Wed, 29 Sep 2021 20:51:55 -0300
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Wed, 29 Sep 2021 20:51:12 -0300   Wed, 29 Sep 2021 20:50:10 -0300   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Wed, 29 Sep 2021 20:51:12 -0300   Wed, 29 Sep 2021 20:50:10 -0300   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Wed, 29 Sep 2021 20:51:12 -0300   Wed, 29 Sep 2021 20:50:10 -0300   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Wed, 29 Sep 2021 20:51:12 -0300   Wed, 29 Sep 2021 20:50:42 -0300   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:   192.168.42.135
  ExternalIP:   3.86.231.237
  Hostname:     ip-192-168-42-135.ec2.internal
  InternalDNS:  ip-192-168-42-135.ec2.internal
  ExternalDNS:  ec2-3-86-231-237.compute-1.amazonaws.com
Capacity:
  attachable-volumes-aws-ebs:  25
  cpu:                         8
  ephemeral-storage:           83873772Ki
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      32067240Ki
  pods:                        50
Allocatable:
  attachable-volumes-aws-ebs:  25
  cpu:                         7910m
  ephemeral-storage:           76224326324
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      31050408Ki
  pods:                        50
System Info:
  Machine ID:                 ec28a5fbd4d7e76c7dd7e7b0c7ea1697
  System UUID:                ec28a5fb-d4d7-e76c-7dd7-e7b0c7ea1697
  Boot ID:                    d93f6133-7a22-4a5e-a0ed-f2d2275ec303
  Kernel Version:             5.4.141-67.229.amzn2.x86_64
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  docker://19.3.13
  Kubelet Version:            v1.21.2-eks-55daa9d
  Kube-Proxy Version:         v1.21.2-eks-55daa9d
ProviderID:                   aws:///us-east-1c/i-0a6956af83a16d483
Non-terminated Pods:          (4 in total)
  Namespace                   Name                        CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                        ------------  ----------  ---------------  -------------  ---
  kube-system                 aws-node-kr2c4              10m (0%)      0 (0%)      0 (0%)           0 (0%)         108s
  kube-system                 coredns-66cb55d4f4-8pwrn    100m (1%)     0 (0%)      70Mi (0%)        170Mi (0%)     17m
  kube-system                 coredns-66cb55d4f4-hw4mq    100m (1%)     0 (0%)      70Mi (0%)        170Mi (0%)     17m
  kube-system                 kube-proxy-gb8bc            100m (1%)     0 (0%)      0 (0%)           0 (0%)         108s
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                    Requests    Limits
  --------                    --------    ------
  cpu                         310m (3%)   0 (0%)
  memory                      140Mi (0%)  340Mi (1%)
  ephemeral-storage           0 (0%)      0 (0%)
  hugepages-1Gi               0 (0%)      0 (0%)
  hugepages-2Mi               0 (0%)      0 (0%)
  attachable-volumes-aws-ebs  0           0
Events:
  Type    Reason                   Age                  From        Message
  ----    ------                   ----                 ----        -------
  Normal  Starting                 110s                 kubelet     Starting kubelet.
  Normal  NodeHasSufficientMemory  110s (x2 over 110s)  kubelet     Node ip-192-168-42-135.ec2.internal status is now: NodeHasSufficientMemory
  Normal  NodeHasNoDiskPressure    110s (x2 over 110s)  kubelet     Node ip-192-168-42-135.ec2.internal status is now: NodeHasNoDiskPressure
  Normal  NodeHasSufficientPID     110s (x2 over 110s)  kubelet     Node ip-192-168-42-135.ec2.internal status is now: NodeHasSufficientPID
  Normal  NodeAllocatableEnforced  110s                 kubelet     Updated Node Allocatable limit across pods
  Normal  Starting                 101s                 kube-proxy  Starting kube-proxy.
  Normal  NodeReady                78s                  kubelet     Node ip-192-168-42-135.ec2.internal status is now: NodeReady
</pre>

## Checking the EKS Cluster

<pre>
$ kubectl get pod --all-namespaces
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-kr2c4             1/1     Running   0          2m20s
kube-system   coredns-66cb55d4f4-8pwrn   1/1     Running   0          18m
kube-system   coredns-66cb55d4f4-hw4mq   1/1     Running   0          18m
kube-system   kube-proxy-gb8bc           1/1     Running   0          2m20s
</pre>

<pre>
$ kubectl get service --all-namespaces
NAMESPACE     NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
default       kubernetes   ClusterIP   10.100.0.1    <none>        443/TCP         18m
kube-system   kube-dns     ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   18m
</pre>
