provider "aws" {
  alias  = "euw3"
  region = "eu-west-3"
}

resource "aws_iam_user" "ops" {
  name = "improved-couscous-ops"
}

resource "aws_iam_policy" "ops" {
  name        = "improved-couscous-ops"
  description = "improved-couscous API policy for deployment using Zappa"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "ec2:Describe*",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ops" {
  user       = aws_iam_user.ops.name
  policy_arn = aws_iam_policy.ops.arn
}

resource "aws_iam_access_key" "ops" {
  user = aws_iam_user.ops.name
}
