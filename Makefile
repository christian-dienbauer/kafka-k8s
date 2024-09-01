# VARIABLES
CONSUMER_IMAGE=chrdie/kafka-consumer:latest
PRODUCER_IMAGE=chrdie/kafka-producer:latest

# BUILD IMAGES
.PHONY: build-consumer
build-consumer:
	docker build -t $(CONSUMER_IMAGE) -f docker/consumer.Dockerfile .

.PHONY: build-producer
build-producer:
	docker build -t $(PRODUCER_IMAGE) -f docker/producer.Dockerfile .

# PUSH IMAGES
.PHONY: push-consumer
push-consumer:
	docker push $(CONSUMER_IMAGE)

.PHONY: push-producer
push-producer:
	docker push $(PRODUCER_IMAGE)

# DEPLOYMENT TO KUBERNETES
.PHONY: deploy-kafka
deploy-kafka:
	helm install my-kafka bitnami/kafka --versioin 26.4.3 -n development

.PHONY: deploy-consumer
deploy-consumer: 
	kubectl apply -f kubernetes/kafka-consumer/deployment.yaml

.PHONY: deploy-producer
deploy-producer: 
	kubectl apply -f kubernetes/kafka-producer/deployment.yaml
