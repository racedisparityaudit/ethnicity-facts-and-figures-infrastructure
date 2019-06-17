variable "static_site_bucket" { type = string }
variable "static_site_follower_bucket" {
  type    = string
  default = ""
}
variable "error_pages_bucket" { type = string }
variable "uploads_bucket" { type = string }
variable "environment" { type = string }

variable "static_site_url" { type = string }

variable "cloudfront_lambdas" { type = list(string) }
variable "cloudfront_logs" {
  type    = string
  default = ""
}

variable "logging_bucket" {
  type    = string
  default = "ethinicity-facts-and-figures-logs"
}
