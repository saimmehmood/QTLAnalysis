#!/bin/bash
#
# Cloud-init script to get Spark Worker up and running
#
SPARK_VERSION="1.5.0"
APACHE_MIRROR="apache.uib.no"
LOCALNET="192.168.0.0/24" #(IP of network topolgy, do change it according to your network)
SPARK_MASTER_IP="192.168.0.36" #(IP of spark master VM, you can check it by typing 'ifconfig' inside the terminal of spark master machine)
# Change above IP after checking it. 

# Firewall setup
ufw allow from $LOCALNET
ufw allow 8081/tcp

# Dependencies
apt-get -y update
apt-get -y install openjdk-7-jdk

# Download and unpack Spark
curl -o /tmp/spark-$SPARK_VERSION-bin-hadoop1.tgz http://$APACHE_MIRROR/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop1.tgz
tar xvz -C /opt -f /tmp/spark-$SPARK_VERSION-bin-hadoop1.tgz
ln -s /opt/spark-$SPARK_VERSION-bin-hadoop1/ /opt/spark
chown -R root.root /opt/spark-$SPARK_VERSION-bin-hadoop1/*

# Make sure our hostname is resolvable by adding it to /etc/hosts
echo $(ip -o addr show dev eth0 | fgrep "inet " | egrep -o '[0-9.]+/[0-9]+' | cut -f1 -d/) $HOSTNAME | sudo tee -a /etc/hosts
# Start Spark worker with address of Spark master to join cluster 
/opt/spark/sbin/start-slave.sh spark://$SPARK_MASTER_IP:7077
