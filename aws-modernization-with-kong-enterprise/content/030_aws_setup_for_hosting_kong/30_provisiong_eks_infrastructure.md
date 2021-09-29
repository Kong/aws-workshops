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
2021-07-01 11:24:07 [ℹ]  eksctl version 0.54.0
2021-07-01 11:24:07 [ℹ]  using region eu-central-1
2021-07-01 11:24:08 [ℹ]  setting availability zones to [eu-central-1c eu-central-1b eu-central-1a]
2021-07-01 11:24:08 [ℹ]  subnets for eu-central-1c - public:192.168.0.0/19 private:192.168.96.0/19
2021-07-01 11:24:08 [ℹ]  subnets for eu-central-1b - public:192.168.32.0/19 private:192.168.128.0/19
2021-07-01 11:24:08 [ℹ]  subnets for eu-central-1a - public:192.168.64.0/19 private:192.168.160.0/19
2021-07-01 11:24:08 [ℹ]  using Kubernetes version 1.20
2021-07-01 11:24:08 [ℹ]  creating EKS cluster "K4K8S" in "eu-central-1" region with 
2021-07-01 11:24:08 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=eu-central-1 --cluster=K4K8S'
2021-07-01 11:24:08 [ℹ]  CloudWatch logging will not be enabled for cluster "K4K8S" in "eu-central-1"
2021-07-01 11:24:08 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=eu-central-1 --cluster=K4K8S'
2021-07-01 11:24:08 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "K4K8S" in "eu-central-1"
2021-07-01 11:24:08 [ℹ]  2 sequential tasks: { create cluster control plane "K4K8S", 2 sequential sub-tasks: { wait for control plane to become ready, 1 task: { create addons } } }
2021-07-01 11:24:08 [ℹ]  building cluster stack "eksctl-K4K8S-cluster"
2021-07-01 11:24:10 [ℹ]  deploying stack "eksctl-K4K8S-cluster"
2021-07-01 11:24:40 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:25:11 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:26:12 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:27:13 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:28:14 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:29:15 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:30:17 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:31:18 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:32:19 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:33:20 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:34:22 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:35:23 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-cluster"
2021-07-01 11:39:34 [ℹ]  waiting for the control plane availability...
2021-07-01 11:39:34 [✔]  saved kubeconfig as "/Users/claudio/.kube/config"
2021-07-01 11:39:34 [ℹ]  no tasks
2021-07-01 11:39:34 [✔]  all EKS cluster resources for "K4K8S" have been created
2021-07-01 11:41:41 [ℹ]  kubectl command should work with "/Users/claudio/.kube/config", try 'kubectl get nodes'
2021-07-01 11:41:41 [✔]  EKS cluster "K4K8S" in "eu-central-1" region is ready
</pre>

<pre>
$ eksctl get cluster
2021-07-01 12:16:41 [ℹ]  eksctl version 0.54.0
2021-07-01 12:16:41 [ℹ]  using region eu-central-1
NAME	REGION		EKSCTL CREATED
K4K8S	eu-central-1	True
</pre>

## Creating the NodeGroup
Now let's add a NodeGroup in our Cluster.

<pre>
$ kubectl get node
No resources found
</pre>

