#!/bin/bash

root="$(pwd)"
clustersDir="clusters" 
cluster="dcluster"
shard="Master"
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

function check_for_file() {
    if [ ! -e "$1" ]; then
        fail "Missing file: $1"
    fi
}

check_for_file "$dontstarve_dir/$cluster/cluster.ini"
check_for_file "$dontstarve_dir/$cluster/cluster_token.txt"
check_for_file "$dontstarve_dir/$cluster/Master/server.ini"
check_for_file "$dontstarve_dir/$cluster/Caves/server.ini"

check_for_file "$install_dir/bin64"
cd "$install_dir/bin64" || fail

run_shared=(./dontstarve_dedicated_server_nullrenderer_x64)
run_shared+=(-persistent_storage_root "$root")
run_shared+=(-cluster "$cluster")
run_shared+=(-conf_dir "$clustersDir")
run_shared+=(-monitor_parent_process $$)
run_shared+=("$additional")

"${run_shared[@]}" -shard $shard | sed "s/^/$shard:  /"
