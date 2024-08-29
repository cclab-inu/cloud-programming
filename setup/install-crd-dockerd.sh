#!/bin/bash

# Install Go
# ./tools/languages/install-golang.sh
sudo apt install golang-go -y
go version

# Build cri-dockerd
cd ~
rm -rf ~/cri-dockerd

git clone https://github.com/Mirantis/cri-dockerd.git
mkdir -p cri-dockerd/bin
cd ~/cri-dockerd
rm -rf bin
mkdir bin
go build -o bin/cri-dockerd

# Install cri-dockerd binary
sudo mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd

# Set up systemd service
sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

# Reload systemd and enable services
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# Restart and check the status of services
sudo systemctl restart cri-docker.service
sudo systemctl status cri-docker.service
sudo systemctl status cri-docker.socket

# Configure Docker to use systemd cgroup driver
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Clean up
sudo rm -rf cri-dockerd