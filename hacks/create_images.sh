DIR=${1:-.}
DOCKER_ACC=${2:-"registry.localhost:5000"}
IOTEDGE=${3:-"."} #default to run from same dir of the iotedge source code

# iotedged
docker build --no-cache -t $DOCKER_ACC/azureiotedge-agent:1.2-linux-amd64 --file $IOTEDGE/target/publish/Microsoft.Azure.Devices.Edge.Agent.Service/docker/linux/amd64/Dockerfile --build-arg EXE_DIR=. $IOTEDGE/target/publish/Microsoft.Azure.Devices.Edge.Agent.Service
docker image push $DOCKER_ACC/azureiotedge-agent:1.2-linux-amd64

# edgehub
docker build --no-cache -t $DOCKER_ACC/azureiotedge-hub:1.2-linux-amd64 --file $IOTEDGE/target/publish/Microsoft.Azure.Devices.Edge.Hub.Service/docker/linux/amd64/Dockerfile --build-arg EXE_DIR=. $IOTEDGE/target/publish/Microsoft.Azure.Devices.Edge.Hub.Service
docker image push $DOCKER_ACC/azureiotedge-hub:1.2-linux-amd64

# iotedged
docker build --no-cache -t $DOCKER_ACC/azureiotedge-iotedged:1.2-linux-amd64 --file $IOTEDGE/publish/azureiotedge-iotedged/docker/linux/amd64/Dockerfile --build-arg EXE_DIR=. $IOTEDGE/publish/azureiotedge-iotedged
docker image push $DOCKER_ACC/azureiotedge-iotedged:1.2-linux-amd64

# iotedge-proxy
docker build --no-cache -t $DOCKER_ACC/azureiotedge-proxy:1.2-linux-amd64 --file $IOTEDGE/publish/azureiotedge-proxy/docker/linux/amd64/Dockerfile --build-arg EXE_DIR=. $IOTEDGE/publish/azureiotedge-proxy
docker image push $DOCKER_ACC/azureiotedge-proxy:1.2-linux-amd64