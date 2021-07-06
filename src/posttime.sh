#!/usr/bin/env bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine=Other
esac

case "${machine}" in
    Mac*)    TOUCH=gtouch;;
    *)          TOUCH=touch
esac

echo "touch command is ${TOUCH}"

regex="s/docvars\[date\]='\(.*\)'/\1/"
for fn in $(IFS=$'\n' ls -1 content/*.post.sh); do
    ts=$(grep '\[date\]' "${fn}" | sed -e "${regex}")
    if [ "${ts}" != "" ]; then
        echo "Setting timestamp '${ts}' on ${fn}"
        $TOUCH -d "${ts}" "${fn}"
    fi
done
