// Copyright 2020 Google LLC All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*
Module to install Citadel (https://istio.io/docs/ops/deployment/architecture/#citadel)
To secure cross-cluster communication between Multi Cluster Allocation endpoints
*/

terraform {
  required_providers {
    kubernetes = "~> 2.5.0"
  }
}

provider "kubernetes" {
  host                   = var.host
  token                  = var.token
  cluster_ca_certificate = var.cluster_ca_certificate
}

resource "kubernetes_namespace" "istio-namespace" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_service_account" "istio_citadel_service_account" {
  metadata {
    name      = "istio-citadel-service-account"
    namespace = kubernetes_namespace.istio-namespace.metadata.0.name

    labels = {
      app      = "security"
      chart    = "security"
      heritage = "Terraform"
      release  = "istio"
    }
  }
}

resource "kubernetes_cluster_role" "istio_citadel_istio_system" {
  metadata {
    name = "istio-citadel-istio-system"

    labels = {
      app      = "security"
      chart    = "security"
      heritage = "Terraform"
      release  = "istio"
    }
  }

  rule {
    resources  = ["configmaps"]
    verbs      = ["create", "get", "update"]
    api_groups = [""]
  }

  rule {
    resources  = ["secrets"]
    verbs      = ["create", "get", "watch", "list", "update", "delete"]
    api_groups = [""]
  }

  rule {
    resources  = ["serviceaccounts", "services", "namespaces"]
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
  }

  rule {
    resources  = ["tokenreviews"]
    verbs      = ["create"]
    api_groups = ["authentication.k8s.io"]
  }
}

resource "kubernetes_cluster_role_binding" "istio_citadel_istio_system" {
  metadata {
    name = "istio-citadel-istio-system"

    labels = {
      app      = "security"
      chart    = "security"
      heritage = "Terraform"
      release  = "istio"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.istio_citadel_service_account.metadata.0.name
    namespace = kubernetes_namespace.istio-namespace.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.istio_citadel_istio_system.metadata.0.name
  }
}

resource "kubernetes_deployment" "istio_citadel" {
  metadata {
    name      = "istio-citadel"
    namespace = kubernetes_namespace.istio-namespace.metadata.0.name

    labels = {
      app      = "security"
      chart    = "security"
      heritage = "Terraform"
      istio    = "citadel"
      release  = "istio"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        istio = "citadel"
      }
    }

    template {
      metadata {
        labels = {
          app      = "security"
          chart    = "security"
          heritage = "Terraform"
          istio    = "citadel"
          release  = "istio"
        }

        annotations = {
          "sidecar.istio.io/inject" = "false"
        }
      }

      spec {
        automount_service_account_token = true
        container {
          name  = "citadel"
          image = "gcr.io/istio-testing/citadel:1.5-dev"
          args = ["--append-dns-names=true", "--grpc-port=8060",
            "--citadel-storage-namespace=istio-system",
            "--custom-dns-names=istio-pilot-service-account.istio-system:istio-pilot.istio-system",
          "--monitoring-port=15014", "--self-signed-ca=true", "--workload-cert-ttl=2160h"]

          env {
            name  = "CITADEL_ENABLE_NAMESPACES_BY_DEFAULT"
            value = "true"
          }

          resources {
            requests = {
              cpu = "10m"
            }
          }

          image_pull_policy = "IfNotPresent"
        }
        service_account_name = kubernetes_service_account.istio_citadel_service_account.metadata.0.name

        toleration {
          key      = "agones.dev/agones-system"
          operator = "Equal"
          value    = "true"
          effect   = "NoExecute"
        }
        affinity {
          node_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              preference {
                match_expressions {
                  key      = "agones.dev/agones-system"
                  operator = "Exists"
                }
              }
            }
          }
        }
      }
    }

    strategy {
      rolling_update {
        max_unavailable = "25%"
        max_surge       = "100%"
      }
    }
  }
}
