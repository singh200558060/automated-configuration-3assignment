#!/bin/bash
# Host configuration script with enhanced logging

disable_signal_handling() {
    trap '' 1 2 15  # Ignore HUP, INT, TERM signals
}

disable_signal_handling

VERBOSE=0
HOST_NAME_UPDATE=0
IP_UPDATE=0

apply_hostname() {
    target_host="$1"
    if [[ "$(hostname)" != "$target_host" ]]; then
        hostname "$target_host"
        echo "$target_host" > /etc/hostname
        HOST_NAME_UPDATE=1
        logger "Hostname updated to $target_host"
    fi
    [[ $VERBOSE -eq 1 ]] && [[ $HOST_NAME_UPDATE -eq 1 ]] && echo "Hostname now $target_host" || echo "Hostname was already set."
}

set_ip_address() {
    target_ip="$1"
    net_dev=$(ip route show default | awk '/default/ {print $5}' | head -n 1)
    if [[ $(ip addr show $net_dev | grep -o "$target_ip") != "$target_ip" ]]; then
        ip addr add "$target_ip/24" dev "$net_dev"
        IP_UPDATE=1
        logger "IP set to $target_ip on interface $net_dev"
    fi
    [[ $VERBOSE -eq 1 ]] && [[ $IP_UPDATE -eq 1 ]] && echo "IP updated to $target_ip" || echo "IP was not changed."
}

update_hosts() {
    new_host="$1"
    new_ip="$2"
    if ! grep -q "$new_ip $new_host" /etc/hosts; then
        echo "$new_ip $new_host" >> /etc/hosts
        logger "Added $new_host ($new_ip) to /etc/hosts"
    fi
    [[ $VERBOSE -eq 1 ]] && echo "Ensured $new_host ($new_ip) is in /etc/hosts."
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -verbose) VERBOSE=1 ;;
        -setname) apply_hostname "$2"; shift ;;
        -setip) set_ip_address "$2"; shift ;;
        -setentry) update_hosts "$2" "$3"; shift 2 ;;
    esac
    shift
done
