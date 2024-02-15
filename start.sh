#!/bin/bash

sudo systemctl restart nibi.service
sudo journalctl -u nibi.service -f --no-hostname -o cat
