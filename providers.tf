provider "aws" {
  region  = var_aws_region

  # You can use access keys
  access_key = var_aws_access_key
  secret_key = var_aws_secret_key

  # Or specify an aws profile, instead.
  # profile = "<aws profile>"
}