# Install Agones 
# https://cloud.google.com/game-servers/docs/quickstart
# https://agones.dev/site/docs/installation/install-agones/yaml/

# Load Config
. ./config

# Get cluster credentials for kubectl
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region ${REGION_US}

# Create Namespace
kubectl create namespace agones-system

# Install Agones
kubectl apply -f https://raw.githubusercontent.com/googleforgames/agones/release-1.16.0/install/yaml/install.yaml

# Wait for Agones to be in Running state
AGONES_STATE="$(kubectl get pods --namespace agones-system)"
if echo $AGONES_STATE | grep -v Running; then
    echo "$AGONES_STATE"
    echo ""
    echo "Agones is not yet in a Running state. Sleeping for 5 seconds, then try again."
    echo "kubectl get pods --namespace agones-system"
    echo ""
    sleep 5
else
    echo "Agones is running!"
fi