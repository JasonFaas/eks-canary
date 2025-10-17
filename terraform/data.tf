data "aws_lambda_functions" "all" {

}

output "Lambda_Function_tNames" {
    value = data.aws_lambda_functions.all.function_names
}