############################################################
# Terraform Bootstrap — Windows
# Installs Docker, kubectl, Minikube, Helm, VPA
############################################################

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "null" {}

############################################################
# Install Chocolatey (Windows package manager)
############################################################

resource "null_resource" "install_chocolatey" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
EOT
  }
}

############################################################
# Install Docker Desktop
############################################################

resource "null_resource" "install_docker" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "choco install docker-desktop -y"
  }

  depends_on = [
    null_resource.install_chocolatey
  ]
}

############################################################
# Install kubectl
############################################################

resource "null_resource" "install_kubectl" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "choco install kubernetes-cli -y"
  }

  depends_on = [
    null_resource.install_chocolatey
  ]
}

############################################################
# Install Minikube
############################################################

resource "null_resource" "install_minikube" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "choco install minikube -y"
  }

  depends_on = [
    null_resource.install_chocolatey
  ]
}

############################################################
# Install Helm
############################################################

resource "null_resource" "install_helm" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "choco install kubernetes-helm -y"
  }

  depends_on = [
    null_resource.install_chocolatey
  ]
}

############################################################
# Start Minikube Cluster
############################################################

resource "null_resource" "start_minikube" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "minikube start --driver=docker"
  }

  depends_on = [
    null_resource.install_docker,
    null_resource.install_minikube,
    null_resource.install_kubectl
  ]
}

############################################################
# Install Metrics Server (needed for autoscaling)
############################################################

resource "null_resource" "metrics_server" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "minikube addons enable metrics-server"
  }

  depends_on = [
    null_resource.start_minikube
  ]
}

############################################################
# Install VPA via Helm
############################################################

resource "null_resource" "install_vpa" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
helm repo add autoscaler https://kubernetes.github.io/autoscaler;
helm repo update;
helm install vpa autoscaler/vertical-pod-autoscaler --namespace kube-system --create-namespace;
kubectl get pods -n kube-system;
EOT
  }

  depends_on = [
    null_resource.install_helm,
    null_resource.start_minikube
  ]
}
