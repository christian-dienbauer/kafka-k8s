# Variables
DOCKER_NETWORK=host
KAFKA=kafka
KAFKA_IMAGE=apache/kafka:3.8.0
KAFKA_PORT=9092
KAFKA_SASL_USER=admin
KAFKA_SASL_PASSWORD=admin
KAFKA_CLUSTER_ID=1#V7OLY7FyQeSH2e0TKHaGLA # Example Cluster ID, use 'uuidgen' to create a new one

CONSUMER=consumer
CONSUMER_IMAGE=chrdie/kafka-consumer:no-sasl


PRODUCER=producer
PRODUCER_IMAGE=chrdie/kafka-producer:no-sasl

# Create a Docker network
.PHONY: network
network:
	@docker network create $(DOCKER_NETWORK) || true

# Run Kafka in KRaft mode with SASL
.PHONY: kafka
kafka: network
	@docker run --name $(KAFKA) --network $(DOCKER_NETWORK) \
	-p $(KAFKA_PORT):$(KAFKA_PORT) \
	-v ./kafka_server_jaas.conf:/etc/kafka/kafka_server_jaas.conf \
	-e KAFKA_NODE_ID=1 \
	-e KAFKA_PROCESS_ROLES=broker,controller \
	-e KAFKA_LISTENERS=SASL_PLAINTEXT://localhost:$(KAFKA_PORT),CONTROLLER://localhost:9093 \
	-e KAFKA_ADVERTISED_LISTENERS=SASL_PLAINTEXT://localhost:$(KAFKA_PORT) \
	-e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=SASL_PLAINTEXT:SASL_PLAINTEXT,CONTROLLER:PLAINTEXT \
	-e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
	-e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
	-e KAFKA_INTER_BROKER_LISTENER_NAME=SASL_PLAINTEXT \
	-e KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=SCRAM-SHA-512 \
	-e KAFKA_SASL_ENABLED_MECHANISMS=SCRAM-SHA-512 \
	-e KAFKA_OPTS="-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf" \
	-e KAFKA_SASL_JAAS_CONFIG="org.apache.kafka.common.security.scram.ScramLoginModule required username=\"$(KAFKA_SASL_USER)\" password=\"$(KAFKA_SASL_PASSWORD)\";" \
	$(KAFKA_IMAGE) \
	bash -c "echo '$(KAFKA_SASL_USER) SCRAM-SHA-512 $(echo -n $(KAFKA_SASL_PASSWORD) | base64)' > /tmp/password.txt && /opt/kafka/bin/kafka-storage.sh format -t $(KAFKA_CLUSTER_ID) -c /opt/kafka/config/kraft/server.properties && /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties"


# Run Kafka in KRaft mode without SASL
.PHONY: start-kafka-no-sasl
start-kafka-no-sasl: network
	docker run --name $(KAFKA) -p $(KAFKA_PORT):$(KAFKA_PORT) --network $(DOCKER_NETWORK) apache/kafka:3.8.0


.PHONY: consumer
consumer:
	docker run --name $(CONSUMER) --network $(DOCKER_NETWORK) $(CONSUMER_IMAGE)

.PHONY: producer
producer:
	docker run --name $(PRODUCER) --network $(DOCKER_NETWORK) $(PRODUCER_IMAGE)

.PHONY: build-consumer
build-consumer:
	docker build -t $(CONSUMER_IMAGE) -f docker/consumer.Dockerfile .

.PHONY: build-producer
build-producer:
	docker build -t $(PRODUCER_IMAGE) -f docker/producer.Dockerfile .

# Stop Kafka container
.PHONY: stop
stop:
	-@docker stop $(KAFKA)
	-@docker rm $(KAFKA)
	-@docker stop $(CONSUMER)
	-@docker rm $(CONSUMER)
	-@docker stop $(PRODUCER)
	-@docker rm $(PRODUCER)

# Clean up network
.PHONY: clean
clean:
	@docker network rm $(DOCKER_NETWORK) || true


