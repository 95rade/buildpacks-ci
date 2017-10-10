$ErrorActionPreference = "Stop";
$env:GOPATH="C:/go-" + (-join ((48..57) + (97..122) | Get-Random -Count 6 | % {[char]$_}))
trap { $host.SetShouldExit(1); rm -Force $env:GOPATH }

$env:CREDENTIAL_FILTER_WHITELIST="SystemDrive,SERVICE_ID,NUMBER_OF_PROCESSORS,PROCESSOR_LEVEL,WINSW_SERVICE_ID,__PIPE_SERVICE_NAME"

$env:PATH=$env:GOPATH + "/bin;C:/go/bin;C:/var/vcap/bosh/bin;" + $env:PATH

$buildDir=$env:GOPATH + "/src/code.cloudfoundry.org/buildpackapplifecycle"
md -Force $buildDir

echo "Moving buildpackapplifecycle onto the gopath..."
cp bal-develop/* $buildDir -recurse

push-location $buildDir

  go get github.com/cloudfoundry-incubator/credhub-cli
  push-location ../../github.com/cloudfoundry-incubator/credhub-cli
    git remote add idoru https://github.com/idoru/credhub-cli
    git fetch idoru
    git checkout idoru/mtls-and-interpolate
  pop-location

  go get -t ./...
  go get github.com/onsi/ginkgo/ginkgo

  go get github.com/pivotal-cf-experimental/concourse-filter
  push-location ../../github.com/pivotal-cf-experimental/concourse-filter
    go build
  pop-location

  $(& ginkgo -r; $ExitCode="$LastExitCode") | concourse-filter

pop-location

rm -Force $env:GOPATH
Exit $ExitCode
