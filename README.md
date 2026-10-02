# EKS Platform: Terraform + GitOps + Full-Stack Observability

**What this demonstrates:** Terraform module design, AWS networking/IAM, EKS operations, GitOps deployment,
and production observability with Dynatrace + Splunk. This is the flagship repo — link it first on your resume.

## Architecture
```
Internet -> ALB -> EKS (private subnets) -> Sample App (Helm) -> RDS (private subnet)
                       |                         |
                  ArgoCD (GitOps sync)      Dynatrace OneAgent (traces/APM)
                                             Splunk Forwarder (logs)
```

## Stack
- **Terraform**: VPC, EKS cluster + managed node groups, RDS, IRSA (IAM Roles for Service Accounts)
- **Helm**: sample app chart (deployment, service, ingress, HPA)
- **ArgoCD**: GitOps sync from this repo to the cluster
- **Dynatrace**: OneAgent operator for full-stack APM
- **Splunk**: log forwarder as a DaemonSet

## How to run
```bash
cd terraform/environments/dev
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan

aws eks update-kubeconfig --name <cluster-name> --region us-east-1
kubectl apply -f ../../../argocd/application.yaml
```

## What to write up as a postmortem-style README section (do this after you build it)
- One deliberate failure you hit (e.g., IRSA trust policy misconfig, CIDR overlap) and how you diagnosed it
- A before/after screenshot of the Dynatrace or Grafana dashboard
- Cost of running this for a week (tie into project #5, FinOps)

## Resume bullet template
"Designed and provisioned a production-pattern EKS platform using Terraform (VPC, IRSA, managed node groups),
deployed via GitOps (ArgoCD), instrumented with Dynatrace APM and Splunk log forwarding for full-stack observability."
