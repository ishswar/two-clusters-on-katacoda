
#!/usr/bin/env bash

######################
### Helper script - Creating cluster ####
######################

set -o errexit
set -o pipefail
set -o nounset

HOST_NAME=$(hostname)

MACHINE_ONE=controlplane
MACHINE_TWO=node01

if [ "$HOST_NAME" = "$MACHINE_ONE" ]; then
        {
                echo "Installing K3S Cluster on Control Plan machine"
                curl -sfL https://get.k3s.io | sh -
                echo "Now will try to get second cluster kube config and merge it with local config"
                mkdir -p .kube
                n=0
				while [ "$n" -lt 10 ] && ! scp $MACHINE_TWO:/etc/rancher/k3s/k3s.yaml $MACHINE_TWO.config.yaml; do
				    n=$(( n + 1 ))
				    TURNLEFT=$(( 10 - $n ))
				    echo "Looks like $MACHINE_TWO config is not ready yet will try $TURNLEFT more time"
				    sleep 10
				done
				FILE=$MACHINE_TWO.config.yaml
				if [ -f "$FILE" ]; then
					sed -i 's/default/cluster2/g' $MACHINE_TWO.config.yaml
					sed -i "s/127.0.0.1/$MACHINE_TWO/g" $MACHINE_TWO.config.yaml
					export KUBECONFIG=/etc/rancher/k3s/k3s.yaml:$MACHINE_TWO.config.yaml
					kubectl config view --flatten > ~/.kube/config
					kubectl config use-context cluster2
					kubectl config get-contexts
					kubectl get nodes
				else 
				    echo "$FILE does not exist."
				    exit
				fi

        }
elif [ "$HOST_NAME" = "$MACHINE_TWO" ]; then
        {
                echo "Processing node01 installing k3s cluster"
                curl -sfL https://get.k3s.io | sh -
        }
else
	{
				echo "No Host matched for processing"
	}
fi




#scp node01:/etc/rancher/k3s/k3s.yaml node01.config.yaml
