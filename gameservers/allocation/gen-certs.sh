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

#
# Script to setup server and client certificates appropriately across
# all the clusters
# Created from: https://agones.dev/site/docs/advanced/allocator-service/
#

# Return CERT_FOLDER after this is run.
cluster_setup() {
  echo "Setting up cluster: $1 $2"
  gcloud container clusters get-credentials $1 --zone $2
  CERT_FOLDER=./certs/$(kubectl config current-context)
  mkdir -p "$CERT_FOLDER" || true
}

server_cert() {
  echo "Setting up server certs: $1 $2"

  #!/bin/bash
  # Create a self-signed ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
EOF

  EXTERNAL_IP=`kubectl get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`

  # Create a Certificate with IP for the allocator-tls secret
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: allocator-selfsigned-cert
  namespace: agones-system
spec:
  commonName: ${EXTERNAL_IP}
  ipAddresses:
    - ${EXTERNAL_IP}
  secretName: allocator-tls
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
EOF

  # Optional: Store the secret ca.crt in a file to be used by the client for the server authentication
  TLS_CA_FILE=$CERT_FOLDER/ca.crt
  TLS_CA_VALUE=`kubectl get secret allocator-tls -n agones-system -ojsonpath='{.data.ca\.crt}'`

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    echo ${TLS_CA_VALUE} | base64 -D > ${TLS_CA_FILE}
  else
    echo ${TLS_CA_VALUE} | base64 -d > ${TLS_CA_FILE}
  fi

  # Add ca.crt to the allocator-tls-ca Secret
  kubectl get secret allocator-tls-ca -o json -n agones-system | jq '.data["tls-ca.crt"]="'${TLS_CA_VALUE}'"' | kubectl apply -f -
}

client_cert() {
  echo "Setting up server certs: $1 $2"

  KEY_FILE=$CERT_FOLDER/client.key
  CERT_FILE=$CERT_FOLDER/client.crt

  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=client"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    CERT_FILE_VALUE=`cat ${CERT_FILE} | base64`
  else
    CERT_FILE_VALUE=`cat ${CERT_FILE} | base64 -w 0`
  fi

  # white-list client certificate
  kubectl get secret allocator-client-ca -o json -n agones-system | jq '.data["client_trial.crt"]="'${CERT_FILE_VALUE}'"' | kubectl apply -f -
}

gcloud container clusters list --format="value(name,zone)" | grep game-cluster | while read -r line ; do
    cluster_setup $line
    server_cert $line
    client_cert $line
done

# The following commands are used to trigger Game Servers reconciliation of clusters within realm, instead of waiting for an hour for the changes to have effect. 
echo " The update realm is to trigger reconciliation between clusters."
gcloud game servers realms update united-states --update-labels=usage=testing --location=global --no-dry-run >/dev/null
gcloud game servers realms update europe --update-labels=usage=testing --location=global --no-dry-run >/dev/null
