![Build and Deploy to GKE](https://github.com/ricoms/ml-api-template/workflows/Build%20and%20Deploy%20to%20GKE/badge.svg)

## Project Overview

This project shows how to operationalize a Machine Learning Microservice API with GKE.

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

`./create_cluster.sh`

1. Add and commit your changes:

```
$ git add .
$ git commit -m "<change-model>"
```

2. Push to the `master` branch:

```
$ git push -u origin master
```

3. View the GitHub Actions Workflow by selecting the `Actions` tab at the top of your repository on GitHub. Then click on the `Build and Deploy to GKE` element to see the details.

When service is online obtain its `ingress ip`:
```
kubectl get service divorce-evaluator-service --output yaml
```

Then you should be able to connect to its health status (`http://35.238.67.202:8080/ping`) in which you should obtain the answer: `{"data": {"status": "ok"}}`

Or submit a request with provided payload:

```
curl --header "Content-Type: application/json" --request POST --data-binary @ml/input/invocation/payload.json http://35.238.67.202:8080/invocations
```

### Some visualization

After succesfully applying the deployment at gke cluster I obtained the following terminal screen:

![](https://github.com/ricoms/ml-api-template/blob/master/static/evaluator-service-and-predict.png)
