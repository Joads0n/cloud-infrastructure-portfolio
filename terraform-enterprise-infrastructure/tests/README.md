# Terraform Enterprise infrastructure tests

Run from the repository root:

```sh
python3 -m unittest discover -s terraform-enterprise-infrastructure/tests -v
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab fmt -check -recursive
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab validate
```

The tests inspect the Terraform contract only. They do not install Terraform Enterprise, create a Cloud SQL instance, publish secrets, access a bucket, or authenticate to GCP.
