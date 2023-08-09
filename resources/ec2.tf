data aws_ssm_parameter linux_arm64 {
    name = "aws/service/canonical/ubuntu/server/20.04/stable/current/arm64/hvm/ebs-standard/ami-id"
}

data aws_ssm_parameter linux_amd64 {
    name = "aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-standard/ami-id"
}

# data aws_ssm_parameter windows {
#     name = "aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-standard/ami-id"
# }

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