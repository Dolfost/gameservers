#!/bin/sh

serversDirectory="servers"
server="dserver"

serverJar="minecraft_1.21.3"
jarsDirectory="serverjars"
jarOptions="nogui"
javaOptions=""
startHeap="512"
maxHeap="1024"

programName="$0"

if [ -e ~/.mcserver.sh ]; then
	source ~/.mcserver.sh
fi

if [ -e mcserver.sh ]; then
	source ./mcserver.sh
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
		-e|--server-jar)
			serverJar="$2"
			shift; shift
			;;
		-s|--server)
			server="$2"
			shift; shift
			;;
		-j|--jars-directory)
			jarsDirestory="$2"
			shift; shift
			;;
		--java-options)
			javaOptions="$2"
			shift; shift
			;;
		--jar-options)
			jarOptions="$2"
			shift; shift
			;;
		--start-heap)
			startHeap="$2"
			shift; shift
			;;
		--max-heap)
			maxHeap="$2"
			shift; shift
			;;
		-h|--help)
			cat << EOF
USAGE: $0 [OPTIONS]
Starts minecraft server

Avaliable options:
-d --servers-directory [PATH]  Directory where all servers located.
   default: $serversDirectory
-s --server [SERVER NAME]      Server to start.
   default: $server
-e --server-jar [FILENAME]     Server jar file. Must be in --jars-directory.
   default: $serverJar
-j --jars-directory [PATH]     Path to look for serve executables.
   default: $jarsDirectory
--java-options [OPTIONS]       Additional java options.
   default: $javaOptions
--jar-options [OPTIONS]        Additional server jar options.
   default: $jarOptions
--start-heap [UINT]            Starting heap size in mb.
   default: $startHeap
--max-heap [UINT]              Maximum heap size in mb.
   default: $maxHeap
-h --help                      Show this message.

Running sever is in <servers-directory>/<server>.
Sever is at <jars-directory>/<server-jar>.

You can add option defaults to ~/.mcserver.sh or 
mcserver.sh in current folder with defaults. They will be sourced with 
mentioned order.
For example, to redefine default --start-heap 
value to 2048, add
startHeap=2048
to the mcserver.sh or ~/.mcserver.sh.
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

check_for_file "$serversDirectory" "no servers directory"
check_for_file "$serversDirectory/$server" "no server folder"

check_for_file "$jarsDirectory" "no server java archive directory"

check_uint "$startHeap" "--start-heap"
check_uint "$maxHeap" "--max-heap"
if [ $startHeap -gt $maxHeap ]; then
	fail "starting RAM size is larger that allowed size"
fi

jar="$(pwd)/$jarsDirectory/$(basename "$serverJar" .jar).jar"
check_for_file "$jar" "no server java archive"

cd "$serversDirectory/$server"
java -Xms"$startHeap"M -Xmx"$maxHeap"M $javaOptions -jar $jar $jarOptions
