#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

[ -z $1 ] && read -p "Key name ? " key || key=$1

$BINARY keys add $key
$BINARY keys show $key --bech val
