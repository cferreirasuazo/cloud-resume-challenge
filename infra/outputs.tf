output "cloudfront_url" {
  description = "CloudFront domain name for the site"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  description = "Set as CF_DISTRIBUTION_ID in GitHub Actions secrets"
  value       = aws_cloudfront_distribution.cdn.id
}

output "api_gateway_url" {
  description = "Set as NEXT_PUBLIC_API_URL in GitHub Actions secrets and .env.local"
  value       = "${aws_apigatewayv2_api.counter_api.api_endpoint}/prod/visits"
}

output "s3_bucket_name" {
  description = "Set as S3_BUCKET in GitHub Actions variables"
  value       = aws_s3_bucket.site.bucket
}
