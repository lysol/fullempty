#!/bin/bash
regex="s/.\+='\([^']\+\)'/\1/"
for fn in $(IFS=$'\n' ls -1 content/*.post.sh); do
    ts=$(grep '\[date\]' "${fn}" | sed -e "${regex}")
    touch -d "${ts}" "${fn}"
done
