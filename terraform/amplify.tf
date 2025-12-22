# This Terraform resource defines an AWS Amplify application for hosting a Next.js frontend.
# AWS Amplify provides a fully managed hosting service for web applications with automatic
# deployments, custom domains, and SSL certificates.
#
# Key features:
#   - Manual branch creation (auto-branch-creation disabled)
#   - Automatic branch deletion when branches are removed
#   - Next.js SSR support (WEB_COMPUTE platform)
#   - Custom build specification for npm-based builds
#   - SPA routing support (404 -> 200 redirect to index.html)
#
# Build process:
#   1. Pre-build: Installs dependencies using npm ci
#   2. Build: Compiles the Next.js application
#   3. Artifacts: Deploys files from .next directory
#   4. Cache: Caches node_modules and .next/cache for faster builds
#
resource "aws_amplify_app" "frontend" {
  name                        = "frontend"
  repository                  = "https://github.com/example/frontend"
  description                 = "Frontend - Next.js web application"
  enable_auto_branch_creation = false
  enable_basic_auth           = false
  enable_branch_auto_build    = false
  enable_branch_auto_deletion = true
  iam_service_role_arn        = "arn:aws:iam::************:role/service-role/AmplifySSRLoggingRole-************"
  platform                    = "WEB_COMPUTE"
  build_spec                  = <<-EOT
        ---
        version: 1  # Specifies the AWS Amplify build specification version

        frontend:
          phases:
            preBuild:
              commands:
                - npm ci --prefer-offline  # Installs dependencies using package-lock.json (faster & consistent)
            build:
              commands:
                - npm run build  # Builds the project (compiles Next.js app)
        
          artifacts:
            baseDirectory: .next  # Specifies the directory where the built files are stored
            files:
              - '**/*'  # Includes all files from the .next directory for deployment
        
          cache:
            paths:
              - node_modules/**  # Caches installed dependencies to speed up future builds
              - .next/cache/**/*  # Caches Next.js build artifacts to optimize incremental builds
        ...
    EOT
  environment_variables = {
    "EXAMPLE_VARIABLE"    = "example-value"

    # Non-secret configuration
    "ENV"              = "dev"
    "NEXT_DISABLE_SSR" = "1"
    "_BUILD_TIMEOUT"   = "15"
  }
  auto_branch_creation_patterns = []
  custom_rule {
    condition = null
    source    = "/<*>"
    status    = "404-200"
    target    = "index.html"
  }

  custom_headers = null
}