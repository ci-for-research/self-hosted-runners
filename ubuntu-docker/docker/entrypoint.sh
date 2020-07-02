#!/bin/bash

if [[ -z "${RUNNER_NAME}" ]]; then
    RUNNER_NAME="docker-$(hostname)"
fi

printf "\n\033[0;44m---> Configuring the runner.\033[0m\n"
./config.sh \
    --name ${RUNNER_NAME} \
    --token ${RUNNER_TOKEN} \
    --url https://github.com/${GITHUB_ORG}/${GITHUB_REPO} \
    --work ${RUNNER_WORKDIR} \
    --labels "docker,github" \
    --unattended \
    --replace

printf "\n\033[0;44m---> Starting the runner.\033[0m\n"
./run.sh
