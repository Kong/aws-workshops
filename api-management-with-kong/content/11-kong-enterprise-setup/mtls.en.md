---
title : "mTLS Setup"
weight : 111
---

Mutual TLS, or mTLS for short, is a method for mutual authentication. mTLS ensures that the parties at each end of a network connection are who they claim to be by verifying that they both have the correct private key. The information within their respective TLS certificates provides additional verification.

mTLS is often used in a Zero Trust security framework to verify users, devices, and servers within an organization. It can also help keep APIs secure.

Zero Trust means that no user, device, or network traffic is trusted by default, an approach that helps eliminate many security vulnerabilities.

In Hybrid mode, mTLS is used for authentication so the actual private key is never transferred on the network, and communication between CP and DP nodes is secure.

Before using Hybrid mode, you need a certificate/key pair. Kong Gateway provides two modes for handling certificate/key pairs:

* **Shared mode** (Default) Use the Kong CLI to generate a certificate/key pair, then distribute copies across nodes. The certificate/key pair is shared by both CP and DP nodes.
* **PKI mode** Provide certificates signed by a central certificate authority (CA). Kong validates both sides by checking if they are from the same CA. This eliminates the risks associated with transporting private keys.


#### Create Certificate/key pair
To have an easier deployment we’re going to use the Shared Mode and OpenSSL to issue the pair. The command below creates two files `cluster.key` and `cluster.crt`.

```bash
openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) \
  -keyout ./cluster.key -out ./cluster.crt \
  -days 1095 -subj "/CN=kong_clustering"
```

#### Create namespace for kong control plane and kong data planes

```bash
kubectl create namespace kong
```

```bash
kubectl create namespace kong-dp
```

#### Create a Kubernetes secret with the pair

```bash
kubectl create secret tls kong-cluster-cert --cert=./cluster.crt --key=./cluster.key -n kong
```

#### Mount the license key as Kubernetes Secret

For Control Plane namespace

```bash
kubectl create secret -n kong generic kong-enterprise-license --from-file=license=./license.json
```

For Data Plane namespace

```bash
kubectl create secret -n kong-dp generic kong-enterprise-license --from-file=license=./license.json
```


You have now reached the end of this module by provisioning the Certificate key pair, required to provision Kong Control Plane