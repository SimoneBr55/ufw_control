#!/bin/bash

#-----------USAGE----------#
if [[ "$1" == "-h" || "$1" == "--help" ]]
then
	echo "This script has to be run directly"
	echo "(i.e. /path/2/script OR ./scripts)"
	echo ""
	echo "./external_connections sdomain1 sdomain2"
	exit 1
fi
#--------------------------#
# Check for other instances running
pidof -o %PPID -x $0 >/dev/null && exit 1  # Careful, this script must be run directly (i.e. ./script)

addr1=$1
addr2=$2

# Function definitions
check() {
	# Get old addresses
	old_addresses=$(cat /var/log/ufw_allowed)

	# awk single addresses to get separate variables
	old_mi=$(echo ${old_addresses} | awk -F',' '{print $1}')
	old_mbp=$(echo ${old_addresses} | awk -F',' '{print $2}')

	# Get new addresses
	new_mi=$(dig +short $addr1 @dns1.registrar-servers.com)
	new_mbp=$(dig +short $addr2 @dns1.registrar-servers.com)
	# Compare
	if [[ "${new_mi}" != "${old_mi}" || "${new_mbp}" != "${old_mbp}" ]]
	then
		# Addresses are different
		echo 'Different Addresses'
		echo 1 # signal via exit code
	fi
}

ufw_automate() {
	# Get old addresses
        old_addresses=$(cat /var/log/ufw_allowed)

        # awk single addresses to get separate variables
        old_mi=$(echo ${old_addresses} | awk -F',' '{print $1}')
        old_mbp=$(echo ${old_addresses} | awk -F',' '{print $2}')

	# Get new addresses
        new_mi=$(dig +short $addr1 @dns1.registrar-servers.com)
        new_mbp=$(dig +short $addr2 @dns1.registrar-servers.com)
	
	# Compare
        if [ "${new_mi}" != "${old_mi}" ]
        then
                # Delete everything
                number=$(sudo ufw status numbered | grep ${old_mi} | awk -F] '{print $1}' | grep -o [1-9])
                ufw --force delete $number
                # Allow SSH
                ufw allow from ${new_mi} to any port 22 proto tcp
		unset number
        fi

	# Compare
        if [ "${new_mbp}" != "${old_mbp}" ]
        then
                # Delete everything
                number=$(sudo ufw status numbered | grep ${old_mbp} | awk -F] '{print $1}' | grep -o [1-9])
                ufw --force delete $number
                # Allow SSH
                ufw allow from ${new_mbp} to any port 22 proto tcp
		unset number
        fi
        truncate -s0 /var/log/ufw_allowed
        echo $new_mi","$new_mbp> /var/log/ufw_allowed
#	echo "," >> /var/log/ufw_allowed
#        echo $new_mbp >> /var/log/ufw_allowed
}

# Main
FILE=/var/log/ufw_control

sleep 2m

ufw enable
while [ ! -f "$FILE" ]
do
	if [ $(check) == 1 ]
	then
		ufw_automate
	fi
	sleep $(cat /var/log/ufw_timeout)
done

# If we are here, that means that we want to disable ufw
ufw disable

exit 0
