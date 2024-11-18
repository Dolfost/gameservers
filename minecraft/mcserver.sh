#!/bin/sh

serversDirectory="servers"
server="dserver"

root=$(pwd)
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

if [ -e "$root/mcserver.sh" ]; then
	source "$root/mcserver.sh"
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
		-r|--root)
			root="$2"
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
 -d --servers-directory [PATH] def: $serversDirectory
     Servers collection directory name in <root>/. 
 -s --server [FOLDER NAME] def: $server
     Server directory to start. 
     Should be in <root>/<servers-directory>/.
 -e --server-jar [FILENAME] def: $serverJar
     Server jar file. Must be in <root>/<jars-directory>.
 -j --jars-directory [PATH] def: $jarsDirectory
     Path to look for server executables.
     Should be in <root>/.
 -r --root [PATH] def: $jarsDirectory
     Path to server root folder. This folderscontains
     contains servers jar folders and servers itsef.
 --java-options [OPTIONS] def: $javaOptions
     Additional java options.
 --jar-options [OPTIONS] def: $jarOptions
     Additional server jar options.
 --start-heap [UINT] def: $startHeap
     Starting heap size in mb.
 --max-heap [UINT] def: $maxHeap
     Maximum heap size in mb.
 -h --help                     
     Show this message.

Running sever is in <servers-directory>/<server>.
Sever is at <jars-directory>/<server-jar>.

You can add option defaults to ~/.mcserver.sh or 
<root>/mcserver.sh in folder with defaults. 
They will be sourced with mentioned order.
For example, to redefine default --start-heap 
value to 2048, add
	startHeap=2048
to the <root>/mcserver.sh or ~/.mcserver.sh.
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

check_for_file "$root/$jarsDirectory" "no server java archive directory"

check_uint "$startHeap" "--start-heap"
check_uint "$maxHeap" "--max-heap"
if [ $startHeap -gt $maxHeap ]; then
	fail "starting RAM size is larger that allowed size"
fi

jar="$root/$jarsDirectory/$(basename "$serverJar" .jar).jar"
check_for_file "$jar" "no server java archive \"$serverJar[.jar]\""

cd "$root/$serversDirectory/$server"
java -Xms"$startHeap"M -Xmx"$maxHeap"M $javaOptions -jar $jar $jarOptions
