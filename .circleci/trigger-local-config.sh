#!/usr/bin/env bash

CURRENT_SHA1=$(git rev-parse HEAD)

# $repo/tree/$branch?circle-token=$CIRCLE_TOKEN"

curl \
    --user ${CIRCLE_TOKEN}: \
    --request POST \
    --form revision=${CURRENT_SHA1} \
    --form config=@config.yml \
    --form notify=false \
        https://circleci.com/api/v1.1/project/github/simonmcc/circleci-packer-1/tree/master
