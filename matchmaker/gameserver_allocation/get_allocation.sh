# Agones Allocator Service
# https://agones.dev/site/docs/advanced/allocator-service/
#
# Agones provides an mTLS based allocator service that is accessible 
# from outside the cluster using a load balancer. The service is 
# deployed and scales independent to Agones controller.

# Load Config
. ../../config

echo "Verify service is up and running"
kubectl get pod -n agones-system | grep agones-allocator
echo "Get Agones Allocator details"
kubectl get service agones-allocator -n agones-system


# Get Cluster Credentials
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region ${REGION_US}

#######################################
# Get External IP of Allocator Service
#######################################
kubectl get service agones-allocator -n ${GKE_NAMESPACE}
EXTERNAL_IP=$(kubectl get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "External IP: $EXTERNAL_IP"

#######################################
# Configure Allocator TLS Secret
#######################################
# Install Cert Manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml
# Create a self-signed ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
EOF

# Create a Certificate with IP for the allocator-tls secret
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: allocator-tls
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

# Add ca.crt to the allocator-tls-ca Secret
TLS_CA_VALUE=$(kubectl get secret allocator-tls -n agones-system -ojsonpath='{.data.ca\.crt}')
kubectl get secret allocator-tls-ca -o json -n agones-system | jq '.data["tls-ca.crt"]="'${TLS_CA_VALUE}'"' | kubectl apply -f -
echo $TLS_CA_VALUE | base64 -d > ca.crt

#######################################
# Generate Client Cert
#######################################
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout client.key -out client.crt -addext 'subjectAltName=IP:'${EXTERNAL_IP}''
CERT_FILE_VALUE=$(cat client.crt | base64 -w 0)
# allowlist client certificate
kubectl get secret allocator-client-ca -o json -n agones-system | jq '.data["client_trial.crt"]="'${CERT_FILE_VALUE}'"' | kubectl apply -f -

# Make API Call to get Allocation
KEY_FILE=client.key
CERT_FILE=client.crt
TLS_CA_FILE=ca.crt
#kubectl get secret allocator-tls-ca -n agones-system -ojsonpath="{.data.tls-ca\.crt}" | base64 -d > "${TLS_CA_FILE}"
curl --key ${KEY_FILE} --cert ${CERT_FILE} --cacert ${TLS_CA_FILE} -H "Content-Type: application/json" --data '{"namespace":"agones-system"}' https://${EXTERNAL_IP}/gameserverallocation -XPOST
