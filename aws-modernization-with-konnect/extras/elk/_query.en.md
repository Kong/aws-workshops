+++
title = "Logs"
weight = 12
+++

####  Create an ELK Index

```bash

echo "export KIBANA_LB=$(kubectl get service kibana-kibana --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n elk)" >> ~/.bashrc
bash
```

```
echo $KIBANA_LB:5601
```

Copy the output and open in a browser at port 5601

Click on **Explore on my own**

![kibana_homepage](/images/kibana_homepage.png)


On the left menu click on **Management **-> **Stack Management**

![kibana_stackmanagement](/images/kibana_stackmanagement.png)


Click on **Data** -> **Index Management**. Since we're already send requests to the Data Plane and we have enabled the TCP-Log plugin, we should see the **kong** index as we set in our Logstash configuration.

![kibana_indexmanagement](/images/kibana_indexmanagement.png)


Click on **Kibana** -> **Index Pattern** -> **Create index pattern**. For the **Index pattern name** choose **kong**. Click on **Next Step**

![kibana_indexpattern](/images/kibana_indexpattern.png)


On the Step 2 page choose **@timestamp** for **Time Field**. Click on **Create index pattern**

![kibana_indexpattern2](/images/kibana_indexpattern2.png)


##  Work with the Kong Data Plane requests

On the left menu click on **Analytics** -> **Discover**. You should see the requests coming from the Kong Data Plane.

![kibana_discover](/images/kibana_discover.png)

