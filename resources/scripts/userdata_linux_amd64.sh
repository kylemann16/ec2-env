#!/bin/sh
USER="ubuntu"

# Mount EBS volume
EXT="/dev/xvdb"
mkfs.xfs "$EXT"
mkdir -p /volume
mount "$EXT" /volume
chown -R $USER:users /volume

HOME="/volume"

curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
su -u $USER -c 'micromamba shell init --shell bash --root-prefix=~/.local/share/mamba'
echo "alias m=micromamba" >> /home/$USER/.bashrc
source /home/$USER/.bashrc

micromamba install -n base tmux --yes