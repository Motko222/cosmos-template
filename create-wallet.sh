#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

if [ -z $1 ]
then
 read -p "Key name ? " key
else
 key=$1
fi

$BINARY keys add $key
$BINARY keys show $key --bech val
