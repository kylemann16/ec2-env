#!/bin/sh
USER="ubuntu"
HOME="/home/$USER/"
# Mount SSD.
# BIG=$(lsblk -b | grep nvme | awk '{print $4 " " $1}' | sort -k 1 -r -n | \
#     head -n 1 | awk '{print $2}')
# EXT="/dev/$BIG"
# echo "Mounting $EXT"
# mkfs -t xfs "$EXT"
# mkdir -p /volume
# mount "$EXT" /volume
# chown -R $USER:users /volume


# read -r -d '' DOCKER_SETTINGS << EOM
# DAEMON_MAXFILES=1048576

# # Additional startup options for the Docker daemon, for example:
# # OPTIONS="--ip-forward=true --iptables=true"
# # By default we limit the number of open files per container
# OPTIONS="--default-ulimit nofile=1024:4096 -g /local/docker"

# # How many seconds the sysvinit script waits for the pidfile to appear
# # when starting the daemon.
# DAEMON_PIDFILE_TIMEOUT=10
# EOM

# echo -e "$DOCKER_SETTINGS" > /etc/sysconfig/docker

# service docker restart

# function user_run {
#     su -c "${@}" $USER
# }

curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
export MAMBA_ROOT_PREFIX=$HOME
su -H -u $USER -c 'micromamba shell init --shell bash --root-prefix=~/.local/share/mamba'
source /home/$USER/.bashrc
micromamba install rsync --yes
alias m=micromamba