locals {
    user = "${
        var.platform == "linux/amd64" ? "ec2-user" :
        ( var.platform == "linux/arm64" ? "ubuntu" :
        ( var.platform == "windows" ? "Administrator" : ""))
    }"
}

resource tls_private_key rsa_key {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource aws_key_pair ec2_key_pair {
    key_name_prefix = "ec2_terra_"
    public_key = tls_private_key.rsa_key.public_key_openssh
}

resource local_file ssh_pem {
    content = tls_private_key.rsa_key.private_key_pem
    filename = "${path.module}/../.secrets/ssh.pem"
    file_permission = "400"
}

resource local_file ssh_config {
    filename = "${path.module}/../.secrets/ssh_config"
    content = <<T
Host ${aws_instance.instance.public_ip}
    hostname ${aws_instance.instance.public_ip}
    User ${local.user}
    IdentityFile ${abspath("${path.module}/../.secrets/ssh.pem")}
    IdentitiesOnly yes
    SendEnv GITHUB_TOKEN
T
}

resource local_file rdp_config {
    filename = "${path.module}/../.secrets/ec2_env.rdp"
    content = <<T
auto connect:i:1
full address:s:${aws_instance.instance.public_dns}
username:s:${aws_instance.instance.public_dns}\${local.user}
T
}