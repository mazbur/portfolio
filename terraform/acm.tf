resource "aws_acm_certificate" "site" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# ACM's DNS challenge records, created in Cloudflare rather than Route 53.
#
# ACM returns names and values as fully-qualified with a trailing dot; Cloudflare
# stores them without one, so both are trimmed to keep the plan stable (an
# untrimmed value shows a permanent diff).
resource "cloudflare_dns_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = trimsuffix(dvo.resource_record_name, ".")
      record = trimsuffix(dvo.resource_record_value, ".")
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.record
  ttl     = 60
  proxied = false # validation records must never be proxied
  comment = "ACM DNS validation — managed by Terraform"
}

# Blocks until ACM observes the records above, so CloudFront is never handed a
# certificate that is still pending.
resource "aws_acm_certificate_validation" "site" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.site.arn

  validation_record_fqdns = [
    for record in cloudflare_dns_record.cert_validation : record.name
  ]
}
