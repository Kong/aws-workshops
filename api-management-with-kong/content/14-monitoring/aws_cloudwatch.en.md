---
title : "AWS CloudWatch"
weight : 141
---

#### Viewing CloudWatch Logs

Observe the log groups at [in the console](https://us-east-2.console.aws.amazon.com/cloudwatch/home?region=us-east-2#logsV2:log-groups). You will notice the following log groups per cluster

* /aws/containerinsights/{ClusterName}}/application
* /aws/containerinsights/{ClusterName}}/host
* /aws/containerinsights/{ClusterName}}/dataplane
* /aws/containerinsights/{ClusterName}}/performance 
#### Querying CloudWatch Logs using logs insights

Click on `/aws/containerinsights/{ClusterName}}/application` and **View in Logs Insights**. Run the following query, which details the entire request and response logged using Kong Plugin

```bash
filter kubernetes.namespace_name='kong-dp'
| parse log '"workspace":"*"' as workspace
| filter ispresent(workspace)
| display log

```

You can view the entire request and response json logged

![cloudwatch_logs_insights](/static/images/logs_insights.png)

For more details on the log format and each property meaning, explore [plugin documentation](https://docs.konghq.com/hub/kong-inc/file-log/#log-format)