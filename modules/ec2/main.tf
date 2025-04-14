resource "aws_instance" "this" {
  # Required variables
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  # Optional variables with safe defaults
  key_name             = var.key_name != "" ? var.key_name : null
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  # User data handling with explicit file existence check
  user_data = var.user_data != "" ? var.user_data : (fileexists("${path.module}/user_data.sh") ? templatefile("${path.module}/user_data.sh", {
    docker_image         = var.docker_image != "" ? var.docker_image : "nginx:latest",
    docker_container_port = var.docker_container_port != "" ? var.docker_container_port : "80",
    docker_host_port     = var.docker_host_port != "" ? var.docker_host_port : "80"
  }) : null)

  # Tags with safe merging
  tags = merge(
    {
      "Name" = var.instance_name != "" ? var.instance_name : "ec2-app-instance"
    },
    var.tags
  )

  # Root block device configuration
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
    tags        = var.tags
  }

  # Prevent unintended replacement due to dynamic changes
  lifecycle {
    ignore_changes = [
      user_data, # Ignore user_data changes to prevent recreation
    ]
  }
}