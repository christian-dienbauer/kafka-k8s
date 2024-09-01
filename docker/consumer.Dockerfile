# Use the official Python image based on Alpine
FROM python:3.9-alpine

# Set the working directory inside the container
WORKDIR /app

# Install required dependencies
RUN apk add --no-cache --update \
    bash \
    curl \
    gcc \
    musl-dev \
    linux-headers \
    libffi-dev \
    openssl-dev

# Copy the rest of the application code into the container
COPY src/kafka-consumer/*.py .
COPY requirements.txt .

# Install Python dependencies (if you have a requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt

# Run the Kafka producer script
CMD ["python", "main.py"]