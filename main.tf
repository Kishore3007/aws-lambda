provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_iam_role" "aws_lambda_role" {
 name   = "aws_lambda_role"
 assume_role_policy = <<EOF
{
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
}
EOF
}

resource "aws_iam_policy" "iam_lambda_policy" {

  name         = "aws_iam_lambda_policy"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_role" {
  role        = aws_iam_role.aws_lambda_role.name
  policy_arn  = aws_iam_policy.iam_lambda_policy.arn
}

data "archive_file" "zip_the_python_code" {
 type        = "zip"
 source_dir  = "${path.module}/python/"
 output_path = "${path.module}/python/hello-python.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
 filename                       = "${path.module}/python/hello-python.zip"
 function_name                  = "sample_lambda_function"
 role                           = aws_iam_role.aws_lambda_role.arn
 handler                        = "hello-python.lambda_handler"
 runtime                        = "python3.10"
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_role]
}
