project-name=ml-api-template
container-name=${project-name}
python-version=3.7.4

time-stamp=$(shell date "+%Y-%m-%d-%H-%M-%S")

setup:
	chmod +x /src/train
	chmod +x /src/serve

build-image:
	docker build -f docker/Dockerfile -t ${container-name} .

data:
	echo "not done!"

local-train: build-docker
	docker run --rm \
		-u ${CURRENT_UID}:${CURRENT_UID} \
		-v ${PWD}/ml:/opt/ml \
		${container-name} train \
			--project_name ${project-name} \
			--run_tag ${time-stamp} \
			--bucket_name ${storage}

local-serve: build-docker
	docker run --rm \
		-v ${PWD}/ml:/opt/ml \
		-p 8080:8080 \
		${container-name} serve \
			--project_name ${project-name} \
			--run_tag "${project-name}-${time-stamp}" \
			--bucket_name ${storage} \
			--model_server_workers 1

local-predict:
	curl --header "Content-Type: application/json" --request POST --data-binary @ml/input/invocation/payload.json http://localhost:8080/invocations
