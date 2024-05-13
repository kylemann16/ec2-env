MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/sh
# Mount SSD.
BIG=$(lsblk -b | grep nvme | awk '{print $4 " " $1}' | sort -k 1 -r -n | \
    head -n 1 | awk '{print $2}')
EXT="/dev/$BIG"
echo "Mounting $EXT"
mkfs -t xfs "$EXT"
mkdir /local
mount "$EXT" /local
chown -R ec2-user:users /local


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

apt-get -y update
apt-get install -y curl

curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
sudo su ec2-user -c 'bash Miniforge3-Linux-x86_64.sh -b'

su ec2-user -c '/home/ec2-user/miniforge3/bin/mamba init'
su ec2-user -c 'source /home/ec2-user/.bashrc'

--==MYBOUNDARY==--\
