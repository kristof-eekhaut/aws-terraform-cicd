variable region {
  description = "AWS Region"
}

variable "build-role-arn" {
  description = "Role that runs the build"
}

variable "pipeline-role-arn" {
  description = "Role that runes the pipeline"
}

variable "codestar-connector-arn" {
  description = "Codestar Connector for GitHub account"
}

variable "image-repository" {
  description = "ECR to publish the images"
}

variable "artifacts-bucket" {
  description = "S3 Bucket to store the build artifacts and cache"
}

variable "eks_cluster_name" {
  description = "Name of the Kubernetes Cluster to deploy to"
}

variable "eks_namespace" {
  description = "Kubernetes namespace to deploy to"
}
