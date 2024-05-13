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
    User ec2-user
    IdentityFile ${abspath("${path.module}/../.secrets/ssh.pem")}
    IdentitiesOnly yes
    SendEnv GITHUB_TOKEN
T
}