# ---------------------------------------------------------------------------
# DNS — Cloudflare
#
# The domain is registered with Cloudflare Registrar, which requires the zone
# to stay on Cloudflare nameservers (third-party nameservers are only possible
# by transferring the domain out). So there is no Route 53 hosted zone here:
# Cloudflare is authoritative and points at the CloudFront distribution.
#
# Every record is DNS-only (`proxied = false`). Proxying would put Cloudflare's
# CDN in front of CloudFront — two CDNs doing the same job, an extra TLS hop,
# and CloudFront losing the real client IP. TLS and caching are CloudFront's
# responsibility in this stack.
# ---------------------------------------------------------------------------

# Apex → CloudFront.
# A CNAME at the zone apex is invalid in plain DNS; Cloudflare permits it via
# CNAME flattening, resolving to A/AAAA records at query time.
resource "cloudflare_dns_record" "apex" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  type    = "CNAME"
  content = aws_cloudfront_distribution.site.domain_name
  ttl     = 1 # 1 = "automatic"; Cloudflare manages the TTL
  proxied = false
  comment = "Managed by Terraform — ${var.project_name}"
}

# www → the same distribution. The CloudFront function issues the
# www → apex redirect, so this deliberately does not redirect at DNS level.
resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.site.domain_name
  ttl     = 1
  proxied = false
  comment = "Managed by Terraform — ${var.project_name}"
}
