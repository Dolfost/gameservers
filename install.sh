#!/bin/sh

programs=(
	"gsforward.sh" 
	"minecraft/mcserver.sh" 
	"dst/dstserver.sh"
	"bombsquad/bsserver.sh"
	"/mount_and_blade_warband/mbwbserver.sh"
)

if [[ ! -d "$HOME/.local/bin" ]]; then
	echo "Error: $HOME/.local/bin does not exist"
	exit 1
fi

for prg in "${programs[@]}"; do
	from="$(pwd)/$prg"
	to="$HOME/.local/bin/$(basename $prg .sh)"

	if [ -e "$to" ]; then 
		echo "skipping $from -> $to"
		continue
	fi

	echo "linking $from to $to"
	ln -s "$from" "$to"
	chmod +x "$to"
done
