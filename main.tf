provider "aws" {
  region  = "eu-west-1"
 // access_key = "var_aws_access_key"
 // secret_key = "var_aws_secret_key"
 // profile = "default"
}

/* create s3 bucket, WEB, public read, index.html default */
  resource "aws_s3_bucket" "web" {
  bucket = "mapfre-gitops-frizqui"
  acl = "public-read"
}


resource "aws_s3_bucket_website_configuration" "example" {
  bucket = "mapfre-gitops-frizqui"

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}




