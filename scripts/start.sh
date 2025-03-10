#!/bin/bash

cd "$(dirname "$0")/../"
ENV_NAME="ec2-env"
CONDA_ENV=$(conda env list | awk '{if($2=="*") print $3}')

if [[ $ENV_NAME==$CONDA_ENV ]]
then
    echo "Environment ${ENV_NAME} found. Activating..."
    mamba activate ${ENV_NAME}
else
    echo 'Environment not found. Creating...'
    mamba env create -f env.yaml
    mamba activate ${ENV_NAME}
fi