#!/bin/sh

programs=("gsforward.sh" "minecraft/mcserver.sh")

if [[ ! -d "$HOME/.local/bin" ]]; then
	echo "Error: $HOME/.local/bin does not exist"
	exit 1
fi

for prg in "${programs[@]}"; do
	echo "linking $(pwd)/$prg to $HOME/.local/bin/$(basename $prg)"
	ln -s "$(pwd)/$prg" "$HOME/.local/bin/$(basename $prg)"
done
