# Machine Learning api template

This project implements the deployment of a functional Machine Learning.


## 1 Software Need/Solution

Need: a Machine Learning template to better organize and deploy a Machine Learning model.

Solution: My software is a suggestion on how to organize a Machine Learning experiment, with the capabilities of `train` a Machine Learning Model. It also includes CI/CD on how to deploy training to AWS SageMaker.


## 2 Prerequisites

This software does not requires specific hardwares. This project is based on **Python 3.8**, **pipenv**, **Makefile**, and **Docker**.

## 3 Build

### 3.1 Locally

I provide the followin `Makefile` target commands:
* `make data` - download the training data,
* `make train` - train the machine learning model with the data and sabe the Machine Learning artifact,

## 4 How do I install it?

This is a service software, the idea is to use its final result an API. If you intend to develop I provide detailed package requirements in the `requirements.txt` file or  `Pipfile` and `Pipfile.lock` for pipenv. Also `Makefile` target `make install` will install requirements using pipenv and docker.

## 5 Is the software ready?


### 5.1 Hello World


### 5.2 Hello Mars


## 6 Tips and Tricks

% code samples

% config tips

## 7 Troubleshooting

% FAQs

% Bugs

## 8 Contributions

% Community

% Explain How

## 9 Licensing and Credits

The repo provides the capability of training and serving a `sklearn` model capable of predicting divorce according to several features available for the "Divorce Predictors data set Data Set" dataset publicly available [here](https://archive.ics.uci.edu/ml/datasets/Divorce+Predictors+data+set).


## 10 List of Changes

## 11 Proof of functionality

After succesfully applying the deployment at EKS I obtained the following terminal screen:

![](https://github.com/ricoms/ml-api-template/blob/master/static/evaluator-service-and-predict.png)
