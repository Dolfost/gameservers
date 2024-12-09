#!/bin/sh

portFrom="25565"
portTo="31415"
subdomain="yoursub"
localPort="<localport>"
noSubdomain="no"
waitConnection="no"

programName="$0"

if [ -e ~/.gsforward.sh ]; then
	source ~/.gsforward.sh
fi

function fail() {
	echo "$programName: Error:" "$@" >&2
	exit 1
}

function check_port() {
	if [[ ! $1 =~ ^[0-9]+$ ]] || [[ $1 -gt 65535 ]] || [[ $1 -lt 1 ]]; then
		fail "$1: $2: not a valid port"
	fi
	if [[ $1 -eq "80" ]]; then 
		fail "80: $2: this port cant be used; http port"
	fi
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-f|--port-from)
			portFrom="$2"
			shift; shift
			;;
		-t|--port-to)
			portTo="$2"
			shift; shift
			;;
		-d|--subdomain)
			subdomain="$2"
			shift; shift
			;;
		-l|--local-port)
			subdomain="$2"
			shift; shift
			;;
		-n|--no-subdomain)
			noSubdomain="$2"
			shift; shift
			;;
		-w|--wait-connection)
			waitConnection="yes"
			shift; shift
			;;
		-h|--help)
			cat << EOF
USAGE: $0 [OPTIONS]
Forward TCP traffic through serveo.net.

Avaliable options:
 -f --port-from [PORT] def: $portFrom
     Local port to forward.
 -t --port-to [PORT] def: $portTo
     Port to forward to <subdomain>.
 -d --subdomain [DOMEN] def: $subdomain
     Subdomain of serveo.net to use.
 -l --local-port [PORT] def: $localPort
     Local port to show in final message.
 -n --no-subdomain yes|no def: $noSubdomain
     Don't use subdomain $subdomain, connect
		 directly to serveo.net:$portTo.
 -w --wait-connection
     Instead of connectiong, try to connect 
		 every 2 seconds and beep when serveo.net is avaliable.
 -h --help 
     Show this message.

To recieve TCP traffic on other machine as localhost:<localport>, use:
$ ssh -L <localport>:<subdomain>:<port-to> serveo.net

You can add and ~/.forward.sh to your home 
with option defaults.
They will be souced in mentioned order.
For example, to redefine default 
--port-to value to 27182, add
   portTo=27182
to the ~/.gsforward.sh.
EOF
			exit 0
			;;
		-*|--*)
			echo "$0: Unknown option: $1"
			echo "try '$0 -h' for usage"
			exit 1
			;;
		*)
			echo "$0: Excess arguments: $1"
			echo "try '$0 -h' for usage"
			exit 1
			;;
	esac
done

check_port "$portFrom" "--port-from"
check_port "$portTo" "--port-to"


if [ $noSubdomain = "no" ]; then
	address="$subdomain:$portTo:localhost:$portFrom" 
else
	address="$portTo:localhost:$portFrom" 
fi

cat << EOF
You can recieve traffic from $portFrom on other machine via:
EOF
if [ $noSubdomain = "no" ]; then
	cat << EOF
   ssh -L $localPort:$subdomain:$portTo serveo.net
where $localPort is untaken port on other machine.
EOF
else
	cat << EOF
   serveo.net:$portTo 
EOF
fi
echo "Have a nice game!"

command="ssh -R $address serveo.net"

if [ "$waitConnection" = "yes" ]; then
	echo "Waiting for valid connection..."
	until timeout 3 $command; do
		echo "Retrying connection..."
		sleep 1
	done
	echo "Connection established!"	
	beep -f 1000 -l 300 -D50 -n -f 1500 -l 200 -D 50 -n -f 1000 -l 300
else
	$command
fi
