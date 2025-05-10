# Capstone Project: EKS Cluster Provisioning and Application Deployment

## Overview

This project provisions an end-to-end Kubernetes infrastructure on AWS using Terraform, and deploys essential services using Helm in a staged approach:

* **Stage 1** provisions the AWS infrastructure, EKS cluster, networking, and security setup.
* **Stage 2** installs ArgoCD, Prometheus Stack, and Grafana using Helm and deploys the application via ArgoCD.

---

## 🔧 Stage 1: Infrastructure Provisioning

### Prerequisites

Ensure you have the following installed:

* Terraform >= 1.3
* AWS CLI configured with credentials and profile
* kubectl

### Directory Structure

```
stage-1/
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

### What This Stage Does

* Generates an SSH key pair using `tls` and `local_file`
* Creates a VPC with public and private subnets
* Provisions an EKS cluster with managed node groups
* Applies necessary IAM roles and security groups
* Outputs the cluster endpoint and kubeconfig readiness

### How to Run

```bash
cd stage-1
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Post-Apply Setup

Update your local kubeconfig:

```bash
aws eks update-kubeconfig --region us-east-1 --name capstone-cluster --profile default
```

---

## 🚀 Stage 2: Helm Deployments

### Prerequisites

* kubeconfig must be pointing to the newly created cluster
* Helm must be installed

### Directory Structure

```
stage-2/
├── main.tf
├── argocd-app.yaml
├── argo-values.yaml
└── prometheus-values.yaml
```

### What This Stage Does

* Installs ArgoCD with a LoadBalancer service
* Installs Prometheus Stack and Grafana in the `monitoring` namespace
* Configures basic resource limits for ArgoCD components
* Deploys an application from GitHub using ArgoCD

### How to Run

```bash
cd stage-2
terraform init
terraform plan
terraform apply
```

### Expose ArgoCD UI

Once ArgoCD is deployed, retrieve the LoadBalancer hostname:

```bash
kubectl get svc -n argocd
```

Access ArgoCD in your browser using the external URL.

Get the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### ArgoCD Application Deployment

The application is defined in `argocd-app.yaml`:

```yaml
  repoURL: https://github.com/josephifekwe97/Capstone-Project-FEB-2025.git
  path: k8/_overlays/
```

You can apply it manually if needed:

```bash
kubectl apply -f argocd-app.yaml
```

### Expose Prometheus and Grafana

```bash
kubectl get svc -n monitoring
```

Log in to Grafana using:

* **User**: admin
* **Password**: securepassword

---

## 🔐 Notes

* Make sure you secure the generated `eks-key.pem` file.
* Ensure IAM policies and roles are appropriately scoped for production.
* Avoid exposing services using `LoadBalancer` with unrestricted public access in production environments.

---

## 🧹 Teardown

To destroy the infrastructure and all Helm charts:

```bash
cd stage-2
terraform destroy
cd ../stage-1
terraform destroy -var-file="terraform.tfvars"
```

---