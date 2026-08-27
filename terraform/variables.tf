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

variable "github_repo" {
  description = "GitHub repo in owner/repo format (e.g. tmehta/portfolio) used to scope OIDC trust"
  type        = string
}

variable "www_redirect" {
  description = "Whether to redirect www -> apex (true) or apex -> www (false)"
  type        = bool
  default     = true
}
