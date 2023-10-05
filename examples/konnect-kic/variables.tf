#mandatory Variables Needed to run the script
variable "konnect_region" {
  type        = string
  description = "Value of apiHostname after kong script is run"

  validation {
    condition     = contains(["us", "eu"], var.konnect_region)
    error_message = "Valid values for Konnect Region are: (us, eu)"
  }
}

variable "runtimeGroupID" {
  type        = string
  description = "Value of runtimeGroupID after kong script is run"
}

variable "cert_secret_name" {
  type        = string
  description = "Value of cert_secret_name after kong script is run"
}

variable "key_secret_name" {
  type        = string
  description = "Value of key_secret_name after kong script is run"
}

variable "telemetry_endpoint" {
  type        = string
  description = "value of telemetry_endpoint from Konnect control plane"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
