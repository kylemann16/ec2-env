#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pem_loc="${SCRIPT_DIR}/../.secrets/ssh.pem"

ipstr="ec2_public_ip = "
fullstr=$(cd ${SCRIPT_DIR}/../ && conda run -n ec2-env terraform output | grep ec2_public_ip | tr -d '"')
export ip=$(echo "${fullstr#"$ipstr"}")

echo $SCRIPT_DIR
echo "$fullstr"
echo "IP: $ip"

eval "ssh -i $pem_loc $ip"

# constr="connection = "
# fullstr=$(conda run -n ec2-env terraform output | grep connection)
# trimmed=$(echo "${fullstr#"$constr"}" | tr -d '"')
# eval "$trimmed"