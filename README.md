# microkubes
Microkubes is a ground-up scalable microservice framework

## Deployment guide for Kubernetes

These instructions will let you deploy the Microkubes on Kubernetes

### Prerequisites Details

* Kubernetes 1.9

### Preparing

1. Run a single-node Kubernetes cluster via Minikube tool

```bash
minikube start
```

2. Create keys for authorization servers:

```bash
./keys/create.sh
```

3. Create a default microkubes namespace and service account

```bash
kubectl create -f kubernetes/manifests/namespace.yaml
kubectl create -f kubernetes/manifests/serviceaccount.yaml
```

4. Create a secret from keys generated in Step 2

```bash
kubectl -n microkubes create secret generic microkubes-secrets \
	--from-file=keys/default \
	--from-file=keys/default.pub \
	--from-file=keys/private.pem \
	--from-file=keys/public.pub \
	--from-file=keys/service.cert \
	--from-file=keys/service.key \
	--from-file=keys/system \
	--from-file=keys/system.pub
```

5. Create a secret for the mongo objects creation

```bash
kubectl -n microkubes create secret generic mongo-init-db \
        --from-file=./kubernetes/manifests/mongo/create_microkubes_db_objects.sh
```

### Deploy Microkubes

Run the following commands:
```bash
cd kubernetes/manifests
kubectl create -f consul.yaml
kubectl create -f kube-consul-register.yaml
kubectl create -f kong.yaml
kubectl create -f mongo.yaml
kubectl create -f rabbitmq.yaml
kubectl create -f fakesmtp.yaml
kubectl create -f microkubes.yaml
```

The platform takes about 5 minutes to bring up and you can follow the progress using `kubectl -n microkubes get pods -w`.
Once all services are running, you can start using microkubes.

### Check that microkubes is up and running

The API gateway is exposed as a nodePort in kubernetes, you can get the URL and do an http GET request to check that microkubes is responding.
```bash
MICROKUBES_URL=`minikube service -n microkubes kong --url`
curl $MICROKUBES_URL/users
```
## Contributing

For contributing to this repository or its documentation, see the [Contributing guidelines](CONTRIBUTING.md).