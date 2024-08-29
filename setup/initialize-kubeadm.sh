#!/bin/bash

# check if planning to use multi nodes
if [ "$MULTI" != "true" ] && [ "$MULTI" != "false" ]; then
    echo "Usage: MULTI={true|false} $0"
    exit
fi

# turn off swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# enable br_netfilter
sudo modprobe br_netfilter
if [ $(cat /proc/sys/net/bridge/bridge-nf-call-iptables) == 0 ]; then
    sudo bash -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
    sudo bash -c "echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf"
fi

# Use the detected CRI socket
CRI_SOCKET=${CRI_SOCKET:-/var/run/cri-dockerd.sock}

kubeadm config images pull

# initialize the master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=$CRI_SOCKET | tee -a ~/k8s_init.log
if [ $? != 0 ]; then
    echo "Failed to initialize kubeadm"
    exit
fi

# make kubectl work for non-root user
if [ ! -f $HOME/.kube/config ]; then
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $USER:$USER $HOME/.kube/config
    export KUBECONFIG=$HOME/.kube/config
    echo "export KUBECONFIG=$HOME/.kube/config" | tee -a ~/.bashrc
fi

# disable master isolation (due to the lack of resources)
if [ "$MULTI" != "true" ]; then
    # single-node case
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
fi

echo ">> Next Step <<"
echo "To deploy a CNI, run 'CNI={flannel|weave|calico|cilium} ./deploy-cni.sh'."