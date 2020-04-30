#!/usr/bin/env bash

aws cloudformation create-stack --stack-name divorce-eks --template-body file://eks.yml --parameters file://eks_parameters.json
