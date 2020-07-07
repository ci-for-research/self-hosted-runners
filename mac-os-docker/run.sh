docker run --rm --name ga-runner \
    -e PERSONAL_ACCESS_TOKEN="8ea42ed3e1d1e49046ae59cf1ffa1edca0cfec99" \
    -e RUNNER_NAME="hello" \
    -e RUNNER_WORKDIR="/tmp/actions-runner-hello" \
    -e GITHUB_ORG="AdamBelloum" \
    -e GITHUB_REPO="hello" \
    ga-runner:latest
