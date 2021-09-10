# Load Config
. ../config

#echo "[ INFO ] Getting Agones SDK"
#go get agones.dev/agones/pkg/sdk

#echo "[ INFO ] Initializing go module"
#go mod init example.com/simple-game-server

#echo "[ INFO ] Running go mod tidy"
#go mod tidy

#echo "[ INFO ] Building main.go"
#GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/server -a -v main.go

echo "[ INFO ] Building docker image"
docker build -t gcr.io/${GCP_PROJECT_ID}/game-server-z1:v1 .

echo "[ INFO ] Push docker image to container registry"
docker push gcr.io/${GCP_PROJECT_ID}/game-server-z1:v1
