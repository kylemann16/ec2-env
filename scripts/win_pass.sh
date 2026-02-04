#!/bin/bash
DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
workspace=$(terraform workspace list | grep '*' | tr -d '* ')
region=$(terraform output --json | jq '.aws_region.value' | tr -d '"')
eid=$(terraform output --json | jq '.instance_id.value' | tr -d '"')
pem_path=$(realpath $DIR/../.secrets/${workspace}/ssh.pem)
pass=$(\
    aws ec2 get-password-data --region $region --instance-id $eid --priv-launch-key $pem_path \
    | jq .PasswordData \
    | tr -d '"')
dns=$(\
    aws ec2 describe-instances --region $region --instance-id $eid \
    | jq '.Reservations[0].Instances[0].PublicDnsName' \
    | tr -d '"')
user=$(echo $dns'\Administrator')

echo Username: $user
echo Password: $pass