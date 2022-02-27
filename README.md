# serverless-vault-gcp

Serverless [HashiCorp Vault](https://www.vaultproject.io/) deployment on Google Cloud using Cloud Run, Cloud Storage, Cloud KMS, Secret Manager & Logging.

![Serverless Vault Architecture](serverless-vault.png)

## Prequisites

* [Google Cloud](https://cloud.google.com/) project with billing enabled
* [gcloud](https://cloud.google.com/sdk/docs/install)
* [Docker](https://www.docker.com/products/docker-desktop)
* [Terraform](https://www.terraform.io/downloads)
* [Vault](https://www.vaultproject.io/downloads)

## Security Concerns

* Vault Server is publicly accessible. This **is not a best practice**. https://cloud.google.com/run/docs/securing/ingress

## Deployment

Enable `containerregistry.googleapis.com` API in your GCP project and run the below commands to set gcloud project and environment variable:

```
gcloud config set project <your-project>
PROJECT_ID=$(gcloud config get-value project)
```

### Push Vault Image to Container Registry

Cloud Run can deploy container images from either Container Registry or Artifact Registry. This project uses Container Registry. You can read more about [pushing and pulling images](https://cloud.google.com/container-registry/docs/pushing-and-pulling) in the Google documentation.

Pull the [HashiCorp Vault image](https://hub.docker.com/_/vault) from Docker Hub and push to Google Container Registry:

```
VAULT_VERSION=1.9.3
docker pull amd64/vault:$VAULT_VERSION
docker tag amd64/vault:$VAULT_VERSION gcr.io/$PROJECT_ID/vault:$VAULT_VERSION
docker push gcr.io/$PROJECT_ID/vault:$VAULT_VERSION
```

### Deploy Vault Infrastructure with Terraform

Configure variables using `terraform.tfvars` file or other means and deploy infrastructure:

```
terraform apply
```

### Initialize the Vault Server

The initial service deployment will be private to prevent someone else from initializing Vault. The service will be made public after initializing.

Set some environment variables to make following commands cleaner:

```
USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
REGION=$(terraform output -raw region)
SERVICE_NAME=$(terraform output -raw service_name)
SERVICE_URL=$(terraform output -raw service_url)
```

Grant Cloud Run invoke access to your user:

```
gcloud run services add-iam-policy-binding ${SERVICE_NAME} \
  --member="user:${USER}" \
  --role='roles/run.invoker' \
  --platform managed \
  --region ${REGION}
```

Use `curl` to initialize the Vault server:

```
curl -s -X PUT \
  ${SERVICE_URL}/v1/sys/init \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  --data '{"recovery_shares":5,"recovery_threshold":3,"secret_shares":5,"secret_threshold":3,"stored_share":5}'
```

You can read more about read more about [initializing](https://www.vaultproject.io/api/system/init) in the HashiCorp Vault documentation.

### Enable No Auth for Cloud Run Service

The Cloud Run Service can be made public now that Vault has been initialized.

Uncomment the `google_iam_policy.noauth` and `google_cloud_run_service_iam_policy.noauth` resource blocks in `cloud_run.tf` and update infrastructure:

```
terraform apply
```

### Check Vault Status

Set the `VAULT_ADDR` environment variable and check the status using `vault`:

```
export VAULT_ADDR=${SERVICE_URL}
vault status
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)