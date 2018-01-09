#!/bin/bash
set -e
CIRCLECI_CACHE_DIR="${HOME}/bin"
PACKER_VERSION="1.1.1"
PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"

if [ ! -f "${CIRCLECI_CACHE_DIR}/packer" ] || [[ ! "$(packer version)" =~ "Packer v${PACKER_VERSION}" ]]; then
  curl --silent -L --out /tmp/packer_${PACKER_VERSION}_linux_amd64.zip ${PACKER_URL}
  sudo unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/bin
  sudo strip /usr/bin/packer
  rm -f /tmp/packer_${PACKER_VERSION}_linux_amd64.zip 
fi

packer version

if [[ ! "$(ruby version)" ]]; then
  sudo apt-get install ruby-full 
fi

ruby -v