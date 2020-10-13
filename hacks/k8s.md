# Steps to create a local IotEdge development enviornment

## Install a local Kubernetes cluster

- Install K3d
```
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

- Add your user to docker group
  
```
sudo usermod -aG docker ${USER}
```

- Create a local docker repo
```
docker volume create local_registry
docker container run -d --name registry.localhost -v local_registry:/var/lib/registry --restart always -p 5000:5000 registry:2
```

- Create a registries.yaml for k3d to use
```
mirrors:
  "registry.localhost:5000":
    endpoint:
      - http://registry.localhost:5000
```

- Run a k3d cluster with local the local registry

```
k3d cluster create multiserver --servers 1 registries.yaml:/etc/rancher/k3s/registries.yaml"
docker network connect k3d-multiserver registry.localhost
```

- Install helm3

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

- Install dotNet

```
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
```

```
sudo apt-get update; \
sudo apt-get install -y apt-transport-https && \
sudo apt-get update && \
sudo apt-get install -y dotnet-sdk-3.1
```

```
sudo apt-get update; \
sudo apt-get install -y apt-transport-https && \
sudo apt-get update && \
sudo apt-get install -y aspnetcore-runtime-3.1
```

- Install rust and dependencies
```
./edgelet/build/linux/install.sh
```

## Cloud side setup

- Create an IoT Hub
 
 ```
 az iot hub create --resource-group <rg> --name <hub> --sku F1 --partition-count 2
 ```

- Create a device idenity
 ```
 az iot hub device-identity create --device-id <dev-name> --edge-enabled --hub-name <hub>
 ```

- View connection string
 ```
 az iot hub device-identity show-connection-string --device-id <dev-name> --hub-name <hub>
 ```

- Simulated module
```
https://docs.microsoft.com/azure/iot-edge/quickstart-linux#deploy-a-module
```

## Compile and Build images

Run the following steps from the source directory

- Build EdgeAgent and EdgeHub

```
  ./scripts/linux/buildBranch.sh
```

or manually using (use only for rapid compilation and not to build the
images)

```
dotnet build
```

- Build Edgelet

```
git submodule update --init --recursive
```

``` 
BUILD_REPOSITORY_LOCALPATH=$PWD ./scripts/linux/buildEdgelet.sh  -i azureiotedge-iotedged -P iotedged --bin-dir .
```
 
``` 
BUILD_REPOSITORY_LOCALPATH=$PWD ./scripts/linux/buildEdgelet.sh  -i azureiotedge-proxy  -P  iotedge-proxy --bin-dir .
```

Or manually (use only for rapid compilation and not to build the
images)

```
cargo build
```

- Build Docker images (pushed to a local repo)

This script updates the four docker images of edgeHub, edgeAgent,
iotedged, and proxy and push them to a local repository.

```
./create_images.sh
```

## Create a private helm repository

Create a private helm repo for testing changes in helm charts and
values using github pages.

- Create a github page out of a repo. Let's say the repo is 
```<my-github-helm-repo>```

```
https://pages.github.com/
```

```
> cd <my-github-helm-repo>
> helm package <path to iodedged source>/kubernetes/charts/edge-kubernetes
> helm package <path to iodedged source>/kubernetes/charts/edge-kubernetes-crd
> helm repo index .
> git add .
> git commit -m "chart update"
> git push
```

## Install images from local repository and private helm chart

```
helm install --repo https://<url-of-your-github-page>  edge1 edge-kubernetes --debug -f override.yaml 
```