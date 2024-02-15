#!/bin/bash

sudo journalctl -u $BINARY.service -f --no-hostname -o cat
