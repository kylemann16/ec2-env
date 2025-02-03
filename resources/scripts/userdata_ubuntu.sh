#!/bin/sh
USER="ubuntu"
# Mount SSD.
BIG=$(lsblk -b | grep nvme | awk '{print $4 " " $1}' | sort -k 1 -r -n | \
    head -n 1 | awk '{print $2}')
EXT="/dev/$BIG"
echo "Mounting $EXT"
mkfs -t xfs "$EXT"
mkdir -p /volume
mount "$EXT" /volume
chown -R $USER:users /volume


read -r -d '' DOCKER_SETTINGS << EOM
DAEMON_MAXFILES=1048576

# Additional startup options for the Docker daemon, for example:
# OPTIONS="--ip-forward=true --iptables=true"
# By default we limit the number of open files per container
OPTIONS="--default-ulimit nofile=1024:4096 -g /local/docker"

# How many seconds the sysvinit script waits for the pidfile to appear
# when starting the daemon.
DAEMON_PIDFILE_TIMEOUT=10
EOM

echo -e "$DOCKER_SETTINGS" > /etc/sysconfig/docker

service docker restart

function user_run {
    su -c "${@}" $USER
}

curl -L micro.mamba.pm/install.sh > install.sh && chmod +x install.sh
./install.sh
source /home/$USER/.bashrc
micromamba install rsync --yes