PROJECT_ID:=ci-cd-dev-test
K8s_CLUSTER:=demo-guardian-assure-cluster
ZONE:=us-central1-c

IMAGE_NAME:=travis-k8s-demo
IMAGE_VERSION:=v1

gauth:
	@gcloud auth activate-service-account --key-file credentials.json

gconfig:
	@gcloud config set project $(PROJECT_ID)

build:
	@gcloud config list
	@gcloud config get-value project
	@gcloud builds submit --tag gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION) .

run:
	@docker run -p 8000:8000 gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION)

push:
	@docker push gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION)

deploy: gconfig
	@kubectl apply -f k8s.yaml
# https://github.com/kubernetes/kubernetes/issues/27081#issuecomment-238078103
	@kubectl patch deployment $(IMAGE_NAME) -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
