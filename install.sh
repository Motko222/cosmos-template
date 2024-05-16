#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
config=~/scripts/$folder/cfg

#install binary
#put instalation script here

$BINARY version
