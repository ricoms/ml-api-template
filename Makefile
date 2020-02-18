project-name=ml-api-template
container-name=${project-name}
python-version=3.7.4

time-stamp=$(shell date "+%Y-%m-%d-%H%M%S")

install:
	sudo apt-get install unrar

setup:
	chmod +x /src/train
	chmod +x /src/serve

build-image:
	docker build -f docker/Dockerfile -t ${container-name} .

data:
	wget https://archive.ics.uci.edu/ml/machine-learning-databases/00497/divorce.rar -P ml/input/data
	cd ml/input/data && unrar e divorce.rar

train: build-image
	docker run --rm \
		-u ${CURRENT_UID}:${CURRENT_UID} \
		-v ${PWD}/ml:/opt/ml \
		${container-name} train \
			--project_name ${project-name} \
			--run_tag ${project-name} \
			--bucket_name ${storage} \
			--data_paht /opt/ml/input/data/divorce.csv

local-serve: build-image
	docker run --rm \
		-v ${PWD}/ml:/opt/ml \
		-p 8080:8080 \
		${container-name} serve \
			--project_name ${project-name} \
			--run_tag ${project-name} \
			--bucket_name ${storage} \
			--model_server_workers 1

local-predict:
	curl --header "Content-Type: application/json" --request POST --data-binary @ml/input/invocation/payload.json http://localhost:8080/invocations
