# kafka-k8s
Kafka producer and consumer deployed in Kubernetes.

Currently the system is running localy in docker container without using SASL authentication

## Local execution

### Build Docker images for producer and consumer

For the producer

```bash
make build prodcuer
```

For the consumer

```bash
docker build consumer
```

### Start Broker

First, start the kafka broker by opening the ports and using the network of the host

```bash
make kafka
```

### Start Consumer

Start the consumer using the host network

```bash
make consumer-no-sasl
```

### Start Producer

Start the producer using the host network

```bash
make producer-no-sasl
```
