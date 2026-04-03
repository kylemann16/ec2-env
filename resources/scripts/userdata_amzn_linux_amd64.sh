#!/bin/sh
USER="ec2-user"

# Mount EBS volume and use it primarily
EXT="/dev/xvdb"
mkfs.xfs "$EXT"
mkdir -p /volume
mount "$EXT" /volume
chown -R $USER:users /volume
HOME="/volume"

yum install git -y

# install/configure docker
yum install docker -y
touch /etc/docker/daemon.json
mkdir /volume/docker
echo "{ \"data-root\": \"/volume/docker\" }" > /etc/docker/daemon.json
service docker restart
usermod -aG docker $USER

#micromamba install
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
micromamba shell init --shell bash --root-prefix=/home/$USER/.local/share/mamba
echo "alias m=micromamba" >> /home/$USER/.bashrc
source /home/$USER/.bashrc

micromamba install -n base tmux --yes