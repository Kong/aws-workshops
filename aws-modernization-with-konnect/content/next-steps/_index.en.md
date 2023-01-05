+++
title = "Cleanup"
chapter = false
weight = 70
pre = "<b>7. </b>"
+++

**Kong**ratulations on completing the workshop! Now its time to delete the infrastructure you’ve created in order to work through the material.

#### Detach the role policy

```bash
aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy   
```

#### Delete the Cognito Pool and EKS Cluster

```bash
aws cloudformation delete-stack --stack-name cognito-$C9_PID
eksctl delete cluster --name $EKS_CLUSTERNAME   
```