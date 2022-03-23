#!/bin/bash

bash external_connections.sh &; disown
sleep 1
touch /var/log/ufw_control
sleep 1
exit 0
