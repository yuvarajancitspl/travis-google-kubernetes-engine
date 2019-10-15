KEY_FILE:=gcloud-service-account-secret.json
PROJECT_ID:=assure-dev
K8s_CLUSTER:=demo-guardian-assure-cluster
ZONE:=us-central1-c

IMAGE_NAME:=travis-k8s-demo
IMAGE_VERSION:=v1

gauth:
    @echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/credentials.json
	@gcloud auth activate-service-account --key-file ${KEY_FILE}

gconfig:
	@gcloud config set project $(PROJECT_ID)
	@gcloud container clusters \
		get-credentials $(K8s_CLUSTER) \
		--zone $(ZONE) \
		--project $(PROJECT_ID)
	@gcloud auth configure-docker

build:
	@docker build -t gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION) .

run:
	@docker run -p 8000:8000 gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION)

push:
	@docker push gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION)

deploy: gconfig
	@kubectl apply -f k8s.yaml
# https://github.com/kubernetes/kubernetes/issues/27081#issuecomment-238078103
	@kubectl patch deployment $(IMAGE_NAME) -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
