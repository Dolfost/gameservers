#!/bin/bash

root="$(pwd)"
clustersDir="clusters" 
cluster="dcluster"
shard="Master"
update_client="no"
update_mods="no"
additional=("-console")
dstDir="$HOME/steamapps/DST"
# additional=("-offline -disabledatacollection -console")
 
if [ -e ~/.dstserver.sh ]; then
	source ~/.dstserver.sh
fi

if [ -e "$root/dstserver.sh" ]; then
	source "$root/dstserver.sh"
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		-c|--cluster)
			cluster="$2"
			shift; shift
			;;
		-s|--shard)
			shard="$2"
			shift; shift
			;;
		-r|--root)
			root="$2"
			shift; shift
			;;
		-d|--clusters-dir)
			clustersDir="$2"
			shift; shift
			;;
		-i|--dst-dir)
			dstDir="$2"
			shift; shift
			;;
		-u|--update-client)
			update_client="yes"
			shift
			;;
		-U|--update-mods)
			update_mods="yes"
			shift
			;;
		-o|--server-option)
			additional+=(" $2")
			shift; shift
			;;
		-h|--help)
			cat << EOF
USAGE: $0 [OPTIONS]
Start Don't Starve Together server.

Available options:
-c --cluster [CLUSTER PATH] def: $cluster
    Cluster name to run.
-s --shard [SHARD PATH] def: $shard
    Shard to start (Caves, Master etc.).
-r --root [PATH] def: $root
    Path to the clusters directory.
-o --server-option [OPTIONS] def: $additional
    Additional nullrenderer options.
-d --clusters-dir [PATH] def: $clustersDir
    Clusters home directory.
-i --dst-dir [PATH] def: $dstDir
    Don't Starve Together installation directory.
-u --update-client
    Update dst client.
-U --update-mods
    Update selected shard mods
-h --help
    Show this message.

Clusters are in <root>/<config-directory>/.
Active cluster is <root>/<config-directory>/<cluster>.
Don't Starve server in <dst-dir>.

You can override default option values 
by putting overrides in ~/.dstserver.sh and <root>/dstsever.sh.
For example, to chande default --cluster-dir value, put 
   clusterDir=<newValue>
in ~/.dstsever.sh or <root>/dstsever.sh.
EOF
			exit 0
			;;
		-*|--*)
			echo "$0: Unknown option: $1"
			echo "try $0 for usage"
			exit 1
			;;
		*)
			echo "$0: Excess arguments: $1"
			echo "try $0 for usage"
			exit 1
			;;
	esac
done

# INSTALL setup
dontstarve_dir="$root/$clustersDir"

function fail() {
    echo Error: "$@" >&2
    exit 1
}

function status() {
	echo " -- $1"
}

function check_for_file() {
    if [ ! -e "$1" ]; then
        fail "Missing file: $1"
    fi
}

check_for_file "$dontstarve_dir"
if [[ "$update_client" == "no" ]]; then
	check_for_file "$dontstarve_dir/$cluster/cluster.ini"
	check_for_file "$dontstarve_dir/$cluster/cluster_token.txt"
	check_for_file "$dontstarve_dir/$cluster/Master/server.ini"
	check_for_file "$dontstarve_dir/$cluster/Caves/server.ini"
fi

check_for_file "$dstDir/bin64"
cd "$dstDir/bin64" || fail

run_shared=(./dontstarve_dedicated_server_nullrenderer_x64)
run_shared+=(-persistent_storage_root "$root")
run_shared+=(-cluster "$cluster")
run_shared+=(-conf_dir "$clustersDir")
run_shared+=(-monitor_parent_process $$)
run_shared+=("$additional")
run_shared+=("-shard $shard")

# update
if [[ "$update_client" == "yes" ]]; then 
	status "Updating dst client"
	steamcmd +@ShutdownOnFailedCommand 1 \
		+@NoPromptForPassword 1 +login anonymous \
		+force_install_dir "$dstDir" \
		+app_update 343050 validate +quit
	if [[ "$?" -eq "0" ]]; then 
		status "Updating dst client finished!"
	else
		status "Updating dst client failed!"
	fi
	exit $?
fi

if [[ "$update_mods" == "yes" ]]; then
	status "Updating '$cluster' cluster mods on '$shard' shard"
	"${run_shared[@]}" - only_update_server_mods | sed "s/^/$shard:  /"
	if [[ "$?" -eq "0" ]]; then 
		status "Updating mods finished!"
	else
		status "Updating mods failed!"
	fi
	exit $?
fi

"${run_shared[@]}" | sed "s/^/$shard:  /"
