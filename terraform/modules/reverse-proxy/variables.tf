variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name_prefix))
    error_message = "Name prefix must be lowercase, start with a letter, and can only contain letters, numbers, and hyphens"
  }
  validation {
    condition     = length(var.name_prefix) >= 1 && length(var.name_prefix) <= 20
    error_message = "Name prefix must be between 1 and 20 characters long"
  }
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.environment))
    error_message = "Environment name must be lowercase, start with a letter, and can only contain letters, numbers, and hyphens"
  }
  validation {
    condition     = length(var.environment) >= 2 && length(var.environment) <= 20
    error_message = "Environment name must be between 2 and 20 characters long"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block (e.g., 10.0.0.0/16)"
  }
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "VPC CIDR must be in the format x.x.x.x/xx"
  }
}

variable "availability_zone_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
  validation {
    condition     = var.availability_zone_count >= 1 && var.availability_zone_count <= 6
    error_message = "Availability zone count must be between 1 and 6"
  }
}

variable "instance_type" {
  description = "EC2 instance type for reverse proxy servers"
  type        = string
  default     = "t3.medium"
  validation {
    condition     = can(regex("^[a-z][0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type (e.g., t3.medium, m5.large)"
  }
}

variable "key_name" {
  description = "Name of the AWS key pair to use for EC2 instances"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", var.key_name))
    error_message = "Key name must start with a letter or number and can only contain letters, numbers, and hyphens"
  }
  validation {
    condition     = length(var.key_name) >= 1 && length(var.key_name) <= 255
    error_message = "Key name must be between 1 and 255 characters long"
  }
}

variable "ssm_instance_profile_name" {
  description = "Name of the IAM instance profile for SSM access"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9+=,.@_-]*$", var.ssm_instance_profile_name))
    error_message = "SSM instance profile name must start with a letter or number and can only contain letters, numbers, and special characters: +=,.@_-"
  }
  validation {
    condition     = length(var.ssm_instance_profile_name) >= 1 && length(var.ssm_instance_profile_name) <= 128
    error_message = "SSM instance profile name must be between 1 and 128 characters long"
  }
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
  validation {
    condition     = var.desired_capacity >= 0 && var.desired_capacity <= 1000
    error_message = "Desired capacity must be between 0 and 1000"
  }
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 4
  validation {
    condition     = var.max_size >= 1 && var.max_size <= 1000
    error_message = "Max size must be between 1 and 1000"
  }
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
  validation {
    condition     = var.min_size >= 0 && var.min_size <= 1000
    error_message = "Min size must be between 0 and 1000"
  }
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
  validation {
    condition     = var.health_check_grace_period >= 0 && var.health_check_grace_period <= 7200
    error_message = "Health check grace period must be between 0 and 7200 seconds"
  }
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "Health check path must start with a forward slash"
  }
  validation {
    condition     = length(var.health_check_path) <= 1024
    error_message = "Health check path must be 1024 characters or less"
  }
}

variable "health_check_interval" {
  description = "Approximate amount of time between health checks"
  type        = number
  default     = 30
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds"
  }
}

variable "health_check_timeout" {
  description = "Amount of time during which no response means a failed health check"
  type        = number
  default     = 5
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds"
  }
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering an unhealthy target healthy"
  type        = number
  default     = 5
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "Health check healthy threshold must be between 2 and 10"
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 2
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "Health check unhealthy threshold must be between 2 and 10"
  }
}

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a healthy response from a target"
  type        = string
  default     = "200,301,302,404"
  validation {
    condition     = can(regex("^([0-9]{3})(,[0-9]{3})*$", var.health_check_matcher))
    error_message = "Health check matcher must be a comma-separated list of HTTP status codes (e.g., 200,301,302)"
  }
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum percentage of instances that must remain healthy during instance refresh"
  type        = number
  default     = 50
  validation {
    condition     = var.instance_refresh_min_healthy_percentage >= 0 && var.instance_refresh_min_healthy_percentage <= 100
    error_message = "Instance refresh min healthy percentage must be between 0 and 100"
  }
}

