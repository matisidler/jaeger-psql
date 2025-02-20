#!/bin/sh
# Generate the final plugin config file in a writable location (/tmp)
envsubst < /tmp/jaeger-config.yaml.template > /tmp/jaeger-config.yaml

# Start the cleaner in the background
/usr/local/bin/jaeger-postgresql-cleaner &

# Launch Jaeger all-in-one with the plugin endpoint flag.
# 'all-in-one' is assumed to be in the container's PATH.
exec all-in-one --grpc-storage.server=127.0.0.1:12345
