variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "task_family" {
  type = string
}

variable "container_name" {
  type = string
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "container_image" {
  type = string
}

variable "network_mode" {
  type = string
}

variable "cont_definitions" {
  description = "List of container definitions for the ECS task"
  type = list(object({
    name   = string
    image  = string
    cpu    = number
    memory = number
    portMappings = list(object({
      containerPort = number
      hostPort      = number
      protocol = string
    }))
    environment = list(object({
      name  = string
      value = string
    }))
  }))
}

variable "desired_count" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "api_name" {
  type = string
}

variable "cors_configuration" {
  description = "CORS configuration for the API Gateway"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age           = optional(number, 0)
  })
  default = {
    allow_credentials = false
    allow_headers     = []
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age           = 0
  }
}

variable "stage_name" {
  type        = string
}

variable "auto_deploy" {
  type        = bool
}

variable "authorization_type" {
  type = string
}

variable "integration_type" {
  type = string
}

variable "integration_method" {
  type = string
}

variable "integration_uri" {
  type = string
}