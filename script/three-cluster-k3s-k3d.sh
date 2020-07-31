#!/usr/bin/env bash

######################
### Helper script - 3 K8S cluster bsed on k3s in k3d (docker) - for kubectl "set-context" practice ####
#https://www.katacoda.com/courses/kubernetes/launch-single-node-cluster

#curl -sfL https://raw.githubusercontent.com/ishswar/two-clusters-on-katacoda/master/script/three-cluster-k3s-k3d.sh | bash -
######################

set -o errexit
set -o pipefail
set -o nounset

banner()
{
echo "================================================"
echo "============  $1  =============="
echo "================================================"
}

spacer()
{
  printf "\n-----------------------------------------------------------------------------\n"
}

runcommand()
{
	echo "Running command [$1]"
	echo 
	$1
}

banner "Downloading k3d install script"

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
spacer

echo "Now creating k3s clusters in respective k3d docker container"

banner "Creating cluster k8s"
runcommand "k3d cluster create k8s"

banner "Creating cluster dk8s"
runcommand "k3d cluster create dk8s"

banner "Creating cluster nk8s"
runcommand "k3d cluster create nk8s"
#k3d cluster create sk8s

spacer
echo "List all the cluster contextes"

kubectl config get-clusters

echo
banner "We are done"