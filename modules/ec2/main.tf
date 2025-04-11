resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  user_data = var.user_data != "" ? var.user_data : templatefile("${path.module}/user_data.sh", {
    docker_image         = var.docker_image
    docker_container_port = var.docker_container_port
    docker_host_port     = var.docker_host_port
  })

  tags = merge(
    {
      "Name" = var.instance_name
    },
    var.tags
  )

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
    tags        = var.tags
  }
}