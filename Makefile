# Load Config
include ./config

deploy-agones: create-gke-cluster \
	get-gke-credentials \
	create-gke-namespace \
	install-agones \
	validate-agones

#deploy-gcgs: gcgs-create-realm \
#	gcgs-create-cluster \
#	gcgs-deployment \
#	gcgs-deployment-create-configs \
#	gcgs-deployment-update-to-fleet-spec-3 \
#	gcgs-validate-rollout

# Used for testing
deploy-gcgs: gcgs-create-cluster \
	gcgs-deployment-update-to-fleet-spec-3 \
	gcgs-validate-rollout

create-gke-cluster:
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
	--enable-ip-alias #--async

get-gke-credentials:
	echo "[ INFO ] Retrieve the credentials for the GKE cluster"
	gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region=${REGION_US}

create-gke-namespace: 
	echo "[ INFO ] Creating GKE namespace ${GKE_NAMESPACE}"
	kubectl create namespace ${GKE_NAMESPACE}

install-agones:
	echo "[ INFO ] Installing agones"
	kubectl apply -f ${AGONES_YAML}

validate-agones:
	echo "[ INFO ] Validating agones, kubectl get"
	# validate that Agones system is running by checking the status of the Kubernetes pods:
	kubectl get --namespace ${GKE_NAMESPACE} pods

gcgs-create-realm:
	echo "[ INFO ] Creating Google Game Servers realm"
	gcloud game servers realms create ${GCGS_REALM_NAME} --time-zone EST --location ${REGION_US}

gcgs-create-cluster:
	gcloud game servers clusters create ${GCGS_CLUSTER_NAME} \
	--realm=${GCGS_REALM_NAME} \
	--gke-cluster locations/${REGION_US}/clusters/${GKE_CLUSTER_NAME} \
	--namespace=default \
	--location ${REGION_US} \
	--no-dry-run

gcgs-deployment:
	# Create deployment with no/empty config
	gcloud game servers deployments create ${GCGS_DEPLOYMENT}

gcgs-deployment-create-configs:
	gcloud game servers configs create fleet-spec-0  --deployment ${GCGS_DEPLOYMENT} --fleet-configs-file fleet_spec_0.yaml
	gcloud game servers configs create fleet-spec-1  --deployment ${GCGS_DEPLOYMENT} --fleet-configs-file fleet_spec_1.yaml
	gcloud game servers configs create fleet-spec-3  --deployment ${GCGS_DEPLOYMENT} --fleet-configs-file fleet_spec_3.yaml
	gcloud game servers configs create fleet-spec-9  --deployment ${GCGS_DEPLOYMENT} --fleet-configs-file fleet_spec_9.yaml
	gcloud game servers configs create fleet-spec-z1 --deployment ${GCGS_DEPLOYMENT} --fleet-configs-file fleet_spec_z1.yaml

gcgs-deployment-update-to-fleet-spec-0:
	gcloud game servers deployments update-rollout ${GCGS_DEPLOYMENT} --default-config fleet-spec-0 --no-dry-run

gcgs-deployment-update-to-fleet-spec-3:
	gcloud game servers deployments update-rollout ${GCGS_DEPLOYMENT} --default-config fleet-spec-3 --no-dry-run

gcgs-validate-rollout:
	# validate the rollout of one fleet under default namespace,
	kubectl get fleet

# Demo Setup and Deployment

demo-create-firewall:
	gcloud compute firewall-rules create gcgs-firewall-z1 \
	--allow udp:7000-8000 \
	--target-tags game-server \
	--description "Firewall to allow game server udp traffic"

demo-get-game-server:
	# get the IP address and port number for an individual game server
	kubectl get gameserver

