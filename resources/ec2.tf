data aws_ssm_parameter linux_arm64 {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/arm64/hvm/ebs-gp2/ami-id"
}

data aws_ssm_parameter linux_amd64 {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

data aws_ssm_parameter windows {
    name = "/aws/service/ami-windows-latest/Windows_Server-2016-English-Full-Base"
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

locals {
    linux_arm64_path = "/aws/service/canonical/ubuntu/server/20.04/stable/current/arm64/hvm/ebs-gp2/ami-id"
    linux_amd64_path = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
    windows_path = "/aws/service/ami-windows-latest/Windows_Server-2016-English-Full-Base"
    ssm_path = "${
        var.platform == "linux/amd64" ? local.linux_arm64_path :
        ( var.platform == "linux/arm64" ? local.linux_arm64_path :
        ( var.platform == "windows" ? local.windows_path : ""))
    }"
}

data aws_ssm_parameter ec2_ami {
    name = local.ssm_path
}

resource random_string run_id {
    length = 5
    special = false
}

//TODO make this variable depending on architecture
variable instance_type {
    type = string
    default = "c5d.xlarge"
}

variable aws_region {
    type = string
}

provider aws {
    region = var.aws_region
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/gpu/recommended"
}

resource aws_instance instance {
    instance_type = var.instance_type
    tags = {
        Name = "Intern_Data_Processor_${random_string.run_id.result}"
    }
    user_data = filebase64("${path.module}/userdata.sh")
    subnet_id = aws_default_subnet.default_subnet.id
    ami = jsondecode(data.aws_ssm_parameter.ami.value).image_id
    key_name = aws_key_pair.ec2_key_pair.key_name
    security_groups = [ aws_security_group.allow_ssh.id ]
    instance_market_options {
        market_type = "spot"
    }
}

output ip_address {
    value = "ssh -i .secrets/ssh.pem ec2-user@${aws_instance.instance.public_ip}"
}

output instance_id {
    value = "${aws_instance.instance.id}"
}