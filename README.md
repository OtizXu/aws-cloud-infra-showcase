# AWS Cloud Infrastructure Showcase

> Production-grade Terraform infrastructure modules powering a real-world cross-platform application — extracted as a public technical showcase.

[![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Multi--Service-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 What this is

This repository is a **public extract of the Terraform module structure** powering [Vibe](https://example.com) — a production cross-platform social application live on iOS App Store and Google Play. The full infrastructure (which I architected and operate as the sole engineer) runs entirely on AWS as 12 microservices behind 9 reusable Terraform modules.

This repo includes the **module sources only** (no production tfvars, account IDs, or secrets). Its purpose: demonstrate Terraform IaC patterns at production scale for prospective employers, hiring managers, and engineers who want to learn from working examples.

If you're hiring SRE / Platform Engineers and want to see real infrastructure code, **this repo is your fastest signal**.

---

## 📐 Architecture Overview

```
                                    ┌──────────────────┐
                                    │  Route 53 (DNS)  │
                                    └────────┬─────────┘
                                             │
                                    ┌────────▼─────────┐
                                    │   CloudFront     │
                                    │   (CDN, S3)      │
                                    └──────────────────┘

                                    ┌──────────────────┐
                                    │   Application    │
                                    │  Load Balancer   │
                                    └────────┬─────────┘
                                             │
                       ┌─────────────────────┼─────────────────────┐
                       │                     │                     │
              ┌────────▼────────┐  ┌─────────▼──────────┐ ┌────────▼────────┐
              │  ECS Fargate    │  │   ECS Fargate      │ │  ECS Fargate    │
              │  Service A      │  │   Service B  ...   │ │  Service N (×12)│
              └────────┬────────┘  └────────┬───────────┘ └────────┬────────┘
                       │                    │                      │
                       └────────────────────┼──────────────────────┘
                                             │
                       ┌─────────────────────┼─────────────────────┐
                       │                     │                     │
              ┌────────▼────────┐  ┌─────────▼──────────┐ ┌────────▼────────┐
              │   RDS Aurora    │  │ ElastiCache Redis  │ │ Secrets Manager │
              │  PostgreSQL 14  │  │  (cache + queues)  │ │  (rotation)     │
              │   Multi-AZ      │  │  Auto failover     │ │                 │
              └─────────────────┘  └────────────────────┘ └─────────────────┘
```

---

## 📦 Modules

| Module | Purpose | Highlights |
|---|---|---|
| **[networking](./modules/networking/)** | VPC, subnets, IGW, NAT | Multi-AZ public/private subnet design, security group segmentation |
| **[ecs](./modules/ecs/)** | ECS Fargate cluster + services | Task definitions, autoscaling, health checks, CloudWatch log drivers |
| **[ecr](./modules/ecr/)** | Container image registry | Vulnerability scanning (scanOnPush), AES256 encryption, image lifecycle |
| **[alb](./modules/alb/)** | Application Load Balancer | Path-based routing with priority-ordered listener rules (≈ K8s Ingress) |
| **[rds](./modules/rds/)** | Aurora PostgreSQL cluster | Multi-AZ, automated backups, Secrets Manager integration |
| **[cache](./modules/cache/)** | ElastiCache Redis | Replication group, automatic failover, cluster-mode-disabled |
| **[s3_cloudfront](./modules/s3_cloudfront/)** | Storage + CDN | Versioning, lifecycle policies, AES256, CORS, OAC |
| **[iam](./modules/iam/)** | IAM roles & policies | Least-privilege task roles, OIDC provider for GitHub Actions |
| **[secrets](./modules/secrets/)** | Secrets Manager | JWT rotation orchestration, coordinated rolling restarts |

---

## 🛠 Patterns Demonstrated

### 1. Modular Composition

Each module is **independently usable** — a downstream project can adopt only `networking` + `ecs` without pulling the rest. No tight coupling between modules; outputs are explicit and minimal.

### 2. Multi-Environment Infrastructure

The full project uses `environments/dev` and `environments/prod` separation, each backed by **its own S3 + DynamoDB remote state** (see [Terraform docs on state locking](https://developer.hashicorp.com/terraform/language/state/remote)).

### 3. Schema-per-Service Database Isolation

Single RDS Aurora cluster shared by **12 microservices**, but each service owns its own PostgreSQL schema. This pattern gives you:
- Cost efficiency of shared infra
- Independence of microservice DB evolution
- Clear ownership boundaries
- 34+ migrations across services with rollback strategy

### 4. JWT Secret Rotation Orchestration

Terraform `null_resource` provisioner triggers **coordinated rolling restarts** across all 12 ECS services when JWT secrets rotate. This avoids the classic problem of stale tokens accumulating during a partial rollout.

### 5. ALB as Kubernetes Ingress Equivalent

Path-based routing with **priority-ordered listener rules** functionally maps to K8s `Ingress` controllers:
- `Service A path /auth/*` → target group A (priority 100)
- `Service B path /chat/*` → target group B (priority 110)
- Default rule → marketing landing page

This makes the ECS Fargate ↔ Kubernetes mental model translation almost 1:1.

---

## 🚀 CI/CD Integration (Implementation Detail)

The full project uses **GitHub Actions** workflows for both:

- **Application deploys** — Matrix strategy across 11 microservices, intelligent change detection (only modified services build), AWS OIDC role assumption (no long-lived keys), ECR vulnerability scanning, ECS force-new-deployment with stability wait
- **Infrastructure deploys** — PR-triggered `terraform plan` for review, `workflow_dispatch` for controlled `terraform apply`, with format check, validation, and staged apply (core → ALB → services)

The workflows themselves are kept private to protect operational details, but the patterns are described in detail [in this LinkedIn post]() (link to your post once written).

---

## 🧠 Why I Open-Sourced the Module Layer

Three reasons:

1. **Show, don't tell** — When applying for SRE / Platform Engineering roles, "I built X with Terraform" carries less weight than "look at this code". This repo lets recruiters and engineers verify in 10 minutes what would otherwise take a 30-minute portfolio walkthrough.

2. **Pattern documentation > code** — The most valuable thing here isn't the HCL syntax; it's the **decisions**: which modules go in which boundary, how state is organized, how environments compose. These patterns generalize to any cloud-native production stack.

3. **Pay it forward** — When I started architecting Vibe's infra, I wished I had access to a real-world reference like this. If this saves another engineer 20 hours of trial-and-error, it pays back the half-day of cleanup work to publish.

---

## 🙋 About the Engineer

I'm Otiz Xu, a Site Reliability Engineer based in Taipei, Taiwan.

- **Currently:** AWS Data Center Operations Technician (L3) + concurrent SRE in InfraOps DevOps function team
- **Previously:** IT Operations consultant for Google Taiwan offices via Astreya, systems integration engineer for AV infrastructure, live production engineer for events / broadcast
- **Networking:** Cisco Certified Network Associate (CCNA)
- **Side projects:** Vibe (production cloud app) — sole engineer responsible for full SRE lifecycle: IaC, CI/CD, observability, incident response

If you're hiring SRE / Platform / Cloud Infrastructure roles, I'd love to connect.

🔗 [LinkedIn](https://linkedin.com/in/otiz0403)

---

## 📜 License

MIT. Use these modules as starting points for your own infrastructure. Attribution appreciated but not required.

---

## ⚠️ Important Notes

- This repo contains **module sources only**. Production `terraform.tfvars`, `backend.tf` configurations with real AWS account IDs, GitHub Actions workflows with deployment secrets, and other operational details are **not** included.
- The modules here are extracted snapshots; they may not be the absolute latest version running in production.
- This repo is a technical showcase, not a maintained library. Issues and PRs are welcome but not actively monitored.
