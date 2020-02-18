project-name=ml-api-template
container-name=${project-name}
python-version=3.7.4

CURRENT_UID := $(shell id -u)
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
	curl --header "Content-Type: application/json" --request POST --data-binary @ml/input/invocation/payload.json http://localhost:8080/invocations

clean:
	rm -r ml/model/divorce
	rm -r ml/output/divorce
	rm ml/output/model.tar.gz
