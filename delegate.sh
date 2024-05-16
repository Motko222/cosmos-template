#!/bin/bash

#usage: bash delegate.sh <key> <valoper> <amount>

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

[ -z $1 ] && read -p "From ($KEY) ? " key || key=$1
[ -z $key ] && key=$KEY

wallet=$(echo $PASS | $BINARY keys show $key -a)
balance=$($BINARY query bank balances $wallet -o json 2>/dev/null | jq -r '.balances[] | select(.denom=="'$DENOM'")' | jq -r .amount)
echo "Balance: $balance $DENOM"

def_valoper=$(echo $PASS | $BINARY keys show $KEY -a --bech val)
[ -z $2 ] && read -p "To valoper (default $def_valoper) ? " valoper || valoper=$2
[ -z $valoper ] && valoper=$def_valoper

[ -z $3 ] && read -p "Amount ? " amount || amount=$3

echo $PASS | $BINARY tx staking delegate $valoper $amount$DENOM --from $key \
 --gas-prices $GAS_PRICE --gas-adjustment $GAS_ADJ --gas auto -y | tail -1
