#!/bin/bash

if [ -f ~/scripts/nibiru/config/env ]
 then
   echo "Config file found."
 else
   read -p "Key name? " KEY
   read -p "Moniker name? " MONIKER
   echo "KEY="$KEY > ~/scripts/pryzm/config/env
   echo "MONIKER="$MONIKER >> ~/scripts/pryzm/config/env
   echo "Config file created."
fi

source ~/scripts/nibiru/config/env

curl -s https://get.nibiru.fi/@v1.0.0! | bash
nibid version
nibid init $MONIKER --chain-id=nibiru-testnet-1 --home $HOME/.nibid
nibid keys add $KEY
curl -s https://networks.testnet.nibiru.fi/$NETWORK/genesis > $HOME/.nibid/config/genesis.json
sed -i 's|seeds =.*|seeds = "'$(curl -s https://networks.testnet.nibiru.fi/$NETWORK/seeds)'"|g' $HOME/.nibid/config/config.toml
sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025unibi"/g' $HOME/.nibid/config/app.toml

config_file="$HOME/.nibid/config/config.toml"

sed -i "s|enable =.*|enable = true|g" "$config_file"
sed -i "s|rpc_servers =.*|rpc_servers = \"$(curl -s https://networks.testnet.nibiru.fi/$NETWORK/rpc_servers)\"|g" "$config_file"
sed -i "s|trust_height =.*|trust_height = \"$(curl -s https://networks.testnet.nibiru.fi/$NETWORK/trust_height)\"|g" "$config_file"
sed -i "s|trust_hash =.*|trust_hash = \"$(curl -s https://networks.testnet.nibiru.fi/$NETWORK/trust_hash)\"|g" "$config_file"

#set prunning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.nibid/config/app.toml

#change ports
sed -i.bak -e "s%:26658%:28658%; s%:26657%:28657%; s%:6060%:6260%; s%:26656%:28656%; s%:26660%:28660%" $HOME/.nibid/config/config.toml && sed -i.bak -e "s%:9090%:9290%; s%:9091%:9291%; s%:1317%:1517%; s%:8545%:8745%; s%:8546%:8746%; s%:6065%:6265%" $HOME/.nibid/config/app.toml && sed -i.bak -e "s%:26657%:28657%" $HOME/.nibid/config/client.toml 

#create service
sudo tee /etc/systemd/system/nibid.service > /dev/null << EOF
[Unit]
Description=nibid node service
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/nibid start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=/root/.nibid"
Environment="DAEMON_NAME=nibid"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nibid.service

echo "Installation done, service is not started. Please run it with start.sh."
