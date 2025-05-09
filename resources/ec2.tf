data aws_ssm_parameter linux_arm64 {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/arm64/hvm/ebs-gp2/ami-id"
}

data aws_ssm_parameter linux_amd64 {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

data aws_ssm_parameter windows {
    name = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-ECS_Optimized"
}

variable platform {
    type = string
    default = "linux/amd64"
    description = "Platform for image."
    validation {
        condition = can(regex("^(windows|linux/arm64|linux/amd64)$", var.platform))
        error_message = "Available platform options: windows, linux/arm64, linux/amd64"
    }
}

locals {
    ami_id = "${
        var.platform == "linux/amd64" ? data.aws_ssm_parameter.linux_amd64.value :
        ( var.platform == "linux/arm64" ? data.aws_ssm_parameter.linux_arm64.value :
        ( var.platform == "windows" ? jsondecode(data.aws_ssm_parameter.windows.value).image_id : ""))
    }"
    userdata_path = "${
        var.platform == "linux/amd64" ? "${path.module}/scripts/userdata_linux_amd64.sh" :
        ( var.platform == "linux/arm64" ? "${path.module}/scripts/userdata_linux_ard64.sh" :
        ( var.platform == "windows" ? "${path.module}/scripts/userdata_win.ps1" : ""))
    }"
}

resource random_string run_id {
    length = 5
    special = false
}

//TODO make this variable depending on architecture?
variable instance_type {
    type = string
    default = "c5.large"
}

variable aws_region {
    type = string
}

provider aws {
    region = var.aws_region
}

variable permissions_path {
    type = string
}

data local_file permissions_json {
    count = var.permissions_path == "" ? 0 : 1
    filename = var.permissions_path
}

resource aws_iam_role_policy ip_policy {
    count = var.permissions_path == "" ? 0 : 1
    name = "ec2_env_ip_policy"
    policy = data.local_file.permissions_json[0].content
    role = aws_iam_role.ip_role[0].name
}

resource aws_iam_role ip_role {
    count = var.permissions_path == "" ? 0 : 1
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource aws_iam_instance_profile instance_profile {
    count = var.permissions_path == "" ? 0 : 1
    name = "ec2_env_instance_profile"
    role = aws_iam_role.ip_role[0].name
}

resource aws_instance instance {
    instance_type = var.instance_type
    tags = {
        Name = "Dev_Instance_${var.platform}"
    }
    user_data = filebase64("${local.userdata_path}")
    subnet_id = aws_default_subnet.default_subnet.id
    ami = local.ami_id
    key_name = aws_key_pair.ec2_key_pair.key_name
    security_groups = [ aws_security_group.allow_ssh.id ]
    iam_instance_profile = var.permissions_path == "" ? null : aws_iam_instance_profile.instance_profile[0].name

    # only wait for password data if it's a windows instance
    get_password_data = var.platform == "windows" ? true : false

    ##### uncomment if you want a spot instance ####
    # instance_market_options {
    #     market_type = "spot"
    # }
    metadata_options {
        instance_metadata_tags="enabled"
        http_endpoint="enabled"
        http_tokens="required"
        http_put_response_hop_limit = 2
    }


}

output connection_str {
    value = var.platform == "windows" ? "ssh -o StrictHostKeyChecking=no -i .secrets/${terraform.workspace}/ssh.pem ${local.user}@${aws_instance.instance.public_dns}" : "ssh -o StrictHostKeyChecking=no -i .secrets/${terraform.workspace}/ssh.pem ${local.user}@${aws_instance.instance.public_ip}"
}

output ec2_public_ip {
    value = var.platform == "windows" ? "${local.user}@${aws_instance.instance.public_dns}" : "${local.user}@${aws_instance.instance.public_ip}"
}

output instance_id {
    value = "${aws_instance.instance.id}"
}

output ami_id {
    sensitive = true
    value = local.ami_id
}

output userdata_path {
    value = local.userdata_path
}