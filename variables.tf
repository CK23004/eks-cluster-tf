variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "c7i-flex.large"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum worker nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum worker nodes"
  type        = number
  default     = 4
}
