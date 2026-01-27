# Reverse Proxy Module

A standalone Terraform module for deploying a highly available reverse proxy infrastructure on AWS using Apache HTTP Server.

## Features

- **Isolated VPC**: Dedicated VPC with private and public subnets
- **High Availability**: Multi-AZ deployment with Auto Scaling Group
- **Application Load Balancer**: Internet-facing ALB with HTTPS termination
- **Apache Reverse Proxy**: Configurable proxy rules for routing traffic
- **WAF Integration**: Optional AWS WAFv2 Web ACL association
- **Logging**: ALB access logs to S3 and optional Promtail for log shipping to Loki
- **Security**: Security groups, SSL/TLS termination, and IAM roles
- **Input Validation**: Comprehensive validation blocks for all variables to catch errors early

## Architecture

```
Internet
    ↓
Application Load Balancer (ALB)
    ↓
WAF (Optional)
    ↓
Target Group
    ↓
Auto Scaling Group
    ↓
EC2 Instances (Apache Reverse Proxy)
    ↓
NAT Gateway
    ↓
Backend Services
```

## Usage

```hcl
module "reverse_proxy" {
  source = "./reverse-proxy"

  name_prefix              = "my-app"
  environment              = "prod"
  vpc_cidr                 = "10.20.0.0/16"
  instance_type            = "t3.medium"
  key_name                 = "my-key-pair"
  ssm_instance_profile_name = "my-ssm-profile"
  
  certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
  backend_url     = "https://backend.example.com"
  
  reverse_proxy_rules = [
    {
      path     = "/app"
      backend  = "https://backend.example.com/app"
      preserve = true
    },
    {
      path     = "/"
      backend  = "https://backend.example.com/"
      preserve = true
    }
  ]

  # Optional: Enable Promtail for log shipping
  enable_promtail = true
  loki_host       = "loki"
  loki_domain     = "example.com"
  
  # Optional: Associate WAF
  waf_web_acl_arn = "arn:aws:wafv2:region:account:webacl/name/id"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.2 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| null | >= 3.2.3 |

## Input Validation

The module implements comprehensive input validation to catch configuration errors early. All variables include validation blocks that enforce:

- **Naming Conventions**: Resource names must follow AWS naming requirements (lowercase, alphanumeric, hyphens)
- **Format Validation**: URLs, ARNs, CIDR blocks, and other structured values are validated for correct format
- **Range Validation**: Numeric values are validated against AWS service limits (e.g., availability zones: 1-6, instance counts: 0-1000)
- **Type Validation**: Boolean and enum values are validated to ensure only valid options are provided
- **Length Validation**: String lengths are validated to prevent AWS service errors

**Example validation rules:**
- `name_prefix`: Must be lowercase, start with a letter, 1-20 characters
- `vpc_cidr`: Must be a valid CIDR block format (e.g., 10.0.0.0/16)
- `certificate_arn`: Must match ACM certificate ARN format
- `backend_url`: Must start with `http://` or `https://`
- `availability_zone_count`: Must be between 1 and 6
- `instance_type`: Must match EC2 instance type pattern (e.g., t3.medium)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names (lowercase, alphanumeric, hyphens, 1-20 chars) | `string` | n/a | yes |
| environment | Environment name (e.g., prod, staging, dev) (lowercase, alphanumeric, hyphens, 2-20 chars) | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC (must be valid CIDR format) | `string` | n/a | yes |
| key_name | Name of the AWS key pair to use for EC2 instances (1-255 chars) | `string` | n/a | yes |
| ssm_instance_profile_name | Name of the IAM instance profile for SSM access (1-128 chars) | `string` | n/a | yes |
| certificate_arn | ARN of the ACM certificate to use for HTTPS (must be valid ACM ARN) | `string` | n/a | yes |
| backend_url | Backend URL to proxy requests to (must start with http:// or https://) | `string` | n/a | yes |
| availability_zone_count | Number of availability zones to use (1-6) | `number` | `3` | no |
| instance_type | EC2 instance type for reverse proxy servers (e.g., t3.medium) | `string` | `t3.medium` | no |
| desired_capacity | Desired number of instances in the Auto Scaling Group (0-1000) | `number` | `2` | no |
| max_size | Maximum number of instances in the Auto Scaling Group (1-1000) | `number` | `4` | no |
| min_size | Minimum number of instances in the Auto Scaling Group (0-1000) | `number` | `1` | no |
| health_check_grace_period | Time (in seconds) after instance comes into service before checking health (0-7200) | `number` | `300` | no |
| health_check_path | Path for health checks (must start with /) | `string` | `"/"` | no |
| health_check_interval | Approximate amount of time between health checks (5-300 seconds) | `number` | `30` | no |
| health_check_timeout | Amount of time during which no response means a failed health check (2-120 seconds) | `number` | `5` | no |
| health_check_healthy_threshold | Number of consecutive health check successes required (2-10) | `number` | `5` | no |
| health_check_unhealthy_threshold | Number of consecutive health check failures required (2-10) | `number` | `2` | no |
| health_check_matcher | HTTP codes to use when checking for a healthy response (comma-separated, e.g., "200,301,302") | `string` | `"200,301,302,404"` | no |
| instance_refresh_min_healthy_percentage | Minimum percentage of instances that must remain healthy during instance refresh (0-100) | `number` | `50` | no |
| instance_refresh_warmup | Number of seconds until a newly launched instance is configured and ready to use (0-3600) | `number` | `300` | no |
| enable_deletion_protection | Enable deletion protection on the ALB | `bool` | `true` | no |
| idle_timeout | Time in seconds that the connection is allowed to be idle (1-4000) | `number` | `180` | no |
| enable_alb_access_logs | Enable access logging for the Application Load Balancer | `bool` | `false` | no |
| log_retention_days | Number of days to retain logs in S3 (1-3650) | `number` | `90` | no |
| ssl_policy | SSL policy to use for HTTPS listener (must start with ELBSecurityPolicy-) | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| waf_web_acl_arn | ARN of the WAF Web ACL to associate with the ALB (optional, must be valid WAFv2 ARN) | `string` | `null` | no |
| reverse_proxy_rules | List of reverse proxy rules in Apache ProxyPass format | `list(object({path=string, backend=string, preserve=optional(bool, true)}))` | `[]` | no |
| enable_promtail | Enable Promtail for log shipping to Loki | `bool` | `false` | no |
| loki_host | Loki hostname (without domain) for log shipping (lowercase, alphanumeric, hyphens) | `string` | `""` | no |
| loki_domain | Loki domain for log shipping (e.g., example.com) | `string` | `""` | no |
| log_name | Name prefix for log files (lowercase, alphanumeric, underscores, 1-50 chars) | `string` | `"reverse_proxy"` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name | DNS name of the Application Load Balancer |
| alb_arn | ARN of the Application Load Balancer |
| alb_zone_id | Zone ID of the Application Load Balancer (for Route53 alias records) |
| target_group_arn | ARN of the target group |
| vpc_id | ID of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| private_subnet_ids | List of private subnet IDs |
| public_subnet_ids | List of public subnet IDs |
| nat_gateway_public_ips | List of public IPs of the NAT Gateways |
| security_group_id | ID of the security group |
| autoscaling_group_name | Name of the Auto Scaling Group |
| launch_template_id | ID of the launch template |
| logs_bucket_id | ID of the S3 bucket for logs |

## Reverse Proxy Rules

The `reverse_proxy_rules` variable accepts a list of objects with the following structure:

```hcl
reverse_proxy_rules = [
  {
    path     = "/app"                    # Path to match
    backend  = "https://backend.com/app" # Backend URL
    preserve = true                       # Whether to preserve path (default: true)
  }
]
```

Each rule will create Apache `ProxyPass` and `ProxyPassReverse` directives.

## Logging

### ALB Access Logs

Access logs are stored in an S3 bucket with the following naming:
- Bucket: `{name_prefix}-{environment}-logs`
- Prefix: `alb-logs/`
- Retention: Configurable (default: 90 days)

### Promtail Integration

If `enable_promtail` is set to `true`, Promtail will be installed and configured to ship logs to Loki:
- Access logs: `/var/log/httpd/{log_name}_access.log`
- Error logs: `/var/log/httpd/{log_name}_error.log`

## WAF Integration

To associate a WAF Web ACL with the ALB, provide the `waf_web_acl_arn` variable:

```hcl
waf_web_acl_arn = "arn:aws:wafv2:region:account:webacl/name/id"
```

## NAT Gateway IPs

The module outputs NAT Gateway public IPs which can be used to:
- Whitelist in external systems
- Add to WAF IP sets
- Configure firewall rules

## Best Practices

- **Naming**: Use lowercase, descriptive prefixes that follow AWS naming conventions
- **Validation**: All inputs are validated - ensure your values meet the validation requirements
- **High Availability**: Deploy across multiple availability zones (minimum 2, recommended 3)
- **Security**: 
  - Enable deletion protection for production environments
  - Use WAF for additional security layers
  - Keep SSL policies up to date
- **Monitoring**: Enable ALB access logs and consider Promtail for centralized logging
- **Scaling**: Configure appropriate min/max/desired capacity based on your traffic patterns
- **Health Checks**: Tune health check parameters based on your application response times
- **Tags**: Apply consistent tagging strategy for resource management and cost tracking

## Examples

See the `examples/` directory for complete usage examples.

## Troubleshooting

### Common Validation Errors

- **Name prefix/environment errors**: Ensure values are lowercase and follow the naming pattern
- **CIDR errors**: Verify the CIDR block is in correct format (e.g., 10.0.0.0/16)
- **ARN errors**: Check that ARNs match the expected format for ACM certificates or WAF Web ACLs
- **URL errors**: Ensure backend URLs start with `http://` or `https://`

### Common Deployment Issues

- **Instance launch failures**: Verify the key pair and SSM instance profile exist
- **Health check failures**: Check security group rules and backend connectivity
- **ALB access log errors**: Verify S3 bucket permissions for ALB log delivery

## License

This module is provided as-is for use in your infrastructure.
