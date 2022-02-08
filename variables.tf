variable "region" {
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "The AWS-CLI profile for the account to create resources in."
  default = "default"
}


#****************Network Part*******************

variable "destination_cidr_block" {
  default     = "0.0.0.0/0"
  description = "Specify all traffic to be routed either trough Internet Gateway or NAT to access the internet"
}

variable "private_subnet_cidrs" {
  type        = list
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24" ]
  description = "List of private cidrs."
}

variable "public_subnet_cidrs" {
  type        = list
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
  description = "List of public cidrs."
}

variable "availability_zones" {
  type        = list
  default     = ["eu-central-1a", "eu-central-1b","eu-central-1c"]
  description = "List of availability zones."
}


#****************ECS Part*******************

variable "autoscale_min" {
  description = "Minimum autoscale (number of EC2)"
  default     = "2"
}
variable "autoscale_max" {
  description = "Maximum autoscale (number of EC2)"
  default     = "3"
}
variable "autoscale_desired" {
  description = "Desired autoscale (number of EC2)"
  default     = "2"
}
variable "instance_type" {
  default = "t2.micro"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  default     = "production"
}

#****************key pair*******************
variable "ssh_pubkey_file" {
  description = "Path to an SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

#****************Image on ECR*******************
variable "docker_image_url" {
  description = "Docker image to run in the ECS cluster"
  default     = "709967413147.dkr.ecr.eu-central-1.amazonaws.com/hylobatesapp:latest"
  #default     = "709967413147.dkr.ecr.eu-central-1.amazonaws.com/nginx:latest"
}
