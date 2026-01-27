## Create a KMS (Key Management Service) key for SOPS
resource "aws_kms_key" "sops_key" {
  description             = "KMS key for SOPS"
  deletion_window_in_days = 10
  policy = jsonencode(
    {
      Id = "key-default-1"
      Statement = [
        {
          Action = "kms:*"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::504922188932:root"
          }
          Resource = "*"
          Sid      = "Enable IAM User Permissions"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    Name = var.sops_kms_key_name
  }
}

resource "aws_kms_alias" "sops_key_alias" {
  name          = "alias/${var.sops_kms_key_name}"
  target_key_id = aws_kms_key.sops_key.id
}