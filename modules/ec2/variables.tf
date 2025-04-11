variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
  default     = "ami-0df368112825f8d8f" # Ubuntu Server
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name to use"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where instance will be launched"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script for the instance"
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "nginx:latest"
}

variable "docker_container_port" {
  description = "Port that the Docker container listens on"
  type        = number
  default     = 80
}

variable "docker_host_port" {
  description = "Port on the host to map to the Docker container"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}