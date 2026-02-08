resource "kubernetes_service" "app" {
  metadata {
    name      = "swimlane-service"
    namespace = kubernetes_namespace.swimlane.metadata[0].name
  }

  spec {
    selector = {
      app = "swimlane"
    }

    port {
      port        = 80
      target_port = 3000
      node_port   = 30007
    }

    type = "NodePort"
  }
}
