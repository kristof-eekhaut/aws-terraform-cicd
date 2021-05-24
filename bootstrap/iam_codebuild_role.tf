resource "aws_iam_role" "terraform-cicd-build-role" {
  name = "terraform-cicd-build-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "terraform-cicd-build-policy-document" {
  statement {
    sid = ""
    actions = ["logs:*", "s3:*", "codebuild:*", "ecr:*", "eks:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "terraform-cicd-build-policy" {
  name = "terraform-cicd-build-policy"
  path = "/"
  description = "Codebuild policy"
  policy = data.aws_iam_policy_document.terraform-cicd-build-policy-document.json
}

resource "aws_iam_role_policy_attachment" "terraform-cicd-build-attachment" {
  policy_arn = aws_iam_policy.terraform-cicd-build-policy.arn
  role = aws_iam_role.terraform-cicd-build-role.id
}

output "terraform-cicd-build-role-arn" {
  value = aws_iam_role.terraform-cicd-build-role.arn
}
