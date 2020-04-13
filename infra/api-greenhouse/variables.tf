variable "aws_api_gateway_rest_api" {
    type = object({id: string})
}

variable "aws_api_gateway_resource" {
    type = object({id: string})
}

variable "aws_lambda_function" {
    type = object({invoke_arn: string})
}

variable "region" {
  type = string
}

variable "account" {
    type = object({account_id:string})
}