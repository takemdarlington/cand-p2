provider "aws" {
	region = var.region
}

resource "aws_iam_role" "iam_role_lambda" {
	name = "iam_role_lambda"
	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": { "Service": "lambda.amazonaws.com" },
		"Effect": "Allow",
		"Sid": "" } ]
}
EOF
}
# package the function for python deployment
data "archive_file" "app_deployment_file" {
	type		= "zip"
	source_dir	= "app"
	output_path = "app.zip"
}


resource "aws_lambda_function" "greet_function" {
	function_name = "GreetingsLambdaFunction"
	
	filename = "app.zip"
	handler = "greet_lambda.lambda_handler"
	runtime = "python3.8"
	role = aws_iam_role.iam_role_lambda.arn
	depends_on = ["aws_iam_role_policy_attachment.lambda_logs"]

	environment {
		variables = {
			greeting = "Hi there!"
		}
	}
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

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

resource "aws_cloudwatch_log_group" "example" {
  name              = aws_lambda_function.greet_function.function_name
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_role_lambda.name
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}


