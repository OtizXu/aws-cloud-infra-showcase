# AWS Cloud Infrastructure Showcase

A historical Terraform module snapshot from the initial AWS architecture of [Vibe](https://vibe-ltd.net/), an independent cross-platform social application.

This repository documents how an early infrastructure extract separates networking, compute, data and access concerns into nine module directories. It contains selected source files, not the complete application, a turnkey deployment or the latest Vibe architecture.

## Repository scope

The useful starting point is the code: module inputs, resource definitions and outputs. Environment composition, application code, database migrations, deployment workflows and remote-state configuration are outside this extract.

This snapshot needs syntax, integration and security work before deployment. No production-readiness or current deployment claim is made for these files.

## Module map

| Module | Configuration present in this snapshot | Boundary to keep in mind |
| --- | --- | --- |
| [networking](modules/networking/) | VPC, availability-zone-indexed subnets and an internet gateway | Route tables, routes, NAT gateways and security groups are not defined here. |
| [ecs](modules/ecs/) | ECS cluster, Fargate task definition and service with `awsvpc` networking | Execution-role permissions, application task role, load-balancer attachment and autoscaling are not configured here. |
| [ecr](modules/ecr/) | Repositories created with `for_each`, immutable image tags and repository-URL outputs | Scanning and lifecycle policies are not explicitly configured here. |
| [alb](modules/alb/) | Application Load Balancer, target group and HTTP listener | HTTPS, path-based rules and ECS target registration are outside this extract. |
| [rds](modules/rds/) | Aurora PostgreSQL cluster, seven-day backup retention and credential-source selection | Cluster instances and database subnet-group configuration are not included. |
| [cache](modules/cache/) | Redis subnet group and replication group; automatic failover enabled when node count is at least two | Explicit cache security groups and encryption settings are not included. |
| [s3_cloudfront](modules/s3_cloudfront/) | S3 bucket, encryption, versioning, lifecycle rule and bucket policy for the CloudFront service principal | Despite the directory name, no CloudFront distribution or Origin Access Control is created. |
| [iam](modules/iam/) | GitHub Actions role with repository-and-branch-restricted OIDC subject matching | The OIDC provider is supplied as an input; the policy needs permission scoping and an audience condition review. |
| [secrets](modules/secrets/) | Secrets Manager secrets and versions from a map input | Rotation automation and service rollout orchestration are not included. |

## Architecture and delivery considerations

### Explicit module boundaries

Inputs such as subnet IDs, security groups, container definitions and an OIDC provider ARN make dependencies visible. A root configuration must still compose the modules and supply the missing integration pieces.

### Environment-aware configuration

Most modules accept `name_prefix` and `environment` inputs. These support naming conventions, but names alone do not isolate environments. Account boundaries, remote state, state locking and deployment approvals belong in the consuming configuration and delivery workflow.

### Repeatable resource definitions

ECR repositories and Secrets Manager entries use `for_each` over collection inputs. The ECS module accepts container definitions and service sizing as inputs. These are examples of expressing repeated configuration without duplicating resource blocks.

## Before adapting the code

Treat these files as an architecture reference that requires engineering review:

- Repair the existing HCL syntax errors in `modules/ecs/variables.tf`. A local `terraform fmt -check -recursive` check currently fails on three single-line variable blocks with multiple arguments.
- Review provider compatibility and outputs, including the Secrets Manager output's handling of a `for_each` resource map.
- Complete network routing, workload permissions, TLS and service-to-load-balancer integration.
- Scope IAM permissions, review OIDC trust conditions and restrict S3 access to the intended CloudFront distribution. Review data-service encryption, deletion protection and final-snapshot settings.
- Protect Terraform state: secret values supplied through Terraform can be stored in state. Marking a value sensitive does not remove it from state.
- Add a root configuration, version constraints and a lock file, then validate and test in an isolated account before considering a deployment.

No deployment verification accompanies this snapshot. This repository is a historical reference, not a maintained module library.

## About

I'm Otiz Xu, based in Taipei, Taiwan. I work in AWS Data Center Operations and contribute to InfraOps DevOps automation. Outside work, I founded Vibe and own its cloud architecture and delivery workflows.

This independent project is shared in a personal capacity. It is not an Amazon or AWS reference implementation.

[LinkedIn](https://www.linkedin.com/in/otiz0403/) · [Vibe](https://vibe-ltd.net/)

## License

[MIT](LICENSE). Retain the copyright and permission notice when redistributing the code, as required by the license.
