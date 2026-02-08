resource "kubernetes_horizontal_pod_autoscaler_v2" "swimlane_hpa" {
  metadata {
    name      = "swimlane-hpa"
    namespace = "swimlane"
  }

  spec {
    min_replicas = 2
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "swimlane-app"
    }

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}
