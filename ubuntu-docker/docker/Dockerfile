FROM ubuntu:19.10

ARG SSH_USER
ARG SSH_PASS

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_VERSION=2.267.1

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    sudo \
    tar

RUN printf "\n\033[0;44m---> Creating SSH user.\033[0m\n"
RUN useradd -rm -d /home/${SSH_USER} -s /bin/bash -G sudo -u 1001 ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASS}" | chpasswd
WORKDIR /home/${SSH_USER}/actions-runner
