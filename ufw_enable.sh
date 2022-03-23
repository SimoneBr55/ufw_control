#!/bin/bash

rm /var/log/ufw_control
bash external_connections.sh &; disown