variable "instance_refresh_warmup" {
  description = "Number of seconds until a newly launched instance is configured and ready to use"
  type        = number
  default     = 300
  validation {
    condition     = var.instance_refresh_warmup >= 0 && var.instance_refresh_warmup <= 3600
    error_message = "Instance refresh warmup must be between 0 and 3600 seconds"
  }
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.enable_deletion_protection)
    error_message = "Enable deletion protection must be either true or false"
  }
}

variable "idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 180
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds"
  }
}

variable "enable_alb_access_logs" {
  description = "Enable access logging for the Application Load Balancer"
  type        = bool
  default     = false
  validation {
    condition     = contains([true, false], var.enable_alb_access_logs)
    error_message = "Enable ALB access logs must be either true or false"
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs in S3"
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 3650
    error_message = "Log retention days must be between 1 and 3650 days"
  }
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to use for HTTPS"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-zA-Z0-9-]+$", var.certificate_arn))
    error_message = "Certificate ARN must be a valid ACM certificate ARN (e.g., arn:aws:acm:region:account:certificate/id)"
  }
}

variable "ssl_policy" {
  description = "SSL policy to use for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  validation {
    condition     = can(regex("^ELBSecurityPolicy-", var.ssl_policy))
    error_message = "SSL policy must be a valid ELB security policy (e.g., ELBSecurityPolicy-TLS13-1-2-2021-06)"
  }
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the ALB (optional)"
  type        = string
  default     = null
  validation {
    condition     = var.waf_web_acl_arn == null || can(regex("^arn:aws:wafv2:[a-z0-9-]+:[0-9]{12}:global/webacl/[a-zA-Z0-9-]+/[a-f0-9-]+$", var.waf_web_acl_arn))
    error_message = "WAF Web ACL ARN must be null or a valid WAFv2 Web ACL ARN"
  }
}

variable "backend_url" {
  description = "Backend URL to proxy requests to"
  type        = string
  validation {
    condition     = can(regex("^https?://", var.backend_url))
    error_message = "Backend URL must start with http:// or https://"
  }
  validation {
    condition     = length(var.backend_url) <= 2048
    error_message = "Backend URL must be 2048 characters or less"
  }
}

variable "log_name" {
  description = "Name prefix for log files"
  type        = string
  default     = "reverse_proxy"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.log_name))
    error_message = "Log name must be lowercase, start with a letter, and can only contain letters, numbers, and underscores"
  }
  validation {
    condition     = length(var.log_name) >= 1 && length(var.log_name) <= 50
    error_message = "Log name must be between 1 and 50 characters long"
  }
}

variable "loki_host" {
  description = "Loki hostname (without domain) for log shipping"
  type        = string
  default     = ""
  validation {
    condition     = var.loki_host == "" || can(regex("^[a-z0-9][a-z0-9-]*$", var.loki_host))
    error_message = "Loki host must be empty or a valid hostname (lowercase, alphanumeric, hyphens)"
  }
  validation {
    condition     = length(var.loki_host) <= 253
    error_message = "Loki host must be 253 characters or less"
  }
}

variable "loki_domain" {
  description = "Loki domain for log shipping (e.g., example.com)"
  type        = string
  default     = ""
  validation {
    condition     = var.loki_domain == "" || can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}$", var.loki_domain))
    error_message = "Loki domain must be empty or a valid domain name (e.g., example.com)"
  }
}

variable "enable_promtail" {
  description = "Enable Promtail for log shipping to Loki"
  type        = bool
  default     = false
  validation {
    condition     = contains([true, false], var.enable_promtail)
    error_message = "Enable Promtail must be either true or false"
  }
}

variable "reverse_proxy_rules" {
  description = "List of reverse proxy rules in Apache ProxyPass format"
  type = list(object({
    path     = string
    backend  = string
    preserve = optional(bool, true)
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.reverse_proxy_rules : (
        startswith(rule.path, "/") &&
        can(regex("^https?://", rule.backend)) &&
        length(rule.path) <= 1024 &&
        length(rule.backend) <= 2048
      )
    ])
    error_message = "Each reverse proxy rule must have a path starting with '/' and a backend URL starting with 'http://' or 'https://'"
  }
  validation {
    condition = alltrue([
      for rule in var.reverse_proxy_rules : contains([true, false], rule.preserve)
    ])
    error_message = "Each preserve value must be either true or false"
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
