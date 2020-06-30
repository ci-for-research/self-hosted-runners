FROM ubuntu:20.04

ARG ssh_prv_key
ARG ssh_pub_key

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
USER ubuntu
WORKDIR /home/ubuntu

# Authorize SSH Host
RUN mkdir -p /home/ubuntu/.ssh && \
    chmod 0700 /home/ubuntu/.ssh && \
    ssh-keyscan ubuntu@garunner > /home/ubuntu/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /home/ubuntu/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /home/ubuntu/.ssh/id_rsa.pub && \
    chmod 600 /home/ubuntu/.ssh/id_rsa && \
    chmod 600 /home/ubuntu/.ssh/id_rsa.pub

# # SSH login fix. Otherwise user is kicked off after login
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
