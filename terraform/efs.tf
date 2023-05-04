resource "aws_security_group" "efs_mount_sg" {
  name        = "efs_mount_sg"
  description = "Amazon EFS for EKS, SG for mount target"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["192.168.0.0/16"]
  }

  tags = {
    Name  = "efs_sg"
    Owner = var.owner_tag
  }
}

resource "aws_efs_file_system" "jenkins_efs_file_system" {
  creation_token   = "creation-token"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name  = "efs_file_system"
    Owner = var.owner_tag
  }
}

resource "aws_efs_mount_target" "jenkins_efs_mount_target" {
  file_system_id  = aws_efs_file_system.jenkins_efs_file_system.id
  subnet_id       = aws_subnet.jenkins_private_subnet_1.id
  security_groups = [aws_security_group.efs_mount_sg.id]
}

resource "aws_efs_access_point" "jenkins_efs_access_point" {
  file_system_id = aws_efs_file_system.jenkins_efs_file_system.id

  root_directory {
    path = "/jenkins"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {
    Owner = var.owner_tag
  }
}

output "efs_file_system_id" {
  value = aws_efs_file_system.jenkins_efs_file_system.id
}

output "efs_file_system_access_point_id" {
  value = aws_efs_access_point.jenkins_efs_access_point.id
}
