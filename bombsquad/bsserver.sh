#!/bin/sh

serversDirectory="servers"
server="dserver"

root=$(pwd)
serverClient="BombSquad_Server_Linux_x86_64_1.7.37"
clientsDirectory="clients"
clientOptions="--interactive"

programName="$0"

if [ -e ~/.bsserver.sh ]; then
	source ~/.bsserver.sh
fi

if [ -e "$root/bsserver.sh" ]; then
	source "$root/bsserver.sh"
fi

function fail() {
	echo "$programName: Error:" "$@" >&2
	exit 1
}

function check_for_file() {
	if [ ! -e "$1" ]; then
		fail "Missing file: $1: $2"
	fi
}

function check_uint() {
	if [[ ! $1 =~ ^[0-9]+$ ]]; then
		fail "$2: not an positive integer"
	fi
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-d|--servers-directory)
			serversDirectory="$2"
			shift; shift
			;;
		-v|--server-client)
			serverClient="$2"
			shift; shift
			;;
		-s|--server)
			server="$2"
			shift; shift
			;;
		-c|--clients-directory)
			jarsDirestory="$2"
			shift; shift
			;;
		-r|--root)
			root="$2"
			shift; shift
			;;
		-o|--client-options)
			clientOptions="$2"
			shift; shift
			;;
		-h|--help)
			cat << EOF
USAGE: $0 [OPTIONS]
Start a BombSquad server.

Avaliable options:
 -d --servers-directory [PATH] def: $serversDirectory
     Servers collection directory name in <root>/. 
 -s --server [FOLDER NAME] def: $server
     Server to start. 
     Should be in <root>/<servers-directory>/.
 -v --server-client [FILENAME] def: $serverClient
     Server client folder. Must be in <root>/<clients-directory>.
		 Should contain bombsquad_server script.
 -c --clients-directory [PATH] def: $clientsDirectory
     Path to look for server clients.
     Should be in <root>/.
 -r --root [PATH] def: $root
     Path to server root folder. This folderscontains
     contains clients and servers folders.
 --client-options [OPTIONS] def: $clientOptions
     Additional client options.
 -h --help                     
     Show this message.

Running sever is in <servers-directory>/<server>.
Sever is at <clients-directory>/<server-client>.

You can add option defaults to ~/.bsserver.sh or 
<root>/bsserver.sh in with options defaults. 
They will be sourced with mentioned order.
For example, to redefine default --clients-directory 
value to <domedir>, add
	clientsDirectory=<somedir>
to the <root>/bsserver.sh or ~/.bsserver.sh.
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

check_for_file "$root" "no server root"
check_for_file "$root/$serversDirectory" "no servers directory"
check_for_file "$root/$serversDirectory/$server" "no server folder"

check_for_file "$root/$clientsDirectory" "no server java archive directory"

client="$root/$clientsDirectory/$serverClient/bombsquad_server"
check_for_file "$client" "no server client executable \"$client[.jar]\""

${client} "--config $root/$serversDirectory/$server/config.toml" \
	"--root $root/$serversDirectory/$server/ba_root" "$clientOptions" 
