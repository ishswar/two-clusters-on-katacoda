#!/bin/bash

functino banner()
{
echo "================================================"
echo "============  $1  =============="
echo "================================================"
}



echo “Downloading k3d install script”

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
echo “Now creating k3s clusters in respective k3d docker container”
banner "Creating cluster k8s"
k3d cluster create k8s
banner "Creating cluster dk8s"
k3d cluster create dk8s
banner "Creating cluster dk8s"
k3d cluster create dk8s
#k3d cluster create sk8s
kubectl config get-clusters

echo “We are done”