#!/bin/bash

# normalize operation location and conda env
source ./start.sh

######## select terraform workspace #########
read -p "Terraform workspace? [default]: " workspace
if [[ $workspace == "" ]]
then
    workspace='default'
fi

terraform workspace select $workspace
if [[ $? -eq 1 ]]
then
    terraform workspace new $workspace
    terraform workspace select $workspace
fi
###########################################

##### select terraform variable file ######
read -p "Variable file path? [None]: " var_file

# perform terraform operations
cd ../
if [[ $var_file == "" ]]
then
    terraform apply
else
    terraform apply -var-file="${var_file}"
fi

############################################