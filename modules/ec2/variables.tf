variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the EC2 instance"
  type        = list(string)
}

variable "key_name" {
  description = "The key pair name for SSH access"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "The IAM instance profile name"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Custom user data script"
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image to run on the instance"
  type        = string
  default     = ""
}

variable "docker_container_port" {
  description = "Docker container port"
  type        = string
  default     = ""
}

variable "docker_host_port" {
  description = "Docker host port"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for the EC2 instance"
  type        = map(string)
  default     = {}
}