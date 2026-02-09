variable "aws_region" {
  description = "AWS region to deploy the VPN stack into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile Terraform should use"
  type        = string
  default     = "personal"
}

variable "instance_type" {
  description = "EC2 instance type for the VPN/ad-block server"
  type        = string
  default     = "t2.micro" # free tier eligible
}

variable "project_name" {
  description = "Name prefix for tags/resources"
  type        = string
  default     = "personal-vpn"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.10.10.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance. Lock this down to public IP /32 later."
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_name" {
  description = "EC2 Name tag"
  type        = string
  default     = "vpn-adblock"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key to import to AWS (optional fallback access)"
  type        = string
  default     = "~/.ssh/personal_vpn.pub"
}

variable "enable_keypair" {
  description = "Whether to create/import an EC2 key pair for SSH fallback"
  type        = bool
  default     = true
}
