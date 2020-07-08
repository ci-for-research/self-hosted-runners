#!/bin/bash

export AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

if [[ -z "${RUNNER_NAME}" ]]; then
    RUNNER_NAME="docker-$(hostname)"
fi

ACTIONS_URL="https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/actions/runners/registration-token"
echo "Requesting registration URL at '${ACTIONS_URL}'"

PAYLOAD=$(curl -sX POST -H "Authorization: token ${PERSONAL_ACCESS_TOKEN}" "${ACTIONS_URL}")
RUNNER_TOKEN=$(echo "${PAYLOAD}" | jq .token --raw-output)

printf "\n\033[0;44m---> Configuring the runner.\033[0m\n"
./config.sh \
    --name "${RUNNER_NAME}" \
    --token "${RUNNER_TOKEN}" \
    --url "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}" \
    --work "${RUNNER_WORKDIR}" \
    --labels "docker,github" \
    --unattended \
    --replace

remove_runner() {
    printf "\n\033[0;44m---> Removing the runner.\033[0m\n"
    ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

# run remove_runner function if "./run.sh" script is interrupted
trap 'remove_runner; exit 130' INT
trap 'remove_runner; exit 143' TERM

printf "\n\033[0;44m---> Starting the runner.\033[0m\n"
./run.sh "$*" &
wait $!
