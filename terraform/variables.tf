variable "aws_region" {
  description = "default region"
  default     = "us-east-1"
}

variable "owner_tag" {
  description = "shows who owns what eks and vpc clusters"
}

variable "cluster_name" {
  description = "name of eks cluster"
}

variable "instance_types" {
  description = "determines ec2 size and how much memory and cpu the ec2 instance will have"
}

variable "desired_size" {
  description = "desired size of eks cluster nodes"
}

variable "max_size" {
  description = "max number of eks nodes that can run"
}

variable "min_size" {
  description = "min number of eks nodes that can run"
}

variable "eks_role" {
  default = "worker"
}
