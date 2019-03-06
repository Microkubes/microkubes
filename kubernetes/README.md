# Deployment guide for Kubernetes

These instructions will let you deploy the Microkubes on Kubernetes.

For deployment guide for Helm, check out [this configuration](helm/README.md).
## Preparing

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

6. Create microkubes configmap

```bash
kubectl -n microkubes create -f kubernetes/manifests/microkubes-configmap.yaml
```


## Deploy Microkubes

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

## Check that microkubes is up and running

The API gateway is exposed as a nodePort in kubernetes, you can get the URL and do an http GET request to check that microkubes is responding.
```bash
MICROKUBES_URL=`minikube service -n microkubes kong --url`
SMTP_SERVER_URL=`minikube -n microkubes service fakesmtp --url | sed -n 2p`
```

Register new user:

```
curl $MICROKUBES_URL/users/register -d '{"email": "john.doe@example.com", "fullName": "John Doe", "password": "johndoe123456"}'
```

To activate the user, visit the (fake) SMTP page, and follow the ling in the email:

```bash
browse "$SMTP_SERVER_URL"
```

Then, login to get the JWT:

```bash
curl $MICROKUBES_URL/jwt/signin -H "Content-Type: application/x-www-form-urlencoded" \
    -d 'email=john.doe@example.com&password=johndoe123456&scope=api:read'
```

Will print out the JWT:

```
"Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTE5NzQ3NzIsImlhdCI6MTU1MTg4ODM3MiwiaXNzIjoiTWljcm9rdWJlcyBKV1QgQXV0aG9yaXR5IiwianRpIjoiYmEyY2ZhMzEtYmExNC00YjRmLTk4NTUtNGRmNmMwZDkyNDAzIiwibmJmIjowLCJvcmdhbml6YXRpb25zIjoiIiwicm9sZXMiOiJ1c2VyIiwic2NvcGVzIjoiYXBpOnJlYWQiLCJzdWIiOiI1YzdmZGFiM2E5OTU0MTAwMDFkNmQ2YzQiLCJ1c2VySWQiOiI1YzdmZGFiM2E5OTU0MTAwMDFkNmQ2YzQiLCJ1c2VybmFtZSI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIn0.JiVywJgKfOMSf3cA6hDYRFftMPxruyFCosDfpGMYBYZyTloVo8GmRceVYXQR6i4FdwmTqZZnatbWFlkBo0FaRzGQTpuHNq_8YY6SelDvp47-0JdSaQ_NRz9hZ0OBgFuFEiRaWY6g5D0cippCPqofkLsExTONvMKYZXdAGNrNw5SnakpIvJM3PF0QE8LWa-F0mVi3mA8SIfwPZmKqCVapVTcB1x4I4hCEksHSa3QiJ3EB6BbOTJVn27vPBJEF1Dr4ahWq_FgQV_FtZ1YngG7YqI3fqSzkj2xWkQVqTYSLlrhKjQ1euhsp1o1qIrIYT5A75jJvjiOHUd0H0nXBorEAOg"
```

Copy the token (without the quotes) and set it to a variable:

```bash
USER_TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTE5NzQ3NzIsImlhdCI6MTU1MTg4ODM3MiwiaXNzIjoiTWljcm9rdWJlcyBKV1QgQXV0aG9yaXR5IiwianRpIjoiYmEyY2ZhMzEtYmExNC00YjRmLTk4NTUtNGRmNmMwZDkyNDAzIiwibmJmIjowLCJvcmdhbml6YXRpb25zIjoiIiwicm9sZXMiOiJ1c2VyIiwic2NvcGVzIjoiYXBpOnJlYWQiLCJzdWIiOiI1YzdmZGFiM2E5OTU0MTAwMDFkNmQ2YzQiLCJ1c2VySWQiOiI1YzdmZGFiM2E5OTU0MTAwMDFkNmQ2YzQiLCJ1c2VybmFtZSI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIn0.JiVywJgKfOMSf3cA6hDYRFftMPxruyFCosDfpGMYBYZyTloVo8GmRceVYXQR6i4FdwmTqZZnatbWFlkBo0FaRzGQTpuHNq_8YY6SelDvp47-0JdSaQ_NRz9hZ0OBgFuFEiRaWY6g5D0cippCPqofkLsExTONvMKYZXdAGNrNw5SnakpIvJM3PF0QE8LWa-F0mVi3mA8SIfwPZmKqCVapVTcB1x4I4hCEksHSa3QiJ3EB6BbOTJVn27vPBJEF1Dr4ahWq_FgQV_FtZ1YngG7YqI3fqSzkj2xWkQVqTYSLlrhKjQ1euhsp1o1qIrIYT5A75jJvjiOHUd0H0nXBorEAOg
```

Then make a call to get your own user data:

```bash
curl $MICROKUBES_URL/users/me -H "Authorization: Bearer $USER_TOKEN"
```
