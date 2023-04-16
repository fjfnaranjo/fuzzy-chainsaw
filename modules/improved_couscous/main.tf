provider "aws" {
  alias  = "euw3"
  region = "eu-west-3"
}

resource "aws_iam_user" "ops" {
  name = "improved-couscous-ops"
}

resource "aws_s3_bucket" "this" {
  bucket   = "improved-couscous"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
        "lambda.amazonaws.com",
        "events.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "improved-couscous-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_iam_policy" "this" {
  name        = "improved-couscous"
  description = "improved-couscous API policy for deployment using Zappa"
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_user_policy_attachment" "ops" {
  user       = aws_iam_user.ops.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_access_key" "ops" {
  user = aws_iam_user.ops.name
}
