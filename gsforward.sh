#!/bin/sh

portFrom="25565"
portTo="31415"
subdomain="yoursub"
localPort="<localport>"

programName="$0"

if [ -e ~/.gsforward.sh ]; then
	source ~/.gsforward.sh
fi

function fail() {
	echo "$programName: Error:" "$@" >&2
	exit 1
}

function check_port() {
	if [[ ! $1 =~ ^[0-9]+$ ]] || [[ $1 -gt 65535 ]]; then
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
		-h|--help)
			cat << EOF
USAGE: $0 [OPTIONS]
Forward TCP traffic through serveo.net.

Avaliable options:
 -p --port-from [PORT] def: $portFrom
     Local port to forward.
 -t --port-to [PORT] def: $portTo
     Port to forward to <subdomain>.
 -d --subdomain [DOMEN] def: $subdomain
     Subdomain of serveo.net to use.
 -l --local-port [PORT] def: $localPort
     Local port to show in final message.
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

cat << EOF
If succesfull and sever is running on port $portFrom, 
You can try to recieve it's traffic on other machine via:
   ssh -L $localPort:$subdomain:$portTo serveo.net
where $localPort is untaken local port. Have a nice game!

EOF

ssh -R $subdomain:$portTo:localhost:$portFrom serveo.net
