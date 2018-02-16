#!/bin/bash -l

set -o errexit
set -o nounset
set -o pipefail

wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v5.11.5/bbl-v5.11.5_linux_x86-64
chmod 755 bbl-v5.11.5_linux_x86-64
alias bbl "$PWD/bbl-v5.11.5_linux_x86-64"

pushd "bbl-state/$ENV_NAME"
  eval "$(bbl print-env)"
  bosh2 -n delete-deployment -d "${DEPLOYMENT_NAME}"
popd
