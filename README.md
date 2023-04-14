# fuzzy-chainsaw
Self-contained DevSysOps environment to deploy improved-couscous.

## Running the self contained Terraform CLI

1. Define the required environment.

```
export AWS_DEFAULT_REGION="region"
export AWS_ACCESS_KEY_ID="id"
export AWS_SECRET_ACCESS_KEY="secret"
```

2. Run the Terraform CLI.

```
./run-terraform.sh ...
```

## Deploying API resources

1. Init the modules (only first time).

```
./run-terraform.sh init
```

2. Apply the configuration.

```
./run-terraform.sh apply
```

## Other commands

- Getting the IAM credentials for environment variables.

```
./run-terraform.sh state pull  | grep -A15 aws_iam_access_key
```
