output "cloudfront_domain" {
  description = "CloudFront distribution domain name (use for CNAME if not using Route 53)"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — set as CLOUDFRONT_DISTRIBUTION_ID in GitHub Actions vars"
  value       = aws_cloudfront_distribution.site.id
}

output "s3_bucket_name" {
  description = "S3 bucket name — set as S3_BUCKET_NAME in GitHub Actions vars"
  value       = aws_s3_bucket.site.id
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC — set as AWS_ROLE_ARN in GitHub Actions vars"
  value       = aws_iam_role.github_actions.arn
}

output "route53_nameservers" {
  description = "Update your domain registrar to use these nameservers"
  value       = aws_route53_zone.site.name_servers
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.site.arn
}
