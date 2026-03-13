# Cloud Resume Bootcamp – AWS Deployment

This project is a cloud-hosted personal resume built with Next.js and deployed on AWS using an automated, fully serverless architecture. It showcases hands-on cloud engineering skills across frontend hosting, CDN distribution, DNS management, API integration, CI/CD, and modern Infrastructure as Code using Terraform.

## Architecture Overview

**Frontend**

- Built with **Next.js**
- Static assets deployed to **Amazon S3**
- Distributed globally via **Amazon CloudFront**
- Custom domain and DNS routing handled with **Route 53**

**Backend**

- **API Gateway** endpoint used for the page view counter
- Lambda backend (or other compute you chose) increments and returns the count
- Data stored using DynamoDB (if applicable)

**Infrastructure as Code**

- Entire infrastructure is defined and provisioned using Terraform

  - S3 bucket for hosting

  - CloudFront distribution

  - Route 53 DNS + ACM certificate

  - Lambda function + IAM roles

  - API Gateway REST API

  - DynamoDB table

**CI/CD**

- GitHub Actions pipeline handles:

  1. Building the Next.js site
  2. Running smoke tests
  3. Deploying to S3 on success
  4. Invalidating CloudFront cache

---

## Features

### 1. Next.js Resume Website

A clean, responsive, statically-generated resume site built with Next.js. Generated output is exported and uploaded to the S3 bucket for hosting.

### 2. S3 Static Hosting

The S3 bucket acts as the website origin for CloudFront. It stores all static assets, including HTML, CSS, JS, and images.

### 3. CloudFront Distribution

CloudFront provides a fast, globally-cached CDN layer.
Configured with:

- S3 bucket origin
- HTTPS using ACM certificate
- Cache invalidation from GitHub Actions on every deploy

### 4. Route 53 (need to implement)

Custom domain management:

- Hosted Zone
- A record pointing to CloudFront
- Automatic validation for ACM

### 5. API Gateway View Counter

A simple REST endpoint wired to a Lambda function that increments a page view counter.
Integrated directly into the frontend to display visitor statistics.

### 6. GitHub Actions Deployment Pipeline

Automated build and deployment workflow:

- Install & build Next.js
- Run smoke test (ensures the build is valid, UI loads, and counter API responds)
- Upload artifacts to S3
- Invalidate CloudFront cache
- Fail the pipeline if the smoke test fails

---

## Project Structure

---

## Deployment Workflow

1. Push to `main`
2. GitHub Actions builds the Next.js app
3. Smoke test runs:

   - Build is valid
   - Essential pages load
   - View counter API responds

4. If the test passes:

   - Static files uploaded to S3
   - CloudFront invalidation triggered

5. New version goes live globally

---

## How to Run Locally

```
pnpm install
pnpm dev
```

The project fetches the view counter during runtime through your configured API Gateway URL.

---

## Smoke Test Overview

The smoke test runs before deployment and checks:

- Build success
- Index page renders
- Required assets load

If anything fails, deployment stops.
