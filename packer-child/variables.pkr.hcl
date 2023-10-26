variable "project_id" {
  type    = string
  default = "hc-ff11ac01f84f408d8638090d8c8"
}

variable "zones" {
  type    = list(string)
  default = ["us-central1-a", "us-west1-a"]
}