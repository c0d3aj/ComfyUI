#!/bin/bash
docker login registry.quantdevlabs.com
docker build -t registry.quantdevlabs.com/machine-learning/cgc-comfy-ui .
docker push registry.quantdevlabs.com/machine-learning/cgc-comfy-ui