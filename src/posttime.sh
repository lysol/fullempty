#!/bin/bash
regex="s/.\+='\([^']\+\)'/\1/"
for fn in $(IFS=$'\n' ls -1 content/*.sh); do
    ts=$(grep '\[date\]' "${fn}" | sed -e "${regex}")
    if [ "${ts}" != "" ]; then
        echo "Setting timestamp '${ts}' on ${fn}"
        touch -d "${ts}" "${fn}"
    fi
done
