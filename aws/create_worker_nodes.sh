#!/usr/bin/env bash

aws cloudformation create-stack --stack-name divorce-nodes --template-body file://worker_nodes.yml --parameters file://worker_nodes_parameters.json --capabilities CAPABILITY_NAMED_IAM
