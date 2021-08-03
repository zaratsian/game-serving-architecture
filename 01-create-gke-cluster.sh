# Load Config
. ./config

# Create Google GKE Clusters
# https://cloud.google.com/game-servers/docs/quickstart
gcloud container clusters create ${GKE_CLUSTER_NAME} \
--cluster-version=${GKE_VERSION} \
--region=${REGION_US} \
--machine-type=${MACHINE_TYPE} \
--tags=game-server \
--scopes=gke-default \
--num-nodes=${MIN_NODES} \
--min-nodes=${MIN_NODES} \
--max-nodes=${MAX_NODES} \
--enable-autoscaling \
--no-enable-autoupgrade \
--enable-ip-alias \
--async

