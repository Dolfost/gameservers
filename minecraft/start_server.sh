#!/bin/sh

serversDirectory="servers"
server="dserver"

serverVersion="1.21.3"
jarsDirectory="serverjars"
jarOptions="nogui"
javaOptions=""
startHeap="512"
maxHeap="1024"

programName="$0"

function fail() {
    echo "$programName: Error:" "$@" >&2
    exit 1
}

function check_for_file() {
    if [ ! -e "$1" ]; then
        fail "Missing file: $1"
    fi
}

function check_uint() {
	if [[ ! $1 =~ ^-?[0-9]+$ ]]; then
		fail "$2: not an positive integer"
	fi
}

while [[ $# -gt 0 ]]; do
        case $1 in
                -d|--servers-directory)
                        serversDirectory="$2"
                        shift; shift
                        ;;
                -v|--server-version)
                        serverVersion="$2"
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
 -v --server-version [VERSION]  Server version to use.
    default: $serverVersion
 -j --jars-directory [PATH]     Path to look for serve executables.
    default: $jarsDirectory
 --java-options [OPTIONS]       Additional java options.
    default: $javaOptions
 --jar-options [OPTIONS]        Additional server jar options.
    default: $jarOptions
 --start-heap [UINT]            Starting heap size. (MB)
    default: $startHeap
 --max-heap [UINT]              Maximum heap size. (MB)
    default: $maxHeap
 -h --help                      Show this message.

Running sever is in <servers-directory>/<server>

Sever of version <server-version> is at <jars-directory>
It is found according to this regular expression: *<server-version>.jar
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

check_for_file "$serversDirectory"
check_for_file "$serversDirectory/$server"

check_for_file "$jarsDirectory"

check_uint "$startHeap" "--start-heap"
check_uint "$maxHeap" "--max-heap"
if [ $startHeap -gt $maxHeap ]; then
	fail "starting RAM size is larger that allowed size"
fi

jar="$(pwd)/$(find $jarsDirectory -name "*$serverVersion.jar" -print -quit)"
check_for_file "$jar"

cd "$serversDirectory/$server"
java -Xms"$startHeap"M -Xmx"$maxHeap"M $javaOptions -jar $jar $jarOptions
