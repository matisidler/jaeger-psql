#!/bin/sh
# Generate the final plugin config file from the template
envsubst < /etc/jaeger/plugin-config.yaml.template > /etc/jaeger/plugin-config.yaml

# Start the cleaner in the background
/usr/local/bin/jaeger-postgresql-cleaner &

# Launch Jaeger all-in-one with the plugin endpoint flag
exec /go/bin/all-in-one --grpc-storage.server=127.0.0.1:12345
