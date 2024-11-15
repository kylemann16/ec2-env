#!/bin/sh
# Mount SSD.
BIG=$(lsblk -b | grep nvme | awk '{print $4 " " $1}' | sort -k 1 -r -n | \
    head -n 1 | awk '{print $2}')
EXT="/dev/$BIG"
echo "Mounting $EXT"
mkfs -t xfs "$EXT"
mkdir -p /volume
mount "$EXT" /volume
chown -R ec2-user:users /volume


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

yum install curl -y
yum install rsync -y

function user_run {
    su ec2-user -c "${@}"
}

curl -L micro.mamba.pm/install.sh > install.sh && chmod +x install.sh
user_run ./install.sh

user_run micromamba init
user_run source /home/ec2-user/.bashrc