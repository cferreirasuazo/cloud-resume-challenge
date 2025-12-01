provider "aws" {
  region = "us-east-1"
}

############################
# S3 Bucket (private)
############################
resource "aws_s3_bucket" "site" {
  bucket = "cristhian-resume-bucket"
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################
# Origin Access Control (OAC)
############################
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "resume-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

############################
# CloudFront Distribution
############################
resource "aws_cloudfront_distribution" "cdn" {
  comment             = "Distribute Cloud Resume" 
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # AWS CacheOptimized
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

############################
# S3 Bucket Policy — CloudFront only
############################
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

############################
# Output CloudFront URL
############################
output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}


############################
# Define AWS DYNAMODB
############################

resource "aws_dynamodb_table" "visits_counter" {
  name = "visits_counter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

########################################
# Define IAM ROLE FOR LAMBDA TO ASSUME
########################################

resource "aws_iam_role" "lambda_role" {
  name = "visits-counter-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}




########################################
# Define IAM POLICY
########################################

resource "aws_iam_role_policy" "lambda_policy" {
  name = "visits-counter-lambda-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Effect = "Allow"
        Resource = aws_dynamodb_table.visits_counter.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}



########################################
# Define lambda function
########################################
 
# Package the Lambda function code
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/../lambda/function.py"
  output_path = "${path.module}/../lambda/function.zip"
}

resource "aws_lambda_function" "counter" {
  function_name = "visits_counter_fn"
  handler       = "function.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      COUNTER_TABLE = aws_dynamodb_table.visits_counter.name
    }
  }
}


resource "aws_apigatewayv2_api" "counter_api" {
  name          = "visits-counter-api"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.counter_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.counter.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_visits" {
  api_id    = aws_apigatewayv2_api.counter_api.id
  route_key = "POST /visits"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.counter_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.counter_api.execution_arn}/*/*"
}


output "api_gateway_url" {
  value = aws_apigatewayv2_api.counter_api.api_endpoint
}