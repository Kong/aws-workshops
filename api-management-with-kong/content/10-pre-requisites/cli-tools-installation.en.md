---
title : "Command Line Utilities"
weight : 102
---

#### Launching AWS Cloud9

You can launch AWS Cloud9 from the AWS Management Console by opening [this link](https://us-east-2.console.aws.amazon.com/cloud9/home?region=us-east-2). 

1. Select Create environment
2. Give it a name you like
3. Leave the default settings and hit `Next Step` and `Next Step` to `Create Environment`

Post launch, we will create a bin directory to save all binaries in home drive, so that its easier to cleanup (if required)

```bash
mkdir -p $HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
```

#### Install EKSCTL

This topic covers `eksctl`, a simple command line utility for creating and managing Kubernetes clusters on Amazon EKS. The eksctl command line utility provides the fastest and easiest way to create a new cluster with nodes for Amazon EKS.

For more information and to see the official documentation, visit https://eksctl.io/.

Download , extract and install the latest release of eksctl with the following command

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl ~/bin
eksctl version
. <(eksctl completion bash)
```

#### Install kubectl

Kubernetes uses a command line utility called kubectl for communicating with the cluster API server. The kubectl binary is available in many operating system package managers, and this option is often much easier than a manual download and install process.

Download the Amazon EKS vended kubectl binary for your cluster's Kubernetes version from Amazon S3. To download the Arm version, change amd64 to arm64 before running the command.


```bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
cp ./kubectl $HOME/bin/kubectl
```

#### Install helm

```bash
curl https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz | tar xz -C /tmp
mv /tmp/linux-amd64/helm ~/bin
helm version
```

#### Install openssl

```bash
sudo yum -y install openssl jq siege
```

#### Identity and Access Management

```bash
aws ec2 associate-iam-instance-profile --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --iam-instance-profile Name=TeamRoleInstanceProfile
aws configure set region `curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`
echo "export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)" >> ~/.bashrc
bash
```

#### Cloud9 Settings change

{{% notice note %}}
Cloud9 normally manages IAM credentials dynamically. This isn’t currently compatible with the EKS IAM authentication, so we will disable it and rely on the IAM role instead.
{{% /notice %}}

1. In your Cloud9 environment , click the gear icon (in top right corner)
2. Select AWS SETTINGS
3. Turn off AWS managed temporary credentials


![Disable IAM](/images/setup/c9disableiam.png)