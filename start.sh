#!/bin/bash

cd $(dirname "$0")
ENV_NAME="ec2-env"
CONDA_ENV_LIST=$(conda env list | grep ${ENV_NAME})

if [[ -z $CONDA_ENV_LIST ]]
then
    echo 'Environment not found. Creating...'
    mamba env create -f env.yaml
    mamba activate ${ENV_NAME}
else
    echo "Environment ${ENV_NAME} found. Activating..."
    mamba activate ${ENV_NAME}
fi