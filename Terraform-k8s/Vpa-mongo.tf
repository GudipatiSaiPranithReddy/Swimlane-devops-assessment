resource "kubernetes_manifest" "mongo_vpa" {
  manifest = {
    apiVersion = "autoscaling.k8s.io/v1"
    kind       = "VerticalPodAutoscaler"

    metadata = {
      name      = "mongo-vpa"
      namespace = "swimlane"
    }

    spec = {
      targetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = "mongo"
      }

      updatePolicy = {
        updateMode = "Auto"
      }

      resourcePolicy = {
        containerPolicies = [
          {
            containerName = "mongo"
            minAllowed = {
              cpu    = "100m"
              memory = "128Mi"
            }
            maxAllowed = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
        ]
      }
    }
  }
}
