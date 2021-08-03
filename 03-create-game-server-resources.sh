# Load Config
. ./config

# Check to see if Agones is in Running state
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

# Create a realm in the same location as the GKE cluster
gcloud game servers realms create ${GCGS_REALM_NAME} --time-zone EST --location ${REGION_US}

# Register your Agones GKE cluster with Game Servers and attach it to the realm you created in the previous step
gcloud game servers clusters create ${GCGS_CLUSTER_NAME} \
--realm=${GCGS_REALM_NAME} \
--gke-cluster locations/${REGION_US}/clusters/${GKE_CLUSTER_NAME} \
--namespace=default \
--location ${REGION_US} \
--no-dry-run

# Create a game server deployment
# This stores all your game server configurations - then you can roll them out to your game server clusters
gcloud game servers deployments create deployment-quickstart

# Create the game server config
gcloud game servers configs create config-1 --deployment deployment-quickstart --fleet-configs-file fleet_configs.yaml

# Update the rollout
gcloud game servers deployments update-rollout deployment-quickstart --default-config config-1 --no-dry-run

# Validate the rollout
kubectl get fleet

