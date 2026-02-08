## Prerequisites & Setup Guide

This project includes Terraform bootstrap automation to install all required Kubernetes tooling on Windows.

---

### Prerequisites

Ensure the following before running Terraform:

* **Windows 10 / 11 (64-bit)**
* **Administrator PowerShell access**
* **Terraform CLI installed** and added to PATH
  Verify:

  ```
  terraform version
  ```
* **Virtualization enabled** (WSL2 or Hyper-V)
* **Internet connectivity** for downloading packages

---

## Step 1 — Bootstrap Environment

Run PowerShell as Administrator:

Repo file : bootstrap-windows.tf

```
terraform init
terraform apply -auto-approve
```

This installs automatically:

* Docker Desktop
* kubectl
* Minikube
* Helm
* Metrics Server
* Vertical Pod Autoscaler (VPA)

If Docker installation requires reboot, restart the system and rerun:

```
terraform apply
```

---

## Step 2 — Start Cluster

```
minikube start --driver=docker
kubectl get nodes
```

---

## Step 3 — Build Application Image

Point Docker to Minikube:

```
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Build image:

```
docker build -t swimlane-app:latest .
```

---

## Step 4 — Push Image to Docker Hub (Optional / Recommended)

If deploying beyond local Minikube or for portability, push the image to Docker Hub.

### 1. Login to Docker Hub

```
docker login
```

Enter Docker Hub username and password.

---

### 2. Tag the Image

Replace `<dockerhub-username>` with your account.

```
docker tag swimlane-app:latest <dockerhub-username>/swimlane-app:latest
```

Example:

```
docker tag swimlane-app:latest johndoe/swimlane-app:latest
```

---

### 3. Push Image

```
docker push <dockerhub-username>/swimlane-app:latest
```

---

## Step 5 — Update Terraform Deployment Image

In your Terraform deployment resource, update the container image reference.

### Terraform Snippet

```
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "swimlane-app"
    namespace = "swimlane"
  }

  <<--------
  ----------
  --------
  -------
  >>

          # Updated Docker Hub image
          image = "<dockerhub-username>/swimlane-app:latest"

          image_pull_policy = "Always"



Replace with your repo:

```
image = "johndoe/swimlane-app:latest"
```

---

## Step 6 — Deploy via Terraform

```
Switch to Dir : devops-practical\Terraform-k8s
terraform init
terraform apply -auto-approve
```

This deploys:

* MongoDB
* Swimlane Application
* Services
* HPA (App)
* VPA (MongoDB)

---

## Step 7 — Access Application

```
minikube service swimlane-service -n swimlane
```

Or:

```
minikube ip
```

Open:

```
http://<minikube-ip>:30007
```

---

Application is now fully deployed and accessible.

=========================================================================================================
What Was Taken Care Of in This Setup

End-to-End Containerization

Infrastructure as Code (IaC)

Automated Bootstrap (Windows)
Docker, Minikube, kubectl, Helm, Metrics Server, and VPA installed automatically → reduces manual setup errors.

Namespace Isolation

Secrets Handling Design

Resource Requests & Limits

CPU/memory boundaries defined → stable scheduling and autoscaler accuracy.

Autoscaling Strategy

HPA for stateless Node.js app

VPA for stateful MongoDB
→ aligned with production scaling patterns.



🚀 Advantages of This Architecture

Reproducible Deployments
One Terraform apply → full environment + workloads.

Environment Consistency

Scalability Ready

High Developer Productivity

Cloud Migration Friendly

Fault Isolation

Cost Efficient (Local)

Security Extensible

Can integrate:

AWS Secrets Manager

HashiCorp Vault

Observability Ready

Disaster Recovery Ready Design

======================================================================================================

➕ Additional Enhancements & Production Considerations

Enterprise Secret Management

HashiCorp Vault for on-prem / self-managed Kubernetes clusters

AWS Secrets Manager for cloud deployments on EKS

Cloud Production Deployment (EKS)

For production-grade workloads, the application stack can be deployed to Amazon EKS

Multi-Availability Zone High Availability

Deployment models include:

Active-Active
Workloads run simultaneously across zones with load balancing for maximum uptime and performance.

Active-Passive
Secondary zone remains on standby for failover, reducing infrastructure cost while maintaining disaster recovery readiness.

Event-Driven Autoscaling with KEDA
Kubernetes Event-Driven Autoscaling (KEDA) can be implemented to scale application pods based on external event sources such as:

We can implement multiple SRE design principles like Circuit Breakers ,Rate limiting, fail fast, Load shedding etc., 

Cost Optimization Strategies
Combining KEDA, Active-Passive zoning, and vertical scaling for stateful services enables optimized resource utilization and reduced cloud spend.

Extensible Security & Compliance Layer
Integration with Vault / AWS Secrets Manager supports audit logging, RBAC enforcement, and compliance-ready secret governance.