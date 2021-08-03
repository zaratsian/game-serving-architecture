# Load Configs
. ./config

echo "Deleting Firewall Rule"
gcloud compute firewall-rules delete gcgs-quickstart-firewall

# Clear the rollout
gcloud game servers deployments update-rollout deployment-quickstart --clear-default-config --no-dry-run

# Delete Game Server config
gcloud game servers configs delete config-1 --deployment deployment-quickstart

# Delete Game Server Deployment
gcloud game servers deployments delete deployment-quickstart

# Delete Game Server Cluster
gcloud game servers clusters delete ${GCGS_CLUSTER_NAME} --realm=${GCGS_REALM_NAME} --location=${REGION_US} --no-dry-run

# Delete the Game Server Realms
gcloud game servers realms delete ${GCGS_REALM_NAME} --location=${REGION_US}

# Delete the GKE Cluster
gcloud container clusters delete ${GKE_CLUSTER_NAME} --zone=${REGION_US}

