##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_dynamodb_table" {
  default = "ddt-datasource"
}

variable "accountId" {}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-2"
}

data "aws_iam_group" "ec2admin" {
  group_name = "EC2Admin"
}

data "aws_region" "current" {
  current = true
}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_dynamodb_table" "terraform_datasource" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ProjectEnvironment"

  attribute {
    name = "ProjectEnvironment"
    type = "S"
  }
}

resource "aws_iam_policy" "dynamodb-access" {
  name = "dynamodb-access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:Get*",
                "dynamodb:query"
            ],
            "Resource": "${aws_dynamodb_table.terraform_datasource.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_iam_role_policy_attachment" "dynamodb-access" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.dynamodb-access.arn}"
}

resource "aws_lambda_function" "data_source_ddb" {
  filename      = "index.zip"
  function_name = "tdd_ddb_query"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.handler"
  runtime       = "nodejs6.10"
}

resource "aws_api_gateway_rest_api" "tddapi" {
  name        = "TDDDataSourceService"
  description = "Query a DynamoDB Table for values"
}

resource "aws_api_gateway_resource" "tddresource" {
  rest_api_id = "${aws_api_gateway_rest_api.tddapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.tddapi.root_resource_id}"
  path_part   = "tdd_ddb_query"
}

resource "aws_api_gateway_method" "tddget" {
  rest_api_id   = "${aws_api_gateway_rest_api.tddapi.id}"
  resource_id   = "${aws_api_gateway_resource.tddresource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.tddapi.id}"
  resource_id             = "${aws_api_gateway_resource.tddresource.id}"
  http_method             = "${aws_api_gateway_method.tddget.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.data_source_ddb.arn}/invocations"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.data_source_ddb.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${var.accountId}:${aws_api_gateway_rest_api.tddapi.id}/*/${aws_api_gateway_method.tddget.http_method}${aws_api_gateway_resource.tddresource.path}"
}

resource "aws_api_gateway_deployment" "ddtdeployment" {
  depends_on = ["aws_api_gateway_integration.integration"]

  rest_api_id = "${aws_api_gateway_rest_api.tddapi.id}"
  stage_name  = "prod"
}

output "invoke-url" {
  value = "https://${aws_api_gateway_deployment.ddtdeployment.rest_api_id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.ddtdeployment.stage_name}/${aws_lambda_function.data_source_ddb.function_name}"
}
