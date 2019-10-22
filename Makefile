PROJECT_ID:=ci-cd-dev-test
ZONE:=us-central1-c

IMAGE_NAME:=travis-k8s-demo
IMAGE_VERSION:=v1
K8s_CLUSTER:=tekton-cluster

gauth:
	@gcloud auth activate-service-account --key-file credentials.json

gconfig:
	@gcloud config set project $(PROJECT_ID)
	@gcloud container clusters \
		get-credentials $(K8s_CLUSTER) \
		--zone $(ZONE) \
		--project $(PROJECT_ID)

build:
	@gcloud config list
	@gcloud config get-value project
	@gcloud builds submit --tag gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION) .

run:
	@docker run -p 8000:8000 gcr.io/$(PROJECT_ID)/$(IMAGE_NAME):$(IMAGE_VERSION)

deploy: gconfig
	@kubectl get ns
	@kubectl apply -f k8s.yaml
# https://github.com/kubernetes/kubernetes/issues/27081#issuecomment-238078103
	@kubectl patch deployment $(IMAGE_NAME) -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
