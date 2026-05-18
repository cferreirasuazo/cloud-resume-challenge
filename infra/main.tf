provider "aws" {
  region = var.aws_region
}

################################
# S3 BUCKET (PRIVATE)
################################

resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################
# CLOUDFRONT ORIGIN ACCESS CONTROL
################################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "resume-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

################################
# ACM CERTIFICATE
################################

resource "aws_acm_certificate" "site_cert" {
  domain_name       = var.www_domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    var.domain_name
  ]

  lifecycle {
    create_before_destroy = true
  }
}

################################
# ROUTE53 ZONE
################################

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

################################
# CERT VALIDATION RECORD
################################

resource "aws_route53_record" "cert_validation" {

  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "site_cert" {
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

################################
# CLOUDFRONT DISTRIBUTION
################################

resource "aws_cloudfront_distribution" "cdn" {

  depends_on = [aws_acm_certificate_validation.site_cert]

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

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [
    var.www_domain_name,
    var.domain_name
  ]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

################################
# S3 POLICY (ALLOW CLOUDFRONT)
################################

resource "aws_s3_bucket_policy" "site" {

  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action   = "s3:GetObject"
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

################################
# ROUTE53 RECORDS
################################

resource "aws_route53_record" "www" {

  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.www_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {

  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

################################
# DYNAMODB TABLE
################################

resource "aws_dynamodb_table" "visits_counter" {

  name         = "visits_counter"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "initial_counter" {

  table_name = aws_dynamodb_table.visits_counter.name
  hash_key   = "id"

  item = jsonencode({
    id = { S = "visits" }
    count = { N = "0" }
  })
}

################################
# IAM ROLE FOR LAMBDA
################################

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

################################
# IAM POLICY
################################

resource "aws_iam_role_policy" "lambda_policy" {

  name = "visits-counter-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]

        Resource = aws_dynamodb_table.visits_counter.arn
      },

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

################################
# LAMBDA FUNCTION
################################

data "archive_file" "lambda_function" {

  type        = "zip"
  source_file = "${path.module}/../lambda/function.py"
  output_path = "${path.module}/../lambda/function.zip"
}

resource "aws_lambda_function" "counter" {

  function_name = "visits_counter_fn"
  runtime       = "python3.12"
  handler       = "function.handler"

  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      COUNTER_TABLE = aws_dynamodb_table.visits_counter.name
    }
  }
}

################################
# API GATEWAY
################################

resource "aws_apigatewayv2_api" "counter_api" {

  name          = "visits-counter-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {

  api_id = aws_apigatewayv2_api.counter_api.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.counter.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_visits" {

  api_id    = aws_apigatewayv2_api.counter_api.id
  route_key = "POST /visits"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
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

  source_arn = "${aws_apigatewayv2_api.counter_api.execution_arn}/*/*"
}

################################
# OUTPUTS
################################

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.counter_api.api_endpoint
}