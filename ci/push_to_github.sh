#!/bin/bash
IMAGE_YML=images.yml
ROOT_DIR=$(git rev-parse --show-toplevel)

set -x
cd "${ROOT_DIR}"

if ! git diff --quiet "${IMAGE_YML}"; then
  git add "${IMAGE_YML}"
  git commit -m "images: Updated by Packer [ci skip]"
  git push origin HEAD:${CIRCLE_BRANCH}
else
  echo "No changes for ${IMAGE_YML}."
fi
