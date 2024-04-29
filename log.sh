#!/bin/bash
folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

sudo journalctl -u $BINARY.service -f --no-hostname -o cat
