#!/bin/bash

# Copyright 2020 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x

# Get Cluster Credentials 
cluster_setup() {
  echo "Setting up cluster: $1 $2"
  gcloud container clusters get-credentials $1 --zone $2
  CERT_FOLDER=./certs/$(kubectl config current-context)
  mkdir -p "$CERT_FOLDER" || true
}

# Loop through each cluster and get cluster credentials
gcloud container clusters list --format="value(name,zone)" | grep game-cluster | while read -r line ; do
    cluster_setup $line
done

# Set variables
NAMESPACE=default
EXTERNAL_IP=`kubectl get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
echo "Allocation Service External IP: ${EXTERNAL_IP}"
CERT_FOLDER=$(pwd)/certs/$(kubectl config current-context)

echo "Getting Fleet"
kubectl get fleet

go run main.go --ip ${EXTERNAL_IP} \
    --namespace ${NAMESPACE} \
    --key "${CERT_FOLDER}/client.key" \
    --cert "${CERT_FOLDER}/client.crt" \
    --cacert "${CERT_FOLDER}/ca.crt" \
    --multicluster true

echo "Getting Fleet"
kubectl get fleet