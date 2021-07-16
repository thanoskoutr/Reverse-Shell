#!/bin/bash

###############################################################################
########################### Basic helper functions ###########################
###############################################################################

show_usage() {
	echo "usage: $(basename $0) [-h] PORT" 
	echo ""
	echo "Simple Listener script that waits for remote reverse shell connections."
}

show_help() {
	show_usage
	echo ""
	echo "positional arguments:"
	echo "  PORT        Specify source port to use"
	echo ""
	echo "optional arguments:"
	echo "  -h, --help	show this help message and exit"
}

is_root() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "$1: missing. Please install \"$1\" first and then run script again."	
		exit 1
	fi
}

###############################################################################
############# Main Function: Parses arguments, executes listener ##############
###############################################################################

# Number of positional arguments: PORT
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

# Check if argument is supplied
if [[ -z $PORT ]]; then
        echo "$(basename $0): error: the following arguments are required: PORT"
	exit 1
fi

# Check if selecetd PORT requires sudo priviliges
if [[ $PORT < 1024 ]]; then
	echo "Choose a PORT >= 1024 for execution with non-root priviliges"
	is_root
fi

# Check if nc is installed
command_exists nc

# Listen on PORT
nc -lnvp $PORT
