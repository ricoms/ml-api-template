## The Makefile includes instructions on environment setup and lint tests
# Create and activate a virtual environment
# Install dependencies in requirements.txt
# Dockerfile should pass hadolint
# app.py should pass pylint
# (Optional) Build a simple integration test

project-name=ml-api-template
DOCKER_IMAGE_NAME=workshop-ml-api-template
python-version=3.8

inputdataconfig_file=ml/input/config/inputdataconfig.json
inputdataconfig=`cat ${inputdataconfig_file}`
hyperparameters_file=ml/input/config/hyperparameters.json
hyperparameters=`cat ${hyperparameters_file}`
resourceconfig_file=ml/input/config/resourceconfig.json
resourceconfig=`cat ${resourceconfig_file}`
CURRENT_UID := $(shell id -u)
time-stamp=$(shell date "+%Y-%m-%d-%H%M%S")

install:
	docker pull hadolint/hadolint:v1.17.6-3-g8da4f4e-alpine
	pipenv install -r requirements.txt --python 3
	pipenv install --dev flake8

data:
	wget https://archive.ics.uci.edu/ml/machine-learning-databases/00497/divorce.rar -P ml/input/data/training/
	cd ml/input/data/training/ && unrar e divorce.rar
	cd ml/input/data/training/ && rm divorce.rar && rm divorce.xlsx

train: build-image
	docker run --rm \
		-u ${CURRENT_UID}:${CURRENT_UID} \
		-v ${PWD}/ml:/opt/ml \
		${DOCKER_IMAGE_NAME} train \
			--project_name ${project-name} \
			--data_path /opt/ml/input/data/training/divorce.csv

clean:
	rm -r ml/model/divorce
	rm -r ml/output/divorce
	rm ml/output/model.tar.gz


data-upload:
	aws s3 sync ml s3://719003640801-workshop-ml-api-template

# CICD commands

lint-docker:
	docker run --rm -i hadolint/hadolint:v1.17.6-3-g8da4f4e-alpine < Dockerfile

lint-python:
	pipenv run flake8 src --count --select=E9,F63,F7,F82 --show-source --statistics
	pipenv run flake8 src --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

lint: lint-docker lint-python

test:
	# Additional, optional, tests could go here
	# python -m pytest -vv --cov=myrepolib tests/*.py
	# python -m pytest --nbval notebook.ipynb
	
coverage:
	pipenv run coverage html

build-image:
	docker build -f Dockerfile -t ${DOCKER_IMAGE_NAME} .

check-env-aws:
ifndef AWS_ACCESS_KEY_ID
	$(error AWS_ACCESS_KEY_ID is undefined)
endif
ifndef AWS_SECRET_ACCESS_KEY
	$(error AWS_SECRET_ACCESS_KEY is undefined)
endif
ifndef AWS_DEFAULT_REGION
	$(error AWS_DEFAULT_REGION is undefined)
endif

check-env-docker:
ifndef DOCKER_SERVER
	$(error DOCKER_SERVER is undefined)
endif

docker-login: check-env-aws check-env-docker
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_SERVER}/${DOCKER_IMAGE_NAME}

release-image: docker-login
	docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_SERVER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG_PUSH} && \
		docker push ${DOCKER_SERVER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG_PUSH}

check-env-sagemaker:
ifndef AWS_PROJECT_BUCKET
	$(error AWS_PROJECT_BUCKET is undefined)
endif
ifndef AWS_SAGEMAKER_ROLE
	$(error AWS_SAGEMAKER_ROLE is undefined)
endif

check-parameter-files:
ifeq ("$(wildcard $(inputdataconfig_file))", "")
	$(error ${inputdataconfig_file} is non-existent)
endif
ifeq ("$(wildcard $(resourceconfig_file))", "")
	touch ${resourceconfig_file}
	echo "{\"InstanceType\"=\"ml.m4.xlarge\",\"InstanceCount\"=\"1\",\"VolumeSizeInGB\"=\"10\"}" > ${resourceconfig_file}
endif
ifeq ("$(wildcard $(hyperparameters_file))", "")
	touch ${hyperparameters_file}
	echo "{}" > ${hyperparameters_file}
endif

sagemaker-training-job: check-env-aws check-env-docker check-env-sagemaker check-parameter-files
	aws sagemaker create-training-job \
		--training-job-name="${TRAINING_JOB_NAME}" \
		--algorithm-specification="TrainingImage=${DOCKER_SERVER}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG_PUSH},TrainingInputMode=File" \
		--role-arn="${AWS_SAGEMAKER_ROLE}" \
		--output-data-config="S3OutputPath=s3://${AWS_PROJECT_BUCKET}/training-jobs/" \
		--resource-config="${resourceconfig}" \
		--stopping-condition="MaxRuntimeInSeconds=3600" \
		--input-data-config="${inputdataconfig}" \
		--hyper-parameters="${hyperparameters}" \
		--tags="Key=system,Value=${DOCKER_IMAGE_NAME},Key=role,Value=machine_learning,Key=group,Value=rnd,Key=env,Value=experimentation,Key=company,Value=gfg,Key=type,Value=service"
