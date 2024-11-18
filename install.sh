#!/bin/sh 

prg=(gsforward.sh minecraft/mcserver.sh)

if [[ -d  "~/.local/bin" ]]; then
	echo "Error: ~/.local/bin does not exist"
fi

for prg in "${programs[@]}"; do
	ln -s "${pwd}/$prg" "~/.local/bin/${basename ${prg}}"
done
