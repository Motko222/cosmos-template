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

#create service
sudo tee /etc/systemd/system/nibi.service > /dev/null << EOF
[Unit]
Description=nibi node service
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/nibid start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=/root/.nibi"
Environment="DAEMON_NAME=nibi"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nibi.service

echo "Installation done, service is not started. Please run it with start.sh."
