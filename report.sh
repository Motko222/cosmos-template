#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg
source ~/.bash_profile

bucket=validator
rpc_port=$(mantrachaind config | jq -r .node | cut -d : -f 3)
json=$(curl -s localhost:$rpc_port/status | jq .result.sync_info)
pid=$(pgrep $BINARY)
version=$($BINARY version)
network=$($BINARY status | jq -r .NodeInfo.network)
type="validator"
foldersize1=$(du -hs ~/.pryzm | awk '{print $1}')
#foldersize2=$(du -hs ~/pryzm | awk '{print $1}')
latestBlock=$(echo $json | jq -r .latest_block_height)
catchingUp=$(echo $json | jq -r .catching_up)
votingPower=$($BINARY status 2>&1 | jq -r .ValidatorInfo.VotingPower)
chain=$(echo $json | jq -r '."chain-id"')
wallet=$(echo $PASS | $BINARY keys show $KEY -a)
valoper=$(echo $PASS | $BINARY keys show $KEY -a --bech val)
moniker=$($BINARY query staking validator $valoper -o json | jq -r .description.moniker)
pubkey=$($BINARY tendermint show-validator --log_format json | jq -r .key)
delegators=$($BINARY query staking delegations-to $valoper -o json | jq '.delegation_responses | length')
jailed=$($BINARY query staking validator $valoper -o json | jq -r .jailed)
if [ -z $jailed ]; then jailed=false; fi
tokens=$($BINARY query staking validator $valoper -o json | jq -r .tokens | awk '{print $1/1000000}')
balance=$($BINARY query bank balances $wallet -o json 2>/dev/null \
      | jq -r '.balances[] | select(.denom=="'$DENOM'")' | jq -r .amount)
active=$($BINARY query tendermint-validator-set | grep -c $pubkey)
threshold=$($BINARY query tendermint-validator-set -o json | jq -r .validators[].voting_power | tail -1)

if $catchingUp
 then 
  status="syncing"
  message="height=$latestBlock"
 else 
  if [ $active -eq 1 ]; then status=active; else status=inactive; fi
fi

if $jailed
 then
  status="error"
  message="jailed"
fi 

if [ -z $pid ];
then status="error";
 message="process not running";
fi

#json output
cat << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "id":"$ID",
  "machine":"$MACHINE",
  "version":"$version",
  "chain":"$chain",
  "status":"$status",
  "message":"$message",
  "rpcport":"$rpc_port",
  "folder1":"$foldersize1",
  "moniker":"$moniker",
  "key":"$KEY",
  "wallet":"$wallet",
  "valoper":"$valoper",
  "pubkey":"$pubkey",
  "catchingUp":"$catchingUp",
  "jailed":"$jailed",
  "active":$active,
  "height":$latestBlock,
  "votingPower":$votingPower,
  "tokens":$tokens,
  "threshold":$threshold,
  "delegators":$delegators,
  "balance":$balance
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$bucket&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    status,machine=$MACHINE,id=$ID,moniker=$moniker status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",tokens=\"$tokens\",threshold=\"$threshold\",active=\"$active\",jailed=\"$jailed\" $(date +%s%N) 
    "
fi
