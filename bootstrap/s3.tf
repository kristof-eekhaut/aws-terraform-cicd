resource "aws_s3_bucket" "codepipeline_artifacts_bucket" {
  bucket = "kree-pipeline-artifacts"
  acl    = "private"
}

output "artifacts-bucket" {
  value = aws_s3_bucket.codepipeline_artifacts_bucket.bucket
}
