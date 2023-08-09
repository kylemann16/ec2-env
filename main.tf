module resources {
    source = "./resources"
    instance_type = var.instance_type
    aws_region = var.aws_region
    platform = var.platform
    architecture = var.architecture
}

variable aws_region {
    type = string
    default = "us-east-1"
}

variable instance_type {
    type = string
    default = "c5d.xlarge"
}

output connection {
    value = module.resources.ip_address
}

variable platform {
    type = string
    default = "linux"
    validation {
        condition = can(regex("^(osx|win|linux|alpine)$", var.platform))
        error_message = "Available platform options: osx, win, linux, alpine."
    }
}

variable architecture {
    type = string
    default = "amd64"
    validation {
        condition = can(regex("^(arm64|amd64)$", var.architecture))
        error_message = "Valid architecture types: amd64, arm64."
    }
}
