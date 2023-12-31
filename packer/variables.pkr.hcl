variable "project_id" {
  type    = string
  default = "hc-1f800ce1e3634caa972e17bb68d"
}

variable "zone" {
  type = string
  default = "us-central1-c"
}

variable "vault_role_id" {
  type = string
}

variable "vault_addr" {
  type = string
}

variable "vault_namespace" {
  type = string
  default = "admin"
}