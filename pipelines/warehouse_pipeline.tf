resource "aws_codebuild_project" "warehouse-cicd-build" {
  name = "warehouse-cicd-build"
  description = "Build for Warehouse project"
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
      stream_name = "warehouse-service"
    }
  }

  source {
    type = "GITHUB"
    location = "https://github.com/kristof-eekhaut/aws-shop-warehouse.git"
    git_clone_depth = 1
  }
  source_version = "main"
}

resource "aws_codebuild_project" "warehouse-cicd-deploy" {
  name = "warehouse-cicd-deploy"
  description = "Deploy Warehouse service docker image to EKS"
  service_role = var.build-role-arn

  concurrent_build_limit = 1

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type = "LINUX_CONTAINER"
    privileged_mode = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name = "REPO_ECR"
      value = var.image-repository
    }
    environment_variable {
      name = "REGION"
      value = var.region
    }
    environment_variable {
      name = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }
    environment_variable {
      name = "EKS_NAMESPACE"
      value = var.eks_namespace
    }
    environment_variable {
      name = "BUILD_ROLE_ARN"
      value = var.build-role-arn
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "build"
      stream_name = "warehouse-service"
    }
  }

  source {
    type = "GITHUB"
    location = "https://github.com/kristof-eekhaut/aws-shop-warehouse.git"
    git_clone_depth = 1
    buildspec = "deploy/buildspec.yml"
  }
  source_version = "main"
}


resource "aws_codepipeline" "warehouse-cicd-pipeline" {
  name = "warehouse-cicd-pipeline"
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
        FullRepositoryId = "kristof-eekhaut/aws-shop-warehouse"
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
        ProjectName = aws_codebuild_project.warehouse-cicd-build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.warehouse-cicd-deploy.name
      }
    }
  }
}
