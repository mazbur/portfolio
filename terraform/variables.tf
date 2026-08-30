variable "domain_name" {
  description = "Apex domain (e.g. tejasm.dev). No trailing dot, no www."
  type        = string
}

variable "project_name" {
  description = "Short slug used for resource names (e.g. portfolio)"
  type        = string
  default     = "portfolio"
}

variable "aws_region" {
  description = "Primary AWS region for S3 and other non-global resources"
  type        = string
  default     = "us-east-1"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for domain_name — shown on the zone's Overview page in the dashboard"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.cloudflare_zone_id))
    error_message = "cloudflare_zone_id must be a 32-character hex string (copy it from the Cloudflare dashboard, not the account ID)."
  }
}

variable "github_repo" {
  description = "GitHub repo in owner/repo format (e.g. tmehta/portfolio) used to scope OIDC trust"
  type        = string
}

variable "www_redirect" {
  description = "Whether to redirect www -> apex (true) or apex -> www (false)"
  type        = bool
  default     = true
}
