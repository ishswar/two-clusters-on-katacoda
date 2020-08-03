#!/usr/bin/env bash

######################
### Helper script - 3 K8S cluster bsed on k3s in k3d (docker) - for kubectl "set-context" practice ####
#https://www.katacoda.com/courses/kubernetes/launch-single-node-cluster

#curl -sfL https://raw.githubusercontent.com/ishswar/two-clusters-on-katacoda/master/script/three-cluster-k3s-k3d.sh | bash -
######################

set -o errexit
set -o pipefail
set -o nounset

NUMBER_OF_NODES_CLUSTER_K8S=2
NUMBER_OF_NODES_CLUSTER_DK8S=0
NUMBER_OF_NODES_CLUSTER_NK8S=0


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

#https://www.cyberciti.biz/faq/how-to-display-countdown-timer-in-bash-shell-script-running-on-linuxunix/
countdown()
(
  IFS=:
  set -- $*
  secs=$(( ${1#0} * 3600 + ${2#0} * 60 + ${3#0} ))
  while [ $secs -gt 0 ]
  do
    sleep 1 &
    printf "\r%02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
    secs=$(( $secs - 1 ))
    wait
  done
  echo
)

banner "Downloading k3d install script"

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
spacer

echo "Now creating k3s clusters in respective k3d docker container"

banner "Creating cluster k8s"
runcommand "k3d cluster create k8s -a $NUMBER_OF_NODES_CLUSTER_K8S"

banner "Creating cluster dk8s"
runcommand "k3d cluster create dk8s -a $NUMBER_OF_NODES_CLUSTER_DK8S"

banner "Creating cluster nk8s"
runcommand "k3d cluster create nk8s-a $NUMBER_OF_NODES_CLUSTER_NK8S"
#k3d cluster create sk8s

spacer
echo "List all the cluster contextes"

kubectl config get-clusters

spacer

banner "Connecting to each cluster to check all is good"
countdown "00:00:10"
{
runcommand "kubectl get nodes --context k3d-k8s"
countdown "00:00:5"
runcommand "kubectl get nodes --context k3d-dk8s"
countdown "00:00:5"
runcommand "kubectl get nodes --context k3d-nk8s"
} || echo "One of the check failed"
 

echo
banner "We are done"