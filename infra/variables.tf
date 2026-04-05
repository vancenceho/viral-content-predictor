variable "region" {
    description = "AWS region where the resources will be created"
    type = string
    default = "ap-southeast-1"
}

variable environment {
    description = "deployment environment" 
    type = string
    default = "dev"
}