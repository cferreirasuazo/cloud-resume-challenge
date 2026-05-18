variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the resume site"
  type        = string
}

variable "domain_name" {
  description = "Root domain (e.g. example.com) — must already exist as a Route 53 hosted zone"
  type        = string
}

variable "www_domain_name" {
  description = "WWW subdomain (e.g. www.example.com)"
  type        = string
}
