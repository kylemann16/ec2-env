####### ENVIRONMENT ########
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.11.0"
        }
    }
}

provider aws {
    region = var.aws_region
}

module resources {
    source = "./resources"
    instance_type = var.instance_type
    aws_region = var.aws_region
    platform = var.platform
    permissions_path= var.permissions_path
    availability_zone = var.az
}

####### VARIABLES ########
variable aws_region {
    type = string
}

variable az {
    type = string
    default = ""
}

variable instance_type {
    type = string
    default = "c5d.4xlarge"
}

variable platform {
    type = string
    description = "Platform for image."
    validation {
        condition = can(regex("^(windows|linux/arm64|linux/amd64)$", var.platform))
        error_message = "Available platform options: windows, linux/arm64, linux/amd64"
    }
    default = "linux/amd64"
}

variable permissions_path {
    type = string
    description = "Path to JSON file with IAM permissions."
    default = ""
}

####### OUTPUTS ########
output connection {
    value = module.resources.connection_str
}

output ec2_public_ip {
    value = module.resources.ec2_public_ip
}

output instance_id {
    value = module.resources.instance_id
}

output ami_id {
    sensitive=true
    value = module.resources.ami_id
}

output userdata_path {
    value = module.resources.userdata_path
}

output aws_region {
    value = var.aws_region
}