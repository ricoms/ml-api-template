# Machine Learning api template

This project implements the deployment of a functional Machine Learning.

Below are some images that show the deployment on AWS:

![](https://github.com/ricoms/ml-api-template/blob/master/static/create_eks.png)

![](https://github.com/ricoms/ml-api-template/blob/master/static/create_infrastructure.png)

![](https://github.com/ricoms/ml-api-template/blob/master/static/create_worker_nodes.png)

![](https://github.com/ricoms/ml-api-template/blob/master/static/cloudformation.png)

![](https://github.com/ricoms/ml-api-template/blob/master/static/awsEKS.png)

This project uses an update policy of AutoScalingRollingUpdate deployment strategy available on Kubernetes, defined at the `aws/app-deployment.yml`

Also, below is the project that ran on my Jenkins server:

![](https://github.com/ricoms/ml-api-template/blob/master/static/jenkins.png)



## 1 Software Need/Solution

Need: a Machine Learning template to better organize and deploy a Machine Learning model.

Solution: My software is a suggestion on how to organize a Machine Learning experiment, with the capabilities of `train` and `serve` a Machine Learning Model. It also includes Jenkins CI/CD on how to deploy the serving code to a Kubernetes cluster.


## 2 Prerequisites

This software does not requires specific hardwares. This project is based on **Python 3.7**, **pip**, **venv**, **Makefile**, and **Docker**.

## 3 Build

### 3.1 Locally

I provide the followin `Makefile` target commands:
* `make data` - download the training data,
* `make train` - train the machine learning model with the data and sabe the Machine Learning artifact,
* `make serve` - raise an api locally and serve the Machine Learning algorithm as a service,
* `make local-ping` - test api health status via `curl`,
* `make local-predict` - submits a `payload.json` via curl and expects a return.

### 3.2 Kubernetes

Having AWS profile configured locally (`aws configure`) you can run the following scripts to create a cluster:

```
cd aws
./create_infrastructure.sh
./create_eks.sh
./create_worker_nodes.sh
```

After this you will have a working EKS cluster to use with configured Jenkins CI/CD Pipeline.

So add and commit your changes:

```
$ git add .
$ git commit -m "<change-model>"
```

2. Push to the `aws_jenkins` branch:

```
$ git push -u origin aws_jenkins
```

3. View the GitHub Actions Workflow by selecting the `Actions` tab at the top of your repository on GitHub. Then click on the `Build and Deploy to GKE` element to see the details.

When service is online obtain its `ingress ip`:
```
kubectl get service divorce-evaluator-service --output yaml
```

Then you should be able to connect to its health status (`http://<app-ip>:8080/ping`) in which you should obtain the answer: `{"data": {"status": "ok"}}`

Or submit a request with provided payload:

```
curl --header "Content-Type: application/json" --request POST --data-binary @ml/input/invocation/payload.json http://<app-ip>:8080/invocations
```

## 4 How do I install it?

This is a service software, the idea is to use its final result an API. If you intend to develop I provide detailed package requirements in the `requirements.txt` file, and two `Makefile` targets commands which you can use `make setup` (creates a local virtual environment that you can activate with `source ~/.devops/bin/activate`) and `make install` that will install requirements - this should be run inside a virtual environment.

## 5 Is the software ready?

It basically functions although it needs work on tests and coverage.

### 5.1 Hello World

I expect that my system provides a full deployable Machine Learning project, some expected features are:
* Machine Learning experiment with modular code organization, testable, with coverage analysis.
* Machine learning api modular code and model agnostic.

### 5.2 Hello Mars

I also expect to provide some deployment standards for:
* Kubernetes deployment, fully trainable and serving capabilities,
* AWS Sagemaker deployment,
* Kubeflow deployment,
* and others.


## 6 Tips and Tricks

This project operationalize a Python falcon app—in a provided module, `src/api/` that serves out predictions (inference) about chances of divorce through API calls. This project could be extended to any pre-trained machine learning model.

This project operationalizes machine learning microservice using [kubernetes](https://kubernetes.io/), which is an open-source system for automating the management of containerized applications.

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
