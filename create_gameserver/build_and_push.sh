# Load Config
. ../config

echo "[ INFO ] Building docker image"
docker build -t gcr.io/${GCP_PROJECT_ID}/game-server-z1:v1 .

echo "[ INFO ] Push docker image to container registry"
docker push gcr.io/${GCP_PROJECT_ID}/game-server-z1:v1
