FROM ubuntu:18.04

ARG DOCKER_USER=tester
ARG DOCKER_PASS=password

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_VERSION=2.267.1
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        libcurl4-openssl-dev \
        tar && \
    rm -rf /var/lib/apt/lists/*

RUN printf "\n\033[0;44m---> Creating SSH user.\033[0m\n"
RUN useradd -rm -d /home/${DOCKER_USER} -s /bin/bash -G ${DOCKER_USER} -u 1001 ${DOCKER_USER}
RUN echo "${DOCKER_USER}:${DOCKER_PASS}" | chpasswd
WORKDIR /home/${DOCKER_USER}/actions-runner

RUN curl -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" > actions_runner.tar.gz && \
    tar -zxf actions_runner.tar.gz && \
    rm -f actions_runner.tar.gz && \
    ./bin/installdependencies.sh

RUN chown -R ${DOCKER_USER} /home/${DOCKER_USER}
RUN mkdir -p /opt/hostedtoolcache && chown -R ${DOCKER_USER}:${DOCKER_USER} $AGENT_TOOLSDIRECTORY

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER ${DOCKER_USER}

ENTRYPOINT ["/entrypoint.sh"]
