resource "kubernetes_deployment" "app" {
  metadata {
    name      = "swimlane-app"
    namespace = kubernetes_namespace.swimlane.metadata[0].name
    labels = {
      app = "swimlane"
    }
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
          image = "pranithreddy2711/swimlane-app:latest"
    
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 3000
          }

          env {
            name  = "MONGODB_URL"
            value = "mongodb://admin:password@mongo:27017/noobjs_dev?authSource=admin"
          }
        }
      }
    }
  }
}
