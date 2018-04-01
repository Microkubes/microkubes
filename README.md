# microkubes
Microkubes is a ground-up scalable microservice framework

## Deployment guide for Kubernetes

These instructions will let you deploy the Microkubes on Kubernetes

### Preparing

1. Run a single-node Kubernetes cluster via Minikube tool

```bash
minikube start
```

2. Create keys for authorization servers:

```bash
./keys/create.sh
```

3. Create a secret from keys generated in Step 2
 
```bash
kubectl create secret generic microkubes-secrets \
	--from-file=keys/default \
	--from-file=keys/default.pub \
	--from-file=keys/private.pem \
	--from-file=keys/public.pub \
	--from-file=keys/service.cert \
	--from-file=keys/service.key \
	--from-file=keys/system \
	--from-file=keys/system.pub
```

### Deploy the Microkubes

Run the following commands:
```bash
cd kubernetes/
kubectl create -f consul.yaml
kubectl create -f kube-consul-register.yaml
kubectl create -f kong.yaml
kubectl create -f mongo.yaml
kubectl create -f rabbitmq.yaml
kubectl create -f fakesmtp.yaml
kubectl create -f microkubes.yaml
```
