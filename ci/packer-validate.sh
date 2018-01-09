#!/bin/bash
ROOT_DIR=$(git rev-parse --show-toplevel)

set -x
set -e

cd "${ROOT_DIR}/packer"

for t in *.json; do
  packer validate "${t}"
done
