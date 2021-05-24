## Specifies the Region your Terraform Provider will server
provider "aws" {
  region = "eu-west-3"
}

## Specifies the S3 Bucket and DynamoDB table used for the durable backend and state locking
terraform {
    backend "s3" {
      encrypt = true
      bucket = "kree-terraform-tfstate"
      key = "terraform.tfstate"
      region = "eu-west-3"
  }
}

module "bootstrap" {
  source = "./bootstrap"
}

module "pipelines" {
  source = "./pipelines"
  build-role-arn = module.bootstrap.terraform-cicd-build-role-arn
  pipeline-role-arn = module.bootstrap.terraform-codepipeline-role-arn
  codestar-connector-arn = var.codestar_connector_arn
  image-repository = var.image_repository
  artifacts-bucket = module.bootstrap.artifacts-bucket
}
