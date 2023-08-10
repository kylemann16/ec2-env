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
    value = module.resources.ip_address
}

variable platform {
    type = string
    default = "linux/amd64"
    description = "Platform for image."
    validation {
        condition = can(regex("^(win|linux/arm64|linux/amd64)$", var.platform))
        error_message = "Available platform options: win, linux/arm64, linux/amd64"
    }
}