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

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "swimlane"
      }
    }

    template {
      metadata {
        labels = {
          app = "swimlane"
        }
      }

      spec {
        container {
          name  = "app"

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
Kubernetes resources and cluster components deployed via Terraform → reproducible and version-controlled infra.

Automated Bootstrap (Windows)
Docker, Minikube, kubectl, Helm, Metrics Server, and VPA installed automatically → reduces manual setup errors.

Namespace Isolation
Dedicated swimlane namespace → logical separation and easier resource governance.

Secrets Handling Design
Sensitive values structured to be externalized (e.g., Docker Hub creds, DB creds, AWS Secrets Manager in cloud design).

Resource Requests & Limits
CPU/memory boundaries defined → stable scheduling and autoscaler accuracy.

Autoscaling Strategy

HPA for stateless Node.js app

VPA for stateful MongoDB
→ aligned with production scaling patterns.

Service Exposure Control
NodePort used locally → simple external access without public LB cost.

Image Portability
Docker Hub push capability → enables cluster portability beyond Minikube.

Helm Addon Management
VPA and cluster plugins managed via Helm → upgradeable and modular.

🚀 Advantages of This Architecture

Reproducible Deployments
One Terraform apply → full environment + workloads.

Environment Consistency
Same images/manifests run locally and in cloud (EKS-ready design).

Scalability Ready
Horizontal scaling for app, vertical tuning for DB.

High Developer Productivity
Bootstrap automation removes manual dependency installs.

Cloud Migration Friendly
Design easily portable to EKS/GKE/AKS.

Fault Isolation
Namespace + pod replicas reduce blast radius.

Cost Efficient (Local)
Minikube avoids cloud cost while testing production patterns.

Security Extensible
Can integrate:

AWS Secrets Manager

HashiCorp Vault

IRSA roles

Observability Ready
Metrics Server already installed → can extend to Prometheus/Grafana.

Disaster Recovery Ready Design
Terraform redeploy + image registry enables rapid cluster rebuild.

======================================================================================================

➕ Additional Enhancements & Production Considerations

Enterprise Secret Management
Secrets can be externalized from Kubernetes and stored securely using:

HashiCorp Vault for on-prem / self-managed Kubernetes clusters

AWS Secrets Manager for cloud deployments on EKS
This enables encrypted storage, dynamic secret rotation, and centralized access control.

Cloud Production Deployment (EKS)
For production-grade workloads, the application stack can be deployed to Amazon EKS, leveraging managed Kubernetes control planes, automated upgrades, and native AWS integrations.

Multi-Availability Zone High Availability
The EKS cluster can span multiple Availability Zones to eliminate single points of failure and improve resiliency.

Deployment models include:

Active-Active
Workloads run simultaneously across zones with load balancing for maximum uptime and performance.

Active-Passive
Secondary zone remains on standby for failover, reducing infrastructure cost while maintaining disaster recovery readiness.

Event-Driven Autoscaling with KEDA
Kubernetes Event-Driven Autoscaling (KEDA) can be implemented to scale application pods based on external event sources such as:

Message queues

Kafka topics

Prometheus metrics

HTTP traffic spikes

This allows:

Fine-grained scaling

Faster reaction to demand

Improved cost efficiency compared to CPU-only HPA scaling

Cost Optimization Strategies
Combining KEDA, Active-Passive zoning, and vertical scaling for stateful services enables optimized resource utilization and reduced cloud spend.

Extensible Security & Compliance Layer
Integration with Vault / AWS Secrets Manager supports audit logging, RBAC enforcement, and compliance-ready secret governance.