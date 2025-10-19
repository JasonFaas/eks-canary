data "aws_lambda_functions" "all" {

}

output "Lambda_Function_tNames" {
    value = data.aws_lambda_functions.all.function_names
}

# Route53 Hosted Zone configuration
data "aws_route53_zone" "existing" {
  zone_id      = local.existing_zone_id
}