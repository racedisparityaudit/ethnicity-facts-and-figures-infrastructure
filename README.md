# Ethnicity facts and figures infrastructure

This repository contains terraform config used to create/update cloud infrastructure supporting the Ethnicity Facts
and Figures service. This service is hosted across Heroku and AWS; at the moment, only AWS resources are configured
for automated management.

## Dependencies

* Install [Terraform v0.12.2](https://releases.hashicorp.com/terraform/0.12.2/)
* Install [aws-vault](https://github.com/99designs/aws-vault)

## Setup

1. Add your AWS RDU user credentials to aws-vault
    * `aws-vault add rdu`
2. Declare profiles for `rdu` and `rdu-infrastructure` in `~/.aws/config`. Take the sample config below and insert
   the RDU AWS account ID and your username. (Note: the `mfa_serial` is currently declared on the root profile to
   work around a [known issue in aws-vault](https://github.com/99designs/aws-vault/issues/381))
```text
[profile rdu]
region=eu-west-1
mfa_serial = arn:aws:iam::<############>:mfa/<username>

[profile rdu-infrastructure]
source_profile = rdu
role_arn = arn:aws:iam::<############>:role/infrastructure
```
3. You can now use Terraform as your user or as an assumed role with e.g. `aws-vault exec rdu-infrastructure -- terraform plan`

## Further information
The [Developer Manual](https://developers.ethnicity-facts-figures.service.gov.uk) contains more information on how we
use Terraform to manage our infrastructure and how to use it to make changes to our cloud resources.

## TODO
* Lambda basic auth version
* Cloudwatch log groups/roles
* S3 replication roles
