data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_availability_zone" "available" {
    for_each = toset(data.aws_availability_zones.available.names)
    name     = each.value
}

locals {
    azs = [ for x in data.aws_availability_zone.available : x.name ]
}

resource aws_default_subnet default_subnet {
    availability_zone = local.azs[0]
    map_public_ip_on_launch = true
}

resource aws_security_group allow_ssh {
    vpc_id = aws_default_subnet.default_subnet.vpc_id

    # ssh
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # rsync
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #internet
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}