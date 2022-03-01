# serverless-vault-gcp

`serverless-vault-gcp` is a POC for a [HashiCorp Vault](https://www.vaultproject.io/) deployment on Google Cloud Platform.

[What is Vault?](https://www.vaultproject.io/docs/what-is-vault) Vault secures, stores, and tightly controls access to tokens, passwords, certificates, API keys, and other secrets in modern computing.

Vault is served from [Cloud Run](https://cloud.google.com/run) and leverages [Cloud Storage](https://cloud.google.com/storage) for storage, [Cloud KMS](https://cloud.google.com/security-key-management) for seal/unseal, [Secret Manager](https://cloud.google.com/secret-manager) for configuration and [Cloud Logging](https://cloud.google.com/logging) for audit.

![Serverless Vault Architecture](serverless-vault.png)

## Prequisites

* [Google Cloud](https://cloud.google.com/) project with billing enabled
* [gcloud](https://cloud.google.com/sdk/docs/install)
* [Docker](https://www.docker.com/products/docker-desktop)
* [Terraform](https://www.terraform.io/downloads)
* [Vault](https://www.vaultproject.io/downloads)

## Security Concerns

Vault Server is publicly accessible. **This is not a best practice and not recommended for production**. Access to Vault [should be restricted](https://cloud.google.com/run/docs/securing/ingress):

* [Connecting Cloud Run to a VPC network](https://cloud.google.com/run/docs/configuring/connecting-vpc)
* [Enabling IAP for Cloud Run](https://cloud.google.com/iap/docs/enabling-cloud-run)

## Deployment

Enable `artifactregistry.googleapis.com` API in your GCP project and run the below commands to set gcloud project and environment variable:

```
gcloud config set project <your-project>
PROJECT_ID=$(gcloud config get-value project)
```

### Push Vault Image to Artifact Registry

Cloud Run can deploy container images from either Container Registry or Artifact Registry. This project uses Artifact Registry. You can read more about [pushing images](https://cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling#pushing) in the Google documentation.

Pull the [HashiCorp Vault image](https://hub.docker.com/_/vault) from Docker Hub and push to Artifact Registry:

```
VAULT_VERSION=1.9.3
docker pull amd64/vault:$VAULT_VERSION
docker tag amd64/vault:$VAULT_VERSION <location>-docker.pkg.dev/$PROJECT_ID/<repository>/vault:$VAULT_VERSION
docker push <location>-docker.pkg.dev/$PROJECT_ID/<repository>/vault:$VAULT_VERSION
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

Vault is now operational.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)