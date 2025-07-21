resource "aws_s3_bucket" "landing_page" {
  bucket = "jaykape-s3-awsproj-landingpage"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.landing_page.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.landing_page.id

  depends_on = [aws_s3_bucket_public_access_block.allow_public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = "${aws_s3_bucket.landing_page.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.landing_page.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "submit_form" {
  function_name = "submit_form_handler"
  runtime       = "python3.11"
  handler       = "handler.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn

  filename         = "../lambda/lambda_function_payload.zip"  
  source_code_hash = filebase64sha256("../lambda/lambda_function_payload.zip")

  environment {
    variables = {
      DB_HOST     = "dummy"
      DB_NAME     = "dummy"
      DB_USER     = "dummy"
      DB_PASSWORD = "dummy"
    }
  }
}


resource "aws_api_gateway_rest_api" "api" {
  name = "landingpage-api"
}


resource "aws_api_gateway_resource" "submit" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "submit"
}


resource "aws_api_gateway_method" "submit_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "submit_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.submit.id
  http_method             = aws_api_gateway_method.submit_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.submit_form.invoke_arn
}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.submit_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}


resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

 depends_on = [
    aws_api_gateway_integration.submit_lambda
  ]

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_method.submit_post))
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}