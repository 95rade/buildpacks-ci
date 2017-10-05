#!/bin/bash -l

set -o errexit
set -o nounset
set -o pipefail

export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
mkdir -p "$GOPATH"

CF_DIR=$GOPATH/src/code.cloudfoundry.org
mkdir -p "$CF_DIR"/buildpackapplifecycle

echo "Moving buildpackapplifecycle onto the gopath..."
cp -R bal-develop/* "$CF_DIR"/buildpackapplifecycle

cd "$CF_DIR/buildpackapplifecycle"

go get -t ./...
go get github.com/onsi/ginkgo/ginkgo
pushd ../../github.com/cloudfoundry-incubator/credhub-cli
  git remote add idoru https://github.com/idoru/credhub-cli
  git fetch idoru
  git checkout idoru/interpolate-api
popd
ginkgo -r
