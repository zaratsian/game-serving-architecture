GCP_PROJECT_ID="globalgame"
GCP_ARTIFACT_REGISTRY_NAME="globalgame-simulator"
GCP_ARTIFACT_REGISTRY_CONTAINER_NAME="game-event-simulator"
GCP_ARTIFACT_REGISTRY_REGION="us-central1"

# Enable necessary GCP services
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Setup Google Artifact Registry
gcloud artifacts repositories create ${GCP_ARTIFACT_REGISTRY_NAME} \
--repository-format=docker \
--location=${GCP_ARTIFACT_REGISTRY_REGION} \
--description="Game Event Simulator"

# Verify that repo has been created
gcloud artifacts repositories list

# Set up authentication to Docker repositories in the region
gcloud auth configure-docker "${GCP_ARTIFACT_REGISTRY_REGION}-docker.pkg.dev"

REGISTRY="${GCP_ARTIFACT_REGISTRY_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${GCP_ARTIFACT_REGISTRY_NAME}"
echo "Artifact Registry Path: ${REGISTRY}"

# Build the image.
docker rmi -f $REGISTRY/${GCP_ARTIFACT_REGISTRY_CONTAINER_NAME}
docker build -t $REGISTRY/${GCP_ARTIFACT_REGISTRY_CONTAINER_NAME} .

# Push the image to the configured Registry.
docker push $REGISTRY/${GCP_ARTIFACT_REGISTRY_CONTAINER_NAME}
