#!/bin/bash

# SERVER opotions
# final server location is
# $root/$conf_dir/$cluster
root="$HOME/dstservers"
conf_dir="servers" 
cluster="default"
shard="Master"
additional=("-console")
# additional=("-offline -disabledatacollection -console")

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
		-o|--server-option)
			additional+=(" $2")
			shift; shift
			;;
		-h|--help)
			echo help
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
install_dir="$HOME/steamapps/DST"
dontstarve_dir="$root/$conf_dir"

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
run_shared+=(-conf_dir "$conf_dir")
run_shared+=(-monitor_parent_process $$)
run_shared+=("$additional")

"${run_shared[@]}" -shard $shard | sed "s/^/$shard:  /"
