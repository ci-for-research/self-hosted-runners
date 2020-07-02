#!/bin/bash

./config.sh \
    --token ${RUNNER_TOKEN} \
    --url https://github.com/${GITHUB_ORG}/${GITHUB_REPO} \
    --unattended \
    --replace

./run.sh
