#!/bin/bash
SRC=$1
DST=$2

if [[ $SRC == "help" ]]; then
    echo -e "
    sync.sh SRC DST.
        DST - Destination folder on remote instance.
        SRC - Source folder on local machine.
    "
    exit 0
fi

if [[ $SRC == "" ]]; then
    echo "Missing required positional argument SRC. (sync.sh SRC DST)"
    exit 1
fi

if [[ $DST == "" ]]; then
    echo "Missing required positional argument DST. (sync.sh SRC DST)"
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pem_loc="${SCRIPT_DIR}/../.secrets/ssh.pem"

ipstr="ec2_public_ip = "
fullstr=$(conda run -n ec2-env terraform output | grep ec2_public_ip | tr -d '"')
export ip=$(echo "${fullstr#"$ipstr"}")

echo "rsync -chavzP -e 'ssh -i $pem_loc' $SRC $ip:$DST"
rsync -chavzP -e "ssh -i $pem_loc" $SRC $ip:$DST
