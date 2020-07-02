#!/bin/bash

./config.sh \
    --token ${RUNNER_TOKEN} \
    --url https://github.com/${GITHUB_ORG}/${GITHUB_REPO} \
    --name ${RUNNER_NAME} \
    --labels "docker,github" \
    --unattended \
    --replace

./run.sh