<pre>
$ eksctl create nodegroup --cluster K4K8S --name K4K8S-node --region eu-central-1 --node-type m5.2xlarge --nodes 1 --max-pods-per-node 50
2021-07-01 12:18:04 [ℹ]  eksctl version 0.54.0
2021-07-01 12:18:04 [ℹ]  using region eu-central-1
2021-07-01 12:18:05 [ℹ]  will use version 1.20 for new nodegroup(s) based on control plane version
2021-07-01 12:18:13 [ℹ]  nodegroup "K4K8S-node" will use "ami-0083e9407e275acf2" [AmazonLinux2/1.20]
2021-07-01 12:18:15 [ℹ]  1 nodegroup (K4K8S-node) was included (based on the include/exclude rules)
2021-07-01 12:18:15 [ℹ]  will create a CloudFormation stack for each of 1 nodegroups in cluster "K4K8S"
2021-07-01 12:18:15 [ℹ]  2 sequential tasks: { fix cluster compatibility, 1 task: { 1 task: { create nodegroup "K4K8S-node" } } }
2021-07-01 12:18:15 [ℹ]  checking cluster stack for missing resources
2021-07-01 12:18:16 [ℹ]  cluster stack has all required resources
2021-07-01 12:18:16 [ℹ]  building nodegroup stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:18:16 [ℹ]  --nodes-min=1 was set automatically for nodegroup K4K8S-node
2021-07-01 12:18:16 [ℹ]  --nodes-max=1 was set automatically for nodegroup K4K8S-node
2021-07-01 12:18:17 [ℹ]  deploying stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:18:17 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:18:34 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:18:52 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:19:12 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:19:31 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:19:53 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:20:14 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:20:34 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:20:52 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:21:11 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:21:29 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:21:46 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:22:05 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:22:22 [ℹ]  waiting for CloudFormation stack "eksctl-K4K8S-nodegroup-K4K8S-node"
2021-07-01 12:22:24 [ℹ]  no tasks
2021-07-01 12:22:25 [ℹ]  adding identity "arn:aws:iam::151743893450:role/eksctl-K4K8S-nodegroup-K4K8S-node-NodeInstanceRole-1VVUN9E3UB1DY" to auth ConfigMap
2021-07-01 12:22:26 [ℹ]  nodegroup "K4K8S-node" has 0 node(s)
2021-07-01 12:22:26 [ℹ]  waiting for at least 1 node(s) to become ready in "K4K8S-node"
2021-07-01 12:22:56 [ℹ]  nodegroup "K4K8S-node" has 1 node(s)
2021-07-01 12:22:56 [ℹ]  node "ip-192-168-41-56.eu-central-1.compute.internal" is ready
2021-07-01 12:22:56 [✔]  created 1 nodegroup(s) in cluster "K4K8S"
2021-07-01 12:22:56 [✔]  created 0 managed nodegroup(s) in cluster "K4K8S"
2021-07-01 12:22:59 [ℹ]  checking security group configuration for all nodegroups
2021-07-01 12:22:59 [ℹ]  all nodegroups have up-to-date configuration
</pre>

<pre>
$ kubectl get node
NAME                                             STATUS   ROLES    AGE     VERSION
ip-192-168-41-56.eu-central-1.compute.internal   Ready    <none>   4m10s   v1.20.4-eks-6b7464
</pre>

<pre>
$ kubectl describe node
Name:               ip-192-168-41-56.eu-central-1.compute.internal
Roles:              <none>
Labels:             alpha.eksctl.io/cluster-name=K4K8S
                    alpha.eksctl.io/instance-id=i-04ba739575f55ea53
                    alpha.eksctl.io/nodegroup-name=K4K8S-node
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=m5.xlarge
                    beta.kubernetes.io/os=linux
                    failure-domain.beta.kubernetes.io/region=eu-central-1
                    failure-domain.beta.kubernetes.io/zone=eu-central-1b
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-192-168-41-56.eu-central-1.compute.internal
                    kubernetes.io/os=linux
                    node-lifecycle=on-demand
                    node.kubernetes.io/instance-type=m5.xlarge
                    topology.kubernetes.io/region=eu-central-1
                    topology.kubernetes.io/zone=eu-central-1b
Annotations:        node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 01 Jul 2021 12:22:26 -0300
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  ip-192-168-41-56.eu-central-1.compute.internal
  AcquireTime:     <unset>
  RenewTime:       Thu, 01 Jul 2021 12:27:06 -0300
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Thu, 01 Jul 2021 12:23:26 -0300   Thu, 01 Jul 2021 12:22:24 -0300   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Thu, 01 Jul 2021 12:23:26 -0300   Thu, 01 Jul 2021 12:22:24 -0300   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Thu, 01 Jul 2021 12:23:26 -0300   Thu, 01 Jul 2021 12:22:24 -0300   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Thu, 01 Jul 2021 12:23:26 -0300   Thu, 01 Jul 2021 12:22:56 -0300   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:   192.168.41.56
  ExternalIP:   54.93.47.94
  Hostname:     ip-192-168-41-56.eu-central-1.compute.internal
  InternalDNS:  ip-192-168-41-56.eu-central-1.compute.internal
  ExternalDNS:  ec2-54-93-47-94.eu-central-1.compute.amazonaws.com
