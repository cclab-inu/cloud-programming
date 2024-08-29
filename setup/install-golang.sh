#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install wget

# Get the latest version of Go
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)

# Define installation directory
INSTALL_DIR="/usr/local"

# Remove any previous Go installation
sudo rm -rf ${INSTALL_DIR}/go

# Download and extract the latest Go version
wget https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C ${INSTALL_DIR} -xzf ${GO_VERSION}.linux-amd64.tar.gz

# Set up Go environment
echo "export PATH=\$PATH:${INSTALL_DIR}/go/bin" >> ~/.profile
echo "export PATH=\$PATH:${INSTALL_DIR}/go/bin" >> ~/.bashrc
source ~/.profile
source ~/.bashrc

# Clean up
rm -rf ${GO_VERSION}.linux-amd64.tar.gz

# Verify installation
go version