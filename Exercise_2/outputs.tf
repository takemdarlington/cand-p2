# TODO: Define the output variable for the lambda function.


output "app_version" {
	description = "App version"
	value = "${aws_lambda_function.greet_function.version}"
}

output "function_arn" {
	description = "Deployed function Arn"
	value = "${aws_lambda_function.greet_function.arn}"
}

