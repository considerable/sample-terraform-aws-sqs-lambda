locals {
  lambda_code_path = "/tmp/payload.py"
  lambda_zip_path  = "/tmp/payload.zip"
}

resource "null_resource" "copy_payload" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "cp ${path.module}/payload.py ${local.lambda_code_path}"
  }
}

resource "null_resource" "zip_payload" {
  depends_on = [null_resource.copy_payload]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "zip -j ${local.lambda_zip_path} ${local.lambda_code_path}"
  }
}

provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

resource "aws_lambda_function" "tf_python_lambda" {
  filename         = local.lambda_zip_path
  function_name    = "my_lambda_test"
  role             = aws_iam_role.my_python_lambda_role.arn
  handler          = "payload.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = "data.archive_file.lambda_zip.output_base64sha256"
}

resource "aws_iam_role" "my_python_lambda_role" {
  name = "my_lambda_test_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_sqs_queue" "main_queue" {
  name             = "my-main-queue"
  delay_seconds    = 30
  max_message_size = 262144
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name             = "my-dead-letter-queue"
  delay_seconds    = 30
  max_message_size = 262144
}

resource "aws_lambda_event_source_mapping" "main_queue_sqs_lambda_trigger" {
  event_source_arn = aws_sqs_queue.main_queue.arn
  function_name    = aws_lambda_function.tf_python_lambda.arn
  depends_on       = [aws_sqs_queue.main_queue, aws_sqs_queue.dead_letter_queue]
}

resource "aws_iam_policy" "additional_sqs_lambda_policy" {
  name        = "MyAdditionalSQSLambdaPolicy"
  description = "Additional SQS policy for Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
        ],
        Resource = aws_sqs_queue.main_queue.arn,
      },
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "arn:aws:logs:*:*:*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "additional_sqs_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.additional_sqs_lambda_policy.arn
  role       = aws_iam_role.my_python_lambda_role.name
}
