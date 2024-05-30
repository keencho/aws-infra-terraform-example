variable "app_name" {
  description = "The name of application"
  type = string
  default = "app"
}

variable "app_project_name" {
  description = "The name of Project"
  type = string
  default = "appProject"
}

variable "aws_region" {
  description = "The AWS region to deploy the VPC in"
  type        = string
  default     = "ap-northeast-2"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["a", "b"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  description = "The CIDR blocks for the DB subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "alb-health-check-path" {
  description = "Application Load Balancer Health Check Path"
  type        = string
  default     = "/alb/health-check"
}