#!/bin/bash

cd "$(dirname "$0")"
cd ../

# normalize operation location and conda env

######## select terraform workspace #########
read -p "Terraform workspace? [default]: " workspace
if [[ $workspace == "" ]]
then
    terraform workspace select default
else
    terraform workspace select $workspace
fi

##### select terraform variable file ######
read -p "Variable file path? [None]: " var_file

if [[ $var_file == "" ]]
then
    terraform destroy
else
    terraform destroy -var-file="${var_file}"
fi

##### Delete terraform workspace if not default #####

read -p "remove workspace \"${workspace}\"? [y/N]: " remove
if [[ $remove == [Yy]* ]]
then
    if [[ "${workspace}" != "default" ]]
    then
        terraform workspace select default
        terraform workspace delete --force $workspace
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
        echo "Cannot delete default workspace. Exiting."
    fi
fi