+++
title = "ELK Stack"
weight = 12
+++


#### Elasticsearch

Install Elasticsearch

```bash
kubectl create namespace elk
```

```bash
helm repo add elastic https://helm.elastic.co
helm repo update
helm install es elastic/elasticsearch -n elk --set replicas=1 --set minimumMasterNodes=1 --set service.type=LoadBalancer
```

{{% notice note %}}
TODO : Use Load Balancer instead or Use FluentBit
{{% /notice %}}

#### Logstash

Fetch the Charts and Update values.yaml file

```bash
helm fetch elastic/logstash
tar xvfk logstash*
cd logstash
cp values.yaml logstash-values.yaml
```

Update "logstashPipeline" with




```bash
logstashPipeline:
  logstash.conf: |
    input {
      tcp {
        port => 5044
        codec => "json"
      }
    }
    output {
      elasticsearch {
        hosts => ["http://elasticsearch-master.elk.svc.cluster.local:9200"]
        index => "kong"
      }
    }
```

Update "service" field with:

```bash
service:
  annotations:
  type: ClusterIP
  ports:
    - name: logstash
      port: 5044
      protocol: TCP
      targetPort: 5044
```

Install Logstash

```bash
helm install logstash elastic/logstash -n elk -f logstash-values.yaml
```

#### Kibana

Install Kibana

```bash
helm install kibana elastic/kibana -n elk --set service.type=LoadBalancer
```

Check the installation


```bash
kubectl get all -n elk
```

**Expected Output**

```bash

NAME                             READY   STATUS    RESTARTS   AGE
elasticsearch-master-0           1/1     Running   0          2m27s
kibana-kibana-54c46c54d6-hr5xf   1/1     Running   0          91s
logstash-logstash-0              1/1     Running   0          104s


NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP                                                                 PORT(S)             AGE
elasticsearch-master            ClusterIP      10.100.207.44   <none>                                                                      9200/TCP,9300/TCP   64s
elasticsearch-master-headless   ClusterIP      None            <none>                                                                      9200/TCP,9300/TCP   64s
kibana-kibana                   LoadBalancer   10.100.5.75     a45e164398daa47a5b35a9cbeb0371e5-948492851.eu-central-1.elb.amazonaws.com   5601:32093/TCP      20s
logstash-logstash               ClusterIP      10.100.18.175   <none>                                                                      5044/TCP            27s
logstash-logstash-headless      ClusterIP      None            <none>                                                                      9600/TCP            27s


```


#### Setting the TCP-Log Plugin


Kong's TCP Log plugin enables the telemetry data around all the requests and sends to the TCP stream defined for LogStash


To enable the TCP Log plugin

```bash
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: tcp-log
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
config:
  host: logstash-logstash.elk.svc.cluster.local
  port: 5044
plugin: tcp-log
EOF
```
