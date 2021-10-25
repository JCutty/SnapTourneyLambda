# workspace
terraform {
  backend "remote" {
    organization = "SnapTourney"

    workspaces {
      name = "${PREFIX}SnapTourneyServices" # the workspace has to have AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY , and AWS_DEFAULT_REGION defined
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# ===== Configure the AWS Provider =====
provider "aws" {}

# role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_${PREFIX}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_function" "lambda" {
  filename      = "${PACKAGE}"
  function_name = "poc_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "Lambda.lambda_handler" # filename.function_name
  runtime       = "python3.9"

  source_code_hash = filebase64sha256("${PACKAGE}")
}