Capacity:
  attachable-volumes-aws-ebs:  25
  cpu:                         4
  ephemeral-storage:           83873772Ki
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      15921668Ki
  pods:                        50
Allocatable:
  attachable-volumes-aws-ebs:  25
  cpu:                         3920m
  ephemeral-storage:           76224326324
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      14904836Ki
  pods:                        50
System Info:
  Machine ID:                 ec298ccf9b05a8d7909caa115dbbb244
  System UUID:                ec298ccf-9b05-a8d7-909c-aa115dbbb244
  Boot ID:                    65d1195e-3455-4a62-a727-37fd60bd7295
  Kernel Version:             5.4.117-58.216.amzn2.x86_64
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  docker://19.3.13
  Kubelet Version:            v1.20.4-eks-6b7464
  Kube-Proxy Version:         v1.20.4-eks-6b7464
ProviderID:                   aws:///eu-central-1b/i-04ba739575f55ea53
Non-terminated Pods:          (4 in total)
  Namespace                   Name                       CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                       ------------  ----------  ---------------  -------------  ---
  kube-system                 aws-node-ljf7m             10m (0%)      0 (0%)      0 (0%)           0 (0%)         4m42s
  kube-system                 coredns-85cc4f6d5-7sbhc    100m (2%)     0 (0%)      70Mi (0%)        170Mi (1%)     54m
  kube-system                 coredns-85cc4f6d5-vkqdv    100m (2%)     0 (0%)      70Mi (0%)        170Mi (1%)     54m
  kube-system                 kube-proxy-tv6rb           100m (2%)     0 (0%)      0 (0%)           0 (0%)         4m42s
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                    Requests    Limits
  --------                    --------    ------
  cpu                         310m (7%)   0 (0%)
  memory                      140Mi (0%)  340Mi (2%)
  ephemeral-storage           0 (0%)      0 (0%)
  hugepages-1Gi               0 (0%)      0 (0%)
  hugepages-2Mi               0 (0%)      0 (0%)
  attachable-volumes-aws-ebs  0           0
Events:
  Type    Reason                   Age    From        Message
  ----    ------                   ----   ----        -------
  Normal  Starting                 4m44s  kubelet     Starting kubelet.
  Normal  NodeHasSufficientMemory  4m44s  kubelet     Node ip-192-168-41-56.eu-central-1.compute.internal status is now: NodeHasSufficientMemory
  Normal  NodeHasNoDiskPressure    4m44s  kubelet     Node ip-192-168-41-56.eu-central-1.compute.internal status is now: NodeHasNoDiskPressure
  Normal  NodeHasSufficientPID     4m44s  kubelet     Node ip-192-168-41-56.eu-central-1.compute.internal status is now: NodeHasSufficientPID
  Normal  NodeAllocatableEnforced  4m42s  kubelet     Updated Node Allocatable limit across pods
  Normal  Starting                 4m33s  kube-proxy  Starting kube-proxy.
  Normal  NodeReady                4m12s  kubelet     Node ip-192-168-41-56.eu-central-1.compute.internal status is now: NodeReady
</pre>

## Checking the EKS Cluster

<pre>
$ kubectl get pod --all-namespaces
NAMESPACE     NAME                      READY   STATUS    RESTARTS   AGE
kube-system   aws-node-ljf7m            1/1     Running   0          6m24s
kube-system   coredns-85cc4f6d5-7sbhc   1/1     Running   0          56m
kube-system   coredns-85cc4f6d5-vkqdv   1/1     Running   0          56m
kube-system   kube-proxy-tv6rb          1/1     Running   0          6m24s
</pre>

<pre>
$ kubectl get service --all-namespaces
NAMESPACE     NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
default       kubernetes   ClusterIP   10.100.0.1    <none>        443/TCP         56m
kube-system   kube-dns     ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   56m
</pre>
