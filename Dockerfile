# Build stage: compile the plugin and cleaner binaries using Go 1.21
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
# Clone the repository and check out version v1.7.0
RUN git clone https://github.com/robbert229/jaeger-postgresql.git . \
    && git checkout v1.7.0
# Build the PostgreSQL plugin binary
RUN go build -o jaeger-postgresql ./cmd/jaeger-postgresql
# Build the cleaner binary
RUN go build -o jaeger-postgresql-cleaner ./cmd/jaeger-postgresql-cleaner

# Final stage: create the Jaeger image with the plugin and cleaner embedded
FROM jaegertracing/all-in-one:1.55.0

# Copy the built binaries from the builder stage
COPY --from=builder /app/jaeger-postgresql /usr/local/bin/jaeger-postgresql
COPY --from=builder /app/jaeger-postgresql-cleaner /usr/local/bin/jaeger-postgresql-cleaner

# Copy the plugin configuration template to /tmp (a writable location)
COPY plugin-config.yaml.template /tmp/jaeger-config.yaml.template

# Copy the entrypoint script with executable permissions
COPY --chmod=+x entrypoint.sh /entrypoint.sh

# Set environment variables so Jaeger uses the grpc-plugin storage type
ENV SPAN_STORAGE_TYPE="grpc-plugin" \
    GRPC_STORAGE_PLUGIN_BINARY="/usr/local/bin/jaeger-postgresql" \
    GRPC_STORAGE_PLUGIN_CONFIGURATION_FILE="/tmp/jaeger-config.yaml"

# Expose Jaeger ports plus the plugin port (12345)
EXPOSE 14268 16686 14250 12345

# Use our entrypoint script to perform env substitution and start services
ENTRYPOINT ["/entrypoint.sh"]
