#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

pushd bbl-state/"${ENV_NAME}"
  eval "$(bbl print-env)"
popd

bosh2 update-cloud-config cf-deployment/iaas-support/bosh-lite/cloud-config.yml

