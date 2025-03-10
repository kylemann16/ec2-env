#!/bin/bash

# normalize operation location and conda env
source ./start.sh

workspace=$(terraform workspace list | awk '{if($1=="*") print $2}')
terraform destroy

read -p "remove workspace \"${workspace}\"? [y/N]: " remove
if [[ $remove == [Yy]* ]]
then
    if [[ "${workspace}" != "default" ]]
    then
        terraform workspace select default
        terraform workspace delete $workspace
        secret_dir=$(ls .secrets/ | awk -v ws_dir=$workspace '{if($1==ws_dir) print ".secrets/" $1}')
        if [[ "$secret_dir" != "" ]]
        then
            read -p "Delete ${secret_dir}? [y/N]: " d_dir
            if [[ $d_dir == [Yy]* ]]
            then
                rm -rf $secret_dir
            fi
        fi
    else
        echo "Cannot delete workspace ${workspace}. Exiting."
    fi
fi