provider "aws" {
  alias  = "euw3"
  region = "eu-west-3"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:CreateMultipartUpload",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads",
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:GetRole", "iam:PassRole"]
    resources = [aws_iam_role.this.arn]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetPolicy",
      "lambda:InvokeAsync",
      "lambda:InvokeFunction",
      "lambda:ListVersionsByFunction",
      "lambda:RemovePermission",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]
    resources = [
      join("", [
        "arn:aws:lambda:",
        data.aws_region.current.name,
        ":",
        data.aws_caller_identity.current.account_id,
        ":function:",
        "improved-couscous-production",
      ]),
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "events:ListRuleNamesByTarget",
    ]
    resources = [
      join("", [
        "arn:aws:events:",
        data.aws_region.current.name,
        ":",
        data.aws_caller_identity.current.account_id,
        ":rule/*",
      ]),
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "events:DeleteRule",
      "events:DescribeRule",
      "events:ListTargetsByRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
    resources = [
      join("", [
        "arn:aws:events:",
        data.aws_region.current.name,
        ":",
        data.aws_caller_identity.current.account_id,
        ":rule/*zappa-keep-warm-handler*",
      ]),
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStacks",
      "cloudformation:ListStackResources",
      "cloudformation:UpdateStack",
    ]
    resources = [
      join("", [
        "arn:aws:cloudformation:",
        data.aws_region.current.name,
        ":",
        data.aws_caller_identity.current.account_id,
        ":stack/improved-couscous-production/*",
      ]),
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "apigateway:POST",
      "apigateway:GET",
    ]
    resources = [
      join("", [
        "arn:aws:apigateway:",
        data.aws_region.current.name,
        "::/restapis",
      ]),
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "apigateway:DELETE",
      "apigateway:GET",
      "apigateway:PATCH",
    ]
    resources = [
      join("", [
        "arn:aws:apigateway:",
        data.aws_region.current.name,
        "::/restapis/*",
      ]),
    ]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
    ]
    resources = [
      join("", [
       "arn:aws:logs:",
       data.aws_region.current.name,
       ":",
       data.aws_caller_identity.current.account_id,
       ":log-group:*",
      ]),
    ]
  }
}

resource "aws_iam_policy" "this" {
  name        = "improved-couscous"
  description = "improved-couscous API policy for deployment using Zappa"
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "ops" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_access_key" "ops" {
  user = aws_iam_user.ops.name
}
