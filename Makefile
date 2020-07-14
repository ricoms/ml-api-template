## The Makefile includes instructions on environment setup and lint tests
# Create and activate a virtual environment
# Install dependencies in requirements.txt
# Dockerfile should pass hadolint
# app.py should pass pylint
# (Optional) Build a simple integration test

project-name=ml-api-template
container-name=divorce-predictor
python-version=3.8

CURRENT_UID := $(shell id -u)
time-stamp=$(shell date "+%Y-%m-%d-%H%M%S")

install:
	docker pull hadolint/hadolint:v1.17.6-3-g8da4f4e-alpine
	pipenv install -r requirements.txt --python 3
	pipenv install --dev flake8

test:
	# Additional, optional, tests could go here
	# python -m pytest -vv --cov=myrepolib tests/*.py
	# python -m pytest --nbval notebook.ipynb

lint-docker:
	docker run --rm -i hadolint/hadolint:v1.17.6-3-g8da4f4e-alpine < Dockerfile

lint-python:
	pipenv run flake8 src --count --select=E9,F63,F7,F82 --show-source --statistics
	pipenv run flake8 src --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

lint: lint-docker lint-python

coverage:
	pipenv run pytest --cov=$(PROJECT_NAME)
	pipenv run coverage report -m
	
data:
	wget https://archive.ics.uci.edu/ml/machine-learning-databases/00497/divorce.rar -P ml/input/data
	cd ml/input/data && unrar e divorce.rar
	cd ml/input/data && rm divorce.rar && rm divorce.xlsx

build-image:
	docker build -f Dockerfile -t ${container-name} .

train: build-image
	docker run --rm \
		-u ${CURRENT_UID}:${CURRENT_UID} \
		-v ${PWD}/ml:/opt/ml \
		${container-name} train \
			--project_name ${project-name} \
			--data_path /opt/ml/input/data/divorce.csv

serve: build-image
	tar -xvzf ml/output/model.tar.gz -C ml/model
	docker run --rm \
		-v ${PWD}/ml:/opt/ml \
		-p 8080:8080 \
		${container-name} serve \
			--project_name ${project-name} \
			--model_server_workers 1

local-ping:
	curl http://localhost:8080/ping

local-predict:
	curl --header "Content-Type: application/json" --request POST --data-binary @ml/input/invocation/payload.json http://a31c3822658cd4f8da1ca81e3b945596-1685130153.us-east-1.elb.amazonaws.com:8080/invocations

clean:
	rm -r ml/model/divorce
	rm -r ml/output/divorce
	rm ml/output/model.tar.gz
