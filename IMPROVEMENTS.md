# Cloud Resume Challenge — Code Review & Improvements

## Priority 1 — Critical Bugs (visitor counter is broken)

### 1. API method mismatch

**Where:** [app/page.tsx:28](app/page.tsx#L28) vs [infra/main.tf:358](infra/main.tf#L358)

The frontend sends a `POST` request, but the Terraform config only defines a `GET /visits` route and only allows `GET` in the CORS config. The API silently drops the request.

**Fix — `infra/main.tf`:**
```hcl
# Change route_key
resource "aws_apigatewayv2_route" "get_visits" {
  route_key = "POST /visits"   # was: "GET /visits"
  ...
}

# Add POST to allow_methods
cors_configuration {
  allow_origins = ["https://cristhianferreiracloud.com"]
  allow_methods = ["POST"]     # was: ["GET"]
  allow_headers = ["Content-Type"]
}
```

---

### 2. Lambda missing CORS headers in response

**Where:** [lambda/function.py:20-28](lambda/function.py#L20)

The Lambda returns only `Content-Type`. Without `Access-Control-Allow-Origin`, the browser blocks the response even if the API Gateway route exists.

**Fix — `lambda/function.py`:**
```python
CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
}

# Use in both success and error returns:
return {
    "statusCode": 200,
    "headers": CORS_HEADERS,
    "body": json.dumps({"count": new_count}),
}
```

---

### 3. Missing CloudFront cache invalidation in CI/CD

**Where:** [.github/workflows/ci.yml:117-118](.github/workflows/ci.yml#L117)

After uploading to S3, the workflow never invalidates the CloudFront distribution. Visitors see stale HTML for hours (or until the TTL expires) after each deployment.

**Fix — `.github/workflows/ci.yml`** (add after the S3 sync step):
```yaml
- name: Invalidate CloudFront cache
  run: |
    aws cloudfront create-invalidation \
      --distribution-id ${{ secrets.CF_DISTRIBUTION_ID }} \
      --paths "/*"
```

Requires adding `CF_DISTRIBUTION_ID` as a GitHub Actions secret (found in `infra/main.tf` as the CloudFront resource ID, or from the AWS console).

---

## Priority 2 — CI/CD Quality

### 4. Typecheck job doesn't actually typecheck

**Where:** [.github/workflows/ci.yml:13-29](.github/workflows/ci.yml#L13)

The `typecheck` job installs dependencies but never runs the TypeScript compiler, so type errors slip through to production.

**Fix — add this step to the `typecheck` job:**
```yaml
- name: Type check
  run: pnpm tsc --noEmit
```

---

### 5. App rebuilt 3× per workflow run

**Where:** [.github/workflows/ci.yml:56,76,104](.github/workflows/ci.yml#L56)

The `build`, `smoke-test`, and `deploy-s3` jobs each run `pnpm build` independently. This triples build time and means the binary deployed may differ from the binary tested.

**Fix:** upload the `out/` artifact in `build` and download it in downstream jobs:

```yaml
# In build job — after build step:
- name: Upload build artifact
  uses: actions/upload-artifact@v4
  with:
    name: next-out
    path: out/

# In smoke-test and deploy-s3 jobs — replace the build step:
- name: Download build artifact
  uses: actions/download-artifact@v4
  with:
    name: next-out
    path: out/
```

---

### 6. ESLint disabled in every build step

**Where:** [.github/workflows/ci.yml:56,76,104](.github/workflows/ci.yml#L56)

`NEXT_DISABLE_ESLINT_PLUGIN=1` is set on every build, making linting a no-op in CI.

**Fix:** remove the env var prefix, run `pnpm lint` as a dedicated step in the `typecheck` job, fix any lint errors that surface:
```yaml
- name: Lint
  run: pnpm lint
- name: Build
  run: pnpm build
```

---

## Priority 3 — Best Practices

### 7. Hardcoded API URL in frontend source

**Where:** [app/page.tsx:26](app/page.tsx#L26)

```ts
fetch("https://19pyr48o48.execute-api.us-east-1.amazonaws.com/prod/visits", ...)
```

The URL is baked into source. Rotating the API or adding a staging environment requires a code change.

**Fix:**
1. Create `.env.local` (gitignored):
   ```
   NEXT_PUBLIC_API_URL=https://19pyr48o48.execute-api.us-east-1.amazonaws.com/prod/visits
   ```
2. Update [app/page.tsx:26](app/page.tsx#L26):
   ```ts
   fetch(process.env.NEXT_PUBLIC_API_URL!, { method: "POST" })
   ```
3. Add `NEXT_PUBLIC_API_URL` to GitHub Actions secrets and pass it to the build step:
   ```yaml
   - name: Build
     run: pnpm build
     env:
       NEXT_PUBLIC_API_URL: ${{ secrets.NEXT_PUBLIC_API_URL }}
   ```

---

### 8. Hardcoded S3 bucket name in CI/CD

**Where:** [.github/workflows/ci.yml:118](.github/workflows/ci.yml#L118)

```yaml
run: aws s3 sync out/ s3://cristhian-resume-bucket --delete
```

**Fix:** move to a GitHub Actions repository variable (`Settings → Variables → Actions`):
```yaml
run: aws s3 sync out/ s3://${{ vars.S3_BUCKET }} --delete
```

---

## Summary Table

| # | Area | Severity | Issue | Effort |
|---|------|----------|-------|--------|
| 1 | Terraform + Frontend | Critical | POST vs GET route mismatch | Low |
| 2 | Lambda | Critical | CORS headers missing from response | Low |
| 3 | CI/CD | Critical | No CloudFront invalidation on deploy | Low |
| 4 | CI/CD | Medium | Typecheck job has no type check | Low |
| 5 | CI/CD | Medium | App rebuilt 3× per workflow run | Medium |
| 6 | CI/CD | Medium | ESLint disabled, no lint gate | Medium |
| 7 | Frontend | Low | API URL hardcoded in source | Low |
| 8 | CI/CD | Low | S3 bucket name hardcoded | Low |
