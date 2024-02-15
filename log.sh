#!/bin/bash
source ~/scripts/nibiru/config/env
sudo journalctl -u $BINARY.service -f --no-hostname -o cat
