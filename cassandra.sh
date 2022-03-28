#!/usr/bin/env bash

# A script to install cassandra

# Add the seed nodes here
SEEDS[0]='10.1.1.1'
SEEDS[1]='10.1.1.2'
SEEDS[2]='10.1.1.3'


containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

function join { local IFS="$1"; shift; echo "$*"; }

# Install oracle java first
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo sh -c 'echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections'
sudo apt-get install -y oracle-java7-installer  oracle-java7-set-default


sudo sh -c "echo 'deb http://www.apache.org/dist/cassandra/debian 21x main
deb-src http://www.apache.org/dist/cassandra/debian 21x main' >> /etc/apt/sources.list"

gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | sudo apt-key add -

gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | sudo apt-key add -

gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
gpg --export --armor 0353B12C | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y cassandra

sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/data/system/*

# Extract ip address of eth0
IP_ADDR=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# common settings
sudo sed -i "s/cluster_name: 'Test Cluster'/cluster_name: 'XaarCluster'/g" /etc/cassandra/cassandra.yaml
sudo sed -i 's/endpoint_snitch: SimpleSnitch/endpoint_snitch: GossipingPropertyFileSnitch/g' /etc/cassandra/cassandra.yaml
ALL_SEEDS=`join , ${SEEDS[@]}`
sudo sed -i 's/- seeds: "127.0.0.1"/- seeds: "'${ALL_SEEDS[@]}'"/g' /etc/cassandra/cassandra.yaml

if [[ ${SEEDS[*]} =~ $IP_ADDR ]]; then
  # settings for seed node
  sudo sed -i 's/listen_address: localhost/listen_address: '${IP_ADDR}'/g' /etc/cassandra/cassandra.yaml
  sudo sed -i 's/rpc_address: localhost/rpc_address: '${IP_ADDR}'/g' /etc/cassandra/cassandra.yaml
  sudo sh -c "echo 'auto_bootstrap: false' >> /etc/cassandra/cassandra.yaml "
else
  # settings for other nodes
  sudo sed -i 's/listen_address: localhost/listen_address: '${IP_ADDR}'/g' /etc/cassandra/cassandra.yaml
  sudo sed -i 's/rpc_address: localhost/rpc_address: '${IP_ADDR}'/g' /etc/cassandra/cassandra.yaml
fi

sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/data/system/*
sudo service cassandra start
