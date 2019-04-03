#!/usr/bin/env bash
apt-get update 
apt-get upgrade -y
apt-get check-update
packages=(
    tree
    mc
    git
    wget
    unzip
    java-1.8.0-openjdk-devel.x86_64
    vim
    nano
)
apt-get install -y "${packages[@]}"
