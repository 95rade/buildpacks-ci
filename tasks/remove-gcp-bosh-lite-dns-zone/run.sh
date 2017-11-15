#!/usr/bin/env bash

echo "$GCP_SERVICE_ACCOUNT_KEY" > /tmp/gcp_key

set -o errexit
set -o nounset
set -o pipefail

ZONE_NAME="${ENV_NAME}"-zone
DNS_NAME="${ENV_NAME}.buildpacks-gcp.ci.cf-app.com."
BOSH_LITE_IP=$(cd "bbl-state/${ENV_NAME}" && bbl bosh-deployment-vars | grep external_ip | awk '{print $2}')

gcloud auth activate-service-account --key-file /tmp/gcp_key

gcloud config set project cf-buildpacks

# remove the parent zone records
gcloud dns record-sets transaction start --zone="${ZONE_NAME}"
  gcloud dns record sets transaction remove "${BOSH_LITE_IP}" --name='*.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
  gcloud dns record-sets transaction remove "${BOSH_LITE_IP}" --name='bosh.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
  gcloud dns record-sets transaction remove "${BOSH_LITE_IP}" --name='doppler.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
  gcloud dns record-sets transaction remove "${BOSH_LITE_IP}" --name='loggregator.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
  gcloud dns record-sets transaction remove "${BOSH_LITE_IP}" --name='ssh.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
  gcloud dns record-sets transaction remove "${BOSH_LITE_IP}" --name='tcp.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
  gcloud dns record-sets transaction remove "${BOSH_LITE_IP}" --name='*.ws.'"${DNS_NAME}" --ttl=300 --type=A --zone="${ZONE_NAME}"
gcloud dns record-sets transaction execute --zone="${ZONE_NAME}"

# get the NS
NAMESERVERS=$(gcloud dns managed-zones describe "${ZONE_NAME}" --format='value[delimiter="
"](nameServers)')

#remove zone
gcloud dns managed-zones delete "${ZONE_NAME}"

# remove the parent zone (buildpacks zone) subdomain NS records
gcloud dns record-sets transaction start --zone=buildpacks
  # shellcheck disable=SC2086
  gcloud dns record sets transaction remove ${NAMESERVERS} --name "${DNS_NAME}" --ttl=300 --type=NS --zone=buildpacks
gcloud dns record-sets transaction execute --zone=buildpacks
