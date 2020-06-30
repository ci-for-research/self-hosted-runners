#!/bin/bash

rm -fv ./id_rsa ./id_rsa.pub
ssh-keygen -b 2048 -t rsa -f ./id_rsa -q -N "" -C "ubuntu@garunner"

#docker build -t ghrunner --build-arg ssh_prv_key="$(cat ./id_rsa)" --build-arg ssh_pub_key="$(cat ./id_rsa.pub)" --squash .
docker build -t ghrunner \
	--build-arg ssh_prv_key="$(cat ./id_rsa)" \
	--build-arg ssh_pub_key="$(cat ./id_rsa.pub)" \
	.
