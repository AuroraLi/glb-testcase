resource "google_compute_global_forwarding_rule" "default" {
  provider = google-beta

  name                  = var.lb_prefix

  target                = google_compute_target_http_proxy.default.self_link
  port_range            = "80"

  project               = data.google_project.gke_project.project_id
}

resource "google_compute_target_http_proxy" "default" {
  provider = google-beta

  name    = format("%s-proxy", var.lb_prefix)

  url_map = google_compute_url_map.default.self_link
  project = data.google_project.gke_project.project_id
}

resource "google_compute_url_map" "default" {
  provider = google-beta

  name            = format("%s-urlmap", var.lb_prefix)
  default_service = google_compute_backend_service.backend.self_link
  project         = data.google_project.gke_project.project_id
}


resource "google_compute_backend_service" "backend" {
  provider = google-beta

  # since this is dynamic, ignore changes
  lifecycle {
    ignore_changes = [
        backend
    ]
  }

  name                  = format("%s-backend", var.lb_prefix)
  protocol              = "HTTP2"
  timeout_sec           = 3600

  health_checks         = [
    google_compute_health_check.hc.self_link
  ]

  log_config {
    enable = true
    sample_rate = 1.0
  }
  
  project = data.google_project.gke_project.project_id
}

resource "google_compute_health_check" "hc" {
  name              = format("%s-healthcheck", var.lb_prefix)

  http_health_check {
    port_specification = "USE_FIXED_PORT"
    port = "10254"
    request_path = "/healthz"
  }  

  project = data.google_project.gke_project.project_id
}


output "ip" {
    value = google_compute_global_forwarding_rule.default.ip_address
}