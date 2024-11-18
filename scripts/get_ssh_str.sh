#!/bin/bash

constr="connection = "
fullstr=$(conda run -n ec2-env terraform output | grep connection)
export ssh_cmd=$(echo "${fullstr#"$constr"}")