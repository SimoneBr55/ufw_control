#!/bin/bash

if [[ "$1" == "--help" || "$1" == "-h" ]]
then
	echo "Use --dry-run to see what I am doing"
	exit 0
fi

## INSTALL SCRIPT ##
echo "I can install two domains, right now"
echo ""
echo "First Domain?"
echo ""
read dom1
echo "Second Domain?"
echo ""
read dom2

FOLDER=$(pwd)
INSTALL_LOCATION=/usr/local/sbin

sudo ln -s ${FOLDER}/external_connections.sh ${INSTALL_LOCATION}/external_connections
sudo ln -s ${FOLDER}/ufw_disable.sh ${INSTALL_LOCATION}/ufw_disable
sudo ln -s ${FOLDER}/ufe_enable.sh ${INSTALL_LOCATION}/ufw_enable

echo "Installing crontab as:"
echo "@reboot ${INSTALL_LOCATION}/external_connections ${dom1} ${dom2}"
sudo echo "@reboot root ${INSTALL_LOCATION}/external_connections ${dom1} ${dom2}" |& sudo tee /etc/cron.d/ext_conn
sudo chmod 600 /etc/cron.d/ext_conn

#sudo /bin/bash -c 'echo "@reboot root ${INSTALL_LOCATION}/external_connections ${dom1} ${dom2}" >> /etc/crontab'

exit 0
