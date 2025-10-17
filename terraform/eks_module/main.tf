data "aws_lambda_functions" "all_nested" {

}

output "Lambda_Function_Names_nested" {
    value = data.aws_lambda_functions.all_nested.function_names
}
