# Basic Example

This example shows how to deploy a basic reverse proxy infrastructure.

## Prerequisites

- Terraform >= 1.5.2
- AWS CLI configured with appropriate credentials
- An existing ACM certificate in the target region
- An existing AWS key pair for EC2 instances
- An existing IAM instance profile with SSM permissions

## Usage

1. Update `variables.tf` or create a `terraform.tfvars` file with your values:

**Important:** All values must meet the module's validation requirements:
- `name_prefix`: lowercase, alphanumeric, hyphens only (1-20 chars)
- `environment`: lowercase, alphanumeric, hyphens only (2-20 chars)
- `vpc_cidr`: valid CIDR format (e.g., 10.20.0.0/16)
- `certificate_arn`: valid ACM certificate ARN
- `backend_url`: must start with `http://` or `https://`

```hcl
aws_region                = "eu-west-1"
name_prefix               = "my-app"
environment               = "prod"
vpc_cidr                  = "10.20.0.0/16"
instance_type             = "t3.medium"
key_name                  = "my-key-pair"
ssm_instance_profile_name = "my-ssm-profile"
certificate_domain        = "*.example.com"
backend_url               = "https://backend.example.com"

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

tags = {
  Environment = "production"
  Project     = "my-project"
}
```

2. Initialize and validate:

```bash
terraform init
terraform validate
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

## Validation

The module includes comprehensive input validation. If you encounter validation errors:

- **Name prefix/environment**: Ensure lowercase, no special characters except hyphens
- **CIDR**: Verify format is correct (e.g., `10.20.0.0/16`)
- **ARNs**: Check that certificate ARN matches ACM format
- **URLs**: Ensure backend URLs start with `http://` or `https://`

## Outputs

After applying, you can get the ALB DNS name:

```bash
terraform output alb_dns_name
```

Use this DNS name to configure your DNS records or external systems.

Other useful outputs:
- `alb_zone_id`: For Route53 alias records
- `nat_gateway_public_ips`: For whitelisting in external systems
- `vpc_id`: For VPC peering or other networking configurations
- `security_group_id`: For additional security group rules
