#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#apt update && apt upgrade -y
apt update -y
#install jdk 11
apt-get install -y openjdk-11-jre-headless
#Add confluent repository to apt 
#wget -qO - https://packages.confluent.io/deb/7.2/archive.key | apt-key add -
#add-apt-repository -y \
#    "deb [arch=amd64] https://packages.confluent.io/deb/7.2 stable main" && \
#    apt-get update -y
#install confluent platform	
#apt-get install -y \
#    confluent-platform \
#    confluent-security

#install python 3
add-apt-repository -y ppa:deadsnakes/ppa	
apt-get update -y
apt-get install python3.8 -y
#install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#install ansible 2.11
python3 -m pip install --user ansible-core==2.11