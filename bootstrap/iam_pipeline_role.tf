resource "aws_iam_role" "terraform-codepipeline-role" {
  name = "terraform-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "terraform-cicd-pipeline-policy-document" {
  statement {
    sid = ""
    actions = ["codestar-connections:UseConnection"]
    resources = ["*"]
    effect = "Allow"
  }
  statement {
    sid = ""
    actions = ["cloudwatch:*", "s3:*", "codebuild:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "terraform-cicd-pipeline-policy" {
  name = "terraform-cicd-pipeline-policy"
  path = "/"
  description = "Pipeline Policy"
  policy = data.aws_iam_policy_document.terraform-cicd-pipeline-policy-document.json
}

resource "aws_iam_role_policy_attachment" "terraform-cicd-pipeline-attachment" {
  policy_arn = aws_iam_policy.terraform-cicd-pipeline-policy.arn
  role = aws_iam_role.terraform-codepipeline-role.id
}

output "terraform-codepipeline-role-arn" {
  value = aws_iam_role.terraform-codepipeline-role.arn
}
