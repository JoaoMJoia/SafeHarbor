# ECS (Elastic Container Service) – Backend

This folder holds the AWS ECS configuration used to run the backend on **Fargate**.

## Structure

```
backend/ecs/
└── webserver/
    └── task_definition.json   # ECS Fargate task definition for the app container
```

## Task definition

**File:** `webserver/task_definition.json`

Defines a single Fargate task that runs the backend app container:

- **Family:** `___APPLICATION_NAME___-ecs-webserver-task` (replaced at deploy time)
- **Container:** `backend-app`
- **Resources:** 512 CPU, 1024 MB memory
- **Port:** 80 (HTTP)
- **Network:** `awsvpc`

### Placeholders (replaced by CI)

These placeholders are substituted by the CD workflow (e.g. `.github/workflows/cd-dev-s3-fargate.yaml`) before registering the task definition:

| Placeholder            | Description                    | Example / source                    |
|------------------------|--------------------------------|-------------------------------------|
| `___APPLICATION_NAME___` | Backend app name               | e.g. `example-dev-backend`          |
| `___APP_URL___`        | Public URL of the backend      | From `APP_URL` env in workflow      |
| `___AWS_REGION___`     | AWS region                     | From `vars.AWS_REGION`              |
| `___AWS_ACCOUNT_ID___` | AWS account ID                 | From `secrets.AWS_ACCOUNT_ID`       |

The container **image** is left empty in the JSON and is set by the workflow when building and pushing the image to ECR.

## Environment variables

The task definition sets many environment variables for the backend app.
Sensitive values are not in the JSON; they come from **AWS Secrets Manager** and **SSM Parameter Store** (see below).

## Secrets (AWS Secrets Manager / SSM)

The task pulls these at runtime:

| Secret/parameter name pattern | Used as env var   | Store        |
|------------------------------|-------------------|-------------|
| `___APPLICATION_NAME___:APP_KEY` | `APP_KEY`         | Secrets Manager |
| `___APPLICATION_NAME___:REDIS_HOST` | `REDIS_HOST`   | Secrets Manager |
| `___APPLICATION_NAME___:REDIS_PASSWORD` | `REDIS_PASSWORD` | Secrets Manager |
| `___APPLICATION_NAME___:DB_DATABASE` | `DB_DATABASE` | Secrets Manager |
| `___APPLICATION_NAME___:DB_HOST` | `DB_HOST`       | Secrets Manager |
| `___APPLICATION_NAME___/database/password/master` | `DB_PASSWORD` | SSM Parameter Store |

Replace `___APPLICATION_NAME___` with the same value used in the task family. These secrets/parameters must exist in the target account/region before the task can start.

## IAM roles

The task uses two roles (ARNs in the JSON use `___AWS_ACCOUNT_ID___` and `___APPLICATION_NAME___`):

- **Execution role:** `___APPLICATION_NAME___-ecs-task-execution-role`  
  - Used to pull the image, fetch secrets/parameters, and write logs.
- **Task role:** `___APPLICATION_NAME___-ecs-task-role`  
  - Used by the running app (e.g. S3, other AWS APIs).

These roles must exist and have the right policies in the target account.

## Logging

- **Log driver:** `awslogs`
- **Log group:** `___APPLICATION_NAME___-ecs-webserver-logs`
- **Stream prefix:** `___APPLICATION_NAME___-app`
- **Region:** `___AWS_REGION___`

Ensure the log group exists (or is created by your IaC) and that the execution role has permission to create log streams and write logs.

## Health check

The container has a health check:

- **Command:** `curl -f http://localhost/health || exit 1`
- **Interval:** 30s  
- **Timeout:** 5s  
- **Retries:** 3  
- **Start period:** 60s  

The backend app must expose a `/health` endpoint that returns HTTP 200 when the app is healthy.

## How CI uses this

The **CD - Dev** workflow (e.g. `.github/workflows/cd-dev-s3-fargate.yaml`):

1. Runs with **backend working directory** `backend` and uses **task definition path** `ecs/webserver/task_definition.json` (relative to `backend/`).
2. Builds the Docker image from `backend/Dockerfile` (target `prod`) and pushes it to ECR.
3. Replaces all `___*___` placeholders in `backend/ecs/webserver/task_definition.json`.
4. Injects the new ECR image into the task definition for the `backend-app` container.
5. Registers the task definition and updates the ECS service:
   - **Cluster:** `___APPLICATION_NAME___-ecs-cluster`
   - **Service:** `___APPLICATION_NAME___-ecs-webserver-service`

So this single task definition file is the source of truth for both the app container and the way CI deploys it; any change to placeholders or structure should be reflected here and in the workflow if needed.

## Prerequisites for a new environment

For a new environment (e.g. staging/prod) you typically need:

1. **ECR repository** named like `___APPLICATION_NAME___`.
2. **ECS cluster** and **Fargate service** (e.g. `___APPLICATION_NAME___-ecs-cluster` and `___APPLICATION_NAME___-ecs-webserver-service`).
3. **Secrets** in Secrets Manager and **DB password** in SSM as in the table above.
4. **IAM roles**: task execution role and task role with correct trust and policies.
5. **CloudWatch log group** for `___APPLICATION_NAME___-ecs-webserver-logs`.
6. **VPC / networking** so the service can reach RDS, ElastiCache (Redis), and the internet if needed (e.g. for Composer/ECR).

These are usually provisioned with Terraform or another IaC tool; the task definition in this repo is then used by CI to deploy the container image and configuration.
