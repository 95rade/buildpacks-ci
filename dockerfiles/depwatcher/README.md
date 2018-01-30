# Building/Pushing

docker build -t cfbuildpacks/depwatcher .
docker push cfbuildpacks/depwatcher

## Run locally

docker run -it cfbuildpacks/depwatcher sh
$ echo '{"source":{"type":"rubygems","name":"rails"}}' | /opt/resource/check
