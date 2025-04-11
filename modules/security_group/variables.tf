variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the security group names"
  type        = string
  default     = "demo"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow ingress from (default is all)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ports" {
  description = "Ports to allow in the security group"
  type        = list(number)
  default     = [22, 80, 443]
}