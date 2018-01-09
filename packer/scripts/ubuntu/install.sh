#!/bin/bash -eux
export DEBIAN_FRONTEND="noninteractive"
apt-get update && apt-get upgrade -y

apt-get update && apt-get install -y \
  curl \
  git \
  python-pip \
  python3-venv \
  wget \

pip install awscli
aws --version