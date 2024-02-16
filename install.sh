#!/bin/bash

FOLDER=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')

if [ -f ~/scripts/$FOLDER/config/env ]
 then
   echo "Config file found."
 else
   read -p "Key name? "     KEY;       echo "KEY="$KEY            > ~/scripts/$FOLDER/config/env
   read -p "Moniker name? " MONIKER;   echo "MONIKER="$MONIKER   >> ~/scripts/$FOLDER/config/env
   read -p "Binary? "       BINARY;    echo "BINARY="$BINARY     >> ~/scripts/$FOLDER/config/env
   read -p "Network? "      NETWORK;   echo "NETWORK="$NETWORK   >> ~/scripts/$FOLDER/config/env
   read -p "Password? "     PWD;       echo "PWD="$PWD           >> ~/scripts/$FOLDER/config/env
   read -p "Port set? "     PORT;      echo "PORT="$PORT         >> ~/scripts/$FOLDER/config/env
   read -p "URL? "          URL;       echo "URL="$URL           >> ~/scripts/$FOLDER/config/env
   read -p "Min gas? "      GAS;       echo "GAS="$GAS           >> ~/scripts/$FOLDER/config/env
   echo "Config file created."
fi

source ~/scripts/$FOLDER/config/env

#install binary
#put instalation script here
$BINARY version

$BINARY init $MONIKER --chain-id=$NETWORK --home $HOME/.$BINARY
$BINARY keys add $KEY

# genesis
curl -s $URL/$NETWORK/genesis > $HOME/.$BINARY/config/genesis.json

#seeds
sed -i 's|seeds =.*|seeds = "'$(curl -s $URL/$NETWORK/seeds)'"|g' $HOME/.$BINARY/config/config.toml

#min gas
sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "$GAS"/g' $HOME/.$BINARY/config/app.toml

#prunning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.$BINARY/config/app.toml

#change ports
case $PORT in
 2) sed -i.bak -e "s%:26658%:28658%; s%:26657%:28657%; s%:6060%:6260%; s%:26656%:28656%; s%:26660%:28660%" $HOME/.$BINARY/config/config.tomlsed -i.bak -e "s%:9090%:9290%; s%:9091%:9291%; s%:1317%:1517%; s%:8545%:8745%; s%:8546%:8746%; s%:6065%:6265%" $HOME/.$BINARY/config/app.toml && sed -i.bak -e "s%:26657%:28657%" $HOME/.$BINARY/config/client.toml 
esac

#create service
sudo tee /etc/systemd/system/$BINARY.service > /dev/null << EOF
[Unit]
Description=$BINARY node service
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/$BINARY start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=/root/.$BINARY"
Environment="DAEMON_NAME=$BINARY"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $BINARY.service

echo "Installation done, service is not started. Please run it with start.sh."
