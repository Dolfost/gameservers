#!/bin/sh

serversDirectory="servers"
server="dserver"

root=$(pwd)
executableDirectory="minecraft_1.21.3"
executablesDirectory=""
config="config.txt"

programName="$0"

if [ -e ~/.mbwbserver.sh ]; then
	source ~/.mbwbserver.sh
fi

if [ -e "$root/mbwbserver.sh" ]; then
	source "$root/mbwbserver.sh"
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

while [[ $# -gt 0 ]]; do
	case $1 in
		-d|--servers-directory)
			serversDirectory="$2"
			shift; shift
			;;
		-e|--executable-directory)
			executableDirectory="$2"
			shift; shift
			;;
		-s|--server)
			server="$2"
			shift; shift
			;;
		-c|--config)
			config="$2"
			shift; shift
			;;
		-E|--executables-directory)
			jarsDirestory="$2"
			shift; shift
			;;
		-r|--root)
			root="$2"
			shift; shift
			;;
		-h|--help)
			cat << EOF
USAGE: $0 [OPTIONS]
Starts minecraft server.

Avaliable options:
 -d --servers-directory [PATH] def: $serversDirectory
     Servers collection directory name in <root>/. 
 -s --server [FOLDER NAME] def: $server
     Server directory to start. 
     Should be in <root>/<servers-directory>/.
 -e --executable-directory [FILENAME] def: $executableDirectory
     Server jar file. Must be in <root>/<jars-directory>.
 -E --executables-directory [PATH] def: $executablesDirectory
     Path to look for server executables folders.
     Should be in <root>/.
 -c --config [PATH] def: $config
     Path to the config.
     Should be in <root>/<servers-directory>/<server>.
 -r --root [PATH] def: $root
     Path to server root folder. This folderscontains
     contains servers jar folders and servers itsef.
 -h --help                     
     Show this message.

Running sever is in <servers-directory>/<server>.
Sever is at <executables-directory>/<executable>/mb_warband_dedicated.exe.

You can add option defaults to ~/.mbwbserver.sh or 
<root>/mbwbserver.sh in with options defaults. 
They will be sourced with mentioned order.
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
check_for_file "$root/$serversDirectory/$server/$config" "no config"

check_for_file "$root/$executablesDirectory" "no server executables directory"

exe="$root/$executablesDirectory/$(basename "$executableDirectory")/mb_warband_dedicated.exe"
check_for_file "$exe" "no server executable \"$executableDirectory\""

cd "$root/$serversDirectory/$server"
wineconsole exe "$root/$executablesDirectory/$executableDirectory/mb_warband_dedicated.exe" -r "$root/$serversDirectory/$server/$config"
