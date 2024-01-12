#!/bin/bash
# Set foot's title to the command supplied after -e.
# Note: Option -e is mandatory for this wrapper script.
# Скрипт для запуска cli программ с именованным заголовком напрямую из терминала

unset title
arg_i=0
for arg; do
	arg_i=$((arg_i+1))
	if [[ "$arg" != "-e" ]]; then
		continue
	else
		arg_i=$((arg_i+1))
		title="${*:$arg_i}"
		break
	fi
done

if ! [[ -v title ]]; then
	printf 'error: option -e is mandatory\n'
	exit 1
fi

set -e 

exec foot --title="$title" "$@" 2> /dev/null & 
