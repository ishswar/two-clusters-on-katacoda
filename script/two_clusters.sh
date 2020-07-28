#!/usr/bin/env bash

######################
### Helper script - TWO K3S Clusters on two katakoda ubutnu machines - for kubectl "set-context" practice ####
######################

set -o errexit
set -o pipefail
set -o nounset

banner()
{
  echo "+------------------------------------------+"
  printf "| %-80s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-80s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

spacer()
{
  printf "\n-----------------------------------------------------------------------------\n"
}

HOST_NAME=$(hostname)

MACHINE_ONE=controlplane
MACHINE_TWO=node01

if [ "$HOST_NAME" = "$MACHINE_ONE" ]; then
        {
                banner "Installing K3S Cluster on Control Plan machine"
                echo "Running command: [curl -sfL https://get.k3s.io | sh -] to install K3S locally on machine $MACHINE_ONE"
                curl -sfL https://get.k3s.io | sh -
                spacer
                echo "Running command: [kubectl config get-contexts] to check kubec context avalable"
                kubectl config get-contexts
                echo "Running command: [kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes] to check if install is successfull or not"
                echo "below command might not get any data (No resources found) is expected"
                kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes || { echo "*********** K3S Ssetup seems to have issue needs to be invastigated ************" && exit; }
                banner "Now will try to get kube config from second cluster (on machine $MACHINE_TWO) and merge it with local config"
                echo "Running command: [scp -q -o LogLevel=QUIET $MACHINE_TWO:/etc/rancher/k3s/k3s.yaml $MACHINE_TWO.config.yaml] to get remote cluster config file"
                # We assume remote machine has already k3s cluster installed and SSH is possible without credentails
                n=0
				while [ "$n" -lt 10 ] && ! scp -q -o LogLevel=QUIET $MACHINE_TWO:/etc/rancher/k3s/k3s.yaml $MACHINE_TWO.config.yaml; do
				    n=$(( n + 1 ))
				    TURNLEFT=$(( 10 - $n ))
				    echo "Looks like $MACHINE_TWO K3S config is not ready yet; will try $TURNLEFT more time (after 10 seconds)"
				    sleep 10
				done
				FILE=$MACHINE_TWO.config.yaml
				if [ -f "$FILE" ]; then
					echo "Done downloaded Kube config from $MACHINE_TWO - now merging it locally"
          			spacer
					echo "Updating [$FILE] for cluster info (name,IP etc)"
					sed -i 's/default/cluster2/g' $FILE
					sed -i "s/127.0.0.1/$MACHINE_TWO/g" $FILE
          			spacer
					echo "Updating file [/etc/rancher/k3s/k3s.yaml] local cluster info for cluster context name - change it from 'default' to 'cluster1'"
					sed -i 's/default/cluster1/g' /etc/rancher/k3s/k3s.yaml

					# Add both configs to KUBECONFIG
					export KUBECONFIG=/etc/rancher/k3s/k3s.yaml:$MACHINE_TWO.config.yaml
					mkdir -p .kube
					echo "Building combine kube config file to connec to both clusters"
					kubectl config view --flatten > ~/.kube/config
          			spacer
					echo "Swithing kubectl context to cluster2"
					kubectl config use-context cluster2
          			spacer
					echo "Avalable cluster context in kube config file"
					kubectl config get-contexts
          			spacer
					echo "Getting Remote clusters [cluster2] nodes"
					kubectl get nodes || { echo "********* Failed to get nodes from cluster [cluster2/$MACHINE_TWO] this needs tob e invastigated ********" && exit; }
          			spacer

					echo "Logging into Remote machine to setup it's kubectl config file (this is optional step)"
					ssh $MACHINE_TWO mkdir -p ~/.kube
					ssh $MACHINE_TWO cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
					echo "===== WE ARE DONE ====="

				else
				    echo "************ $FILE does not exist. - Failed to download it from $MACHINE_TWO ? ***************"
				    exit
				fi

        }
elif [ "$HOST_NAME" = "$MACHINE_TWO" ]; then
        {
                banner "Processing $MACHINE_TWO installing k3s cluster - we will work on this cluster from machine [$MACHINE_ONE]"
                curl -sfL https://get.k3s.io | sh -
        }
else
	{
				echo "No Host matched for processing - exiting the script without doing anything"
	}
fi


