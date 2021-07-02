---
title: "Sample App Installation"
chapter: true
draft: false
weight: 5
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
$ kubectl get services --all-namespaces
NAMESPACE     NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
default       kubernetes   ClusterIP   10.100.0.1    <none>        443/TCP         118m
default       sample       ClusterIP   10.100.8.28   <none>        5000/TCP        6m22s
kube-system   kube-dns     ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   118m
```

```
$ kubectl get pod --all-namespaces
NAMESPACE     NAME                      READY   STATUS    RESTARTS   AGE
default       sample-76db6bb547-h2jgk   1/1     Running   0          6m27s
kube-system   aws-node-ljf7m            1/1     Running   0          68m
kube-system   coredns-85cc4f6d5-7sbhc   1/1     Running   0          118m
kube-system   coredns-85cc4f6d5-vkqdv   1/1     Running   0          118m
kube-system   kube-proxy-tv6rb          1/1     Running   0          68m
```

Open a local terminal and expose the application with "port forward":

```$ kubectl port-forward service/sample 5000
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
```

Open another local terminal and consume the app sending a request like this:
```
$ http :5000/hello
HTTP/1.0 200 OK
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Thu, 01 Jul 2021 16:31:38 GMT
Server: Werkzeug/1.0.1 Python/3.7.4

Hello World, Kong: 2021-07-01 16:31:38.972394
```

Type ˆC on the first terminal to stop the application exposure.
