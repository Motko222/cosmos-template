#!/bin/bash

sudo systemctl restart $BINARY.service
sudo journalctl -u $BINARY.service -f --no-hostname -o cat
