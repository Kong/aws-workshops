---
title: "Sample App Installation"
chapter: true
draft: false
weight: 6
---

# Sample App Installation

The going to deploy a very basic application to our EKS Cluster and protect it with Kong for Kubernetes Ingress Controller. The app simply returns the current datetime.

## Deploy Sample App

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: sample
  namespace: default
  labels:
    app: sample
spec:
  type: ClusterIP
  ports:
  - port: 5000
    name: http
  selector:
    app: sample
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample
  template:
    metadata:
      labels:
        app: sample
        version: v1
    spec:
      containers:
      - name: sample
        image: claudioacquaviva/sampleapp
        ports:
        - containerPort: 5000
EOF
```

Check the Deployment
```
$ kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.100.0.1      <none>        443/TCP    19h
sample       ClusterIP   10.100.80.154   <none>        5000/TCP   48s
```

```
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
sample-76db6bb547-p85q9   1/1     Running   0          54s
```

Open a local terminal and expose the application with "port forward":

```
$ kubectl port-forward service/sample 5000
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
```

Open another local terminal and consume the app sending a request like this:
```
$ http :5000/hello
HTTP/1.0 200 OK
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 08 Jul 2021 16:49:41 GMT
Server: Werkzeug/1.0.1 Python/3.7.4

Hello World, Kong: 2021-07-08 16:49:41.002500
```

Type ˆC on the first terminal to stop the application exposure.
