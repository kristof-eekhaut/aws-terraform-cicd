resource "aws_codebuild_project" "events-cicd-build" {
  name = "events-cicd-build"
  description = "Build for Events project"
  service_role = var.build-role-arn

  concurrent_build_limit = 1

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "S3"
    location = "${var.artifacts-bucket}/cache"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name = "REPO_ECR"
      value = var.image-repository
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "build"
      stream_name = "events-service"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/kristof-eekhaut/aws-events-event.git"
    git_clone_depth = 1
  }
  source_version = "main"
}

resource "aws_codepipeline" "events-cicd-pipeline" {
  name = "events-cicd-pipeline"
  role_arn = var.pipeline-role-arn

  artifact_store {
    location = var.artifacts-bucket
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = var.codestar-connector-arn
        FullRepositoryId = "kristof-eekhaut/aws-events-event"
        BranchName = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.events-cicd-build.name
      }
    }
  }
}
