#!/bin/bash
ROOT_DIR=$(git rev-parse --show-toplevel)

set -x
set -e

cd "${ROOT_DIR}/packer"

for t in *.json; do
  "${ROOT_DIR}/ci/packer-ami.rb" build "${t%%.json}"
done
