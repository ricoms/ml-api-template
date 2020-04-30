#!/usr/bin/env bash

aws cloudformation create-stack --stack-name divorce-infra --template-body file://infrastructure.yml --parameters file://infrastructure_parameters.json --capabilities CAPABILITY_NAMED_IAM
