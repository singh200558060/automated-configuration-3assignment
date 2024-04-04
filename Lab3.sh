#!/bin/bash
# Deployment script for server configuration

set_verbose_mode() {
    if [[ "$1" == "-verbose" ]]; then
        echo "-verbose"
    else
        echo ""
    fi
}

VERBOSE=$(set_verbose_mode "$1")

deploy_configuration() {
    server_alias="$1"
    host_identifier="$2"
    network_ip="$3"
    paired_host="$4"
    paired_ip="$5"
    
    scp "configure-host_v4.sh" "remoteadmin@${server_alias}-mgmt:/root"
    ssh "remoteadmin@${server_alias}-mgmt" -- "/root/configure-host_v4.sh $VERBOSE -setname $host_identifier -setip $network_ip -setentry $paired_host $paired_ip"
}

deploy_configuration "server1" "loghost" "192.168.16.3" "webhost" "192.168.16.4"
deploy_configuration "server2" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

# Apply configuration locally
./configure-host_v4.sh $VERBOSE -setentry "loghost" "192.168.16.3"
./configure-host_v4.sh $VERBOSE -setentry "webhost" "192.168.16.4"
