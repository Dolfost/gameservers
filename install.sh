#!/bin/sh 

prg=(gsforward.sh minecraft/mcserver.sh)

if [[ -d  "~/.local/bin" ]]; then
	echo "Error: ~/.local/bin does not exist"
fi

for prg in "${programs[@]}"; do
	echo "linking ${pwd}/$prg to ~/.local/bin/${basename ${prg}}"
	ln -s "${pwd}/$prg" "~/.local/bin/${basename ${prg}}"
done
