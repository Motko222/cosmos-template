#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

read -p "Set? " $set

case $set in
 1) sed -i.bak -e "s%:26658%:27658%; s%:26657%:27657%; s%:6060%:6160%; s%:26656%:27656%; s%:26660%:27660%" $DATA/config/config.toml 
    sed -i.bak -e "s%:9090%:9190%; s%:9091%:9191%; s%:1317%:1417%; s%:8545%:8645%; s%:8546%:8646%; s%:6065%:6165%" $DATA/config/app.toml 
    sed -i.bak -e "s%:26657%:27657%" $DATA/config/client.toml 
 ;;
 2) sed -i.bak -e "s%:26658%:28658%; s%:26657%:28657%; s%:6060%:6260%; s%:26656%:28656%; s%:26660%:28660%" $DATA/config/config.toml
    sed -i.bak -e "s%:9090%:9290%; s%:9091%:9291%; s%:1317%:1517%; s%:8545%:8745%; s%:8546%:8746%; s%:6065%:6265%" $DATA/config/app.toml
    sed -i.bak -e "s%:26657%:28657%" $DATA/config/client.toml 
 ;;
 3) sed -i.bak -e "s%:26658%:29658%; s%:26657%:29657%; s%:6060%:6360%; s%:26656%:29656%; s%:26660%:29660%" $DATA/config/config.toml
    sed -i.bak -e "s%:9090%:9390%; s%:9091%:9391%; s%:1317%:1617%; s%:8545%:8845%; s%:8546%:8846%; s%:6065%:6365%" $DATA/config/app.toml 
    sed -i.bak -e "s%:26657%:29657%" $DATA/config/client.toml 
 ;;
 4) sed -i.bak -e "s%:26658%:30658%; s%:26657%:30657%; s%:6060%:6460%; s%:26656%:30656%; s%:26660%:30660%" $DATA/config/config.toml
    sed -i.bak -e "s%:9090%:9490%; s%:9091%:9491%; s%:1317%:1717%; s%:8545%:8945%; s%:8546%:8946%; s%:6065%:6465%" $DATA/config/app.toml
    sed -i.bak -e "s%:26657%:30657%" $DATA/config/client.toml 
 ;;
 5) sed -i.bak -e "s%:26658%:31658%; s%:26657%:31657%; s%:6060%:6560%; s%:26656%:31656%; s%:26660%:31660%" $DATA/config/config.toml
    sed -i.bak -e "s%:9090%:9590%; s%:9091%:9591%; s%:1317%:1817%; s%:8545%:9045%; s%:8546%:9046%; s%:6065%:6565%" $DATA/config/app.toml
    sed -i.bak -e "s%:26657%:31657%" $DATA/config/client.toml 
 ;;
 *) ;; #no change
