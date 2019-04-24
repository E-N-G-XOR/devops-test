#!/usr/bin/env bash
set -xe

echo ECS_CLUSTER='${CLUSTER_NAME}' > /etc/ecs/ecs.config
