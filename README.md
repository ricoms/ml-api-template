![](https://github.com/ricoms/ml-api-template/workflows/Publish%20Docker%20image/badge.svg)

## Project Overview

This project shows how to operationalize a Machine Learning Microservice API.

For this example I'm using the dataset "Divorce Predictors data set Data Set" publicly available [here](https://archive.ics.uci.edu/ml/datasets/Divorce+Predictors+data+set).

The repo provides the capability of training and serving a `sklearn` model capable of predicting divorce according to several features available for the "Divorce Predictors data set Data Set" dataset publicly available [here](https://archive.ics.uci.edu/ml/datasets/Divorce+Predictors+data+set). This project operationalize a Python falcon app—in a provided module, `src/api/` that serves out predictions (inference) about chances of divorce through API calls. This project could be extended to any pre-trained machine learning model.

### Project Tasks

This project operationalizes machine learning microservice using [kubernetes](https://kubernetes.io/), which is an open-source system for automating the management of containerized applications.

## Setup the Environment

* Create a virtualenv and activate it
* Run `make install` to install the necessary dependencies


### Running the application

#### Locally:

`make train`, `make serve`, `make local-ping`, `make local-predict`

#### Run in Kubernetes:

`cd aws`

`./create_infrastructure.sh`
`./create_eks.sh`
`./create_worker_nodes.sh`

### Kubernetes Steps

* Setup and Configure Docker locally
* Setup and Configure Kubernetes locally
* Create Flask app in Container
* Run via kubectl
