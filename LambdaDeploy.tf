# credentials
credentials "app.terraform.io" {
  token = "${TOKEN}"
}

# workspace
terraform {
  backend "remote" {
    organization = "SnapTourney"

    workspaces {
      name = "${PREFIX}SnapTourneyServices"
    }
  }
}

# role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_${PREFIX}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_lambda_function" "lambda" {
  filename      = "${PACKAGE}"
  function_name = "poc_lambda"
  role          = aws_iam_role.iam_for_lambda.arn

  source_code_hash = filebase64sha256("${PACKAGE}")

  runtime = "python3.9"
}