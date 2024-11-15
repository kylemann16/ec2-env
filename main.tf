module resources {
    source = "./resources"
    instance_type = var.instance_type
    aws_region = var.aws_region
    platform = var.platform
}

variable aws_region {
    type = string
    default = "us-east-1"
}

variable instance_type {
    type = string
    default = "c5d.4xlarge"
}

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

variable platform {
    type = string
    description = "Platform for image."
    validation {
        condition = can(regex("^(windows|linux/arm64|linux/amd64)$", var.platform))
        error_message = "Available platform options: windows, linux/arm64, linux/amd64"
    }
    default = "linux/amd64"
}