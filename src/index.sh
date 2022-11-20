#!/usr/bin/env bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine=Other
esac

case "${machine}" in
    Mac*)    TOUCH=gtouch
                DATE=gdate
                ;;
    *)          TOUCH=touch
                DATE=date
                ;;
esac

echo "Build running on ${machine}"
echo "touch command is ${TOUCH}"
echo "date command is ${DATE}"

# $templatevars are used as the base variables for every template,
# sourced from default.json
declare -A templatevars
# set default template vars
. content/default.sh
POST_INDEX="${BUILD_DIR}${POST_INDEX}"
# make the build directory if it's not there yet :)
mkdir -p $(dirname "${POST_INDEX}")

for n in $(ls -1 src/*.func.sh); do
    echo "including $n"
    . "${n}"
done


function work_on() {
    n="$1"
    echo -n "${n} "
    # initialize document associative array prefilled with templatevars' values
    declare -A docvars=()
    for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done

    # source file to set variables
    . "${n}"

    # "template" is a special value that is the location of the base template to include
    if [ "${docvars[template]}" == "" ]; then
        echo -n "${n}: Using blank template"
        output="<% content %>"
    else
        output=$(< "${docvars['template']}")
    fi

    # if "date" is present, make a nice human-readable date.
    if [ ${docvars[date]+_} ]; then
        docvars[nicedate]="$(${DATE} -d "${docvars[date]}" '+%Y-%m-%d')"
    fi

    # "content" is more special, it's a filename that we cat the contents of to get the
    # actual value. might make it this more explicit rather than implicit later
    contentPath="${docvars[content]}"

    if [ -z "${contentPath}" ]; then
        echo "${n}: No content property, skipping"
        continue
    fi

    # considering doing this check for any value honestly
    if [[ -x "${contentPath}" ]]; then
        # file is executable, execute it to get our content
        docvars[content]="$($contentPath)"
    else
        # otherwise just redirect contents
        docvars[content]="$(< "$contentPath")"
    fi

    for i in "${!docvars[@]}"
    do
        # replace tag values in both all the other docvars but our content
        docvars["${i}"]=$(replace_tags docvars <<<"${docvars[${i}]}")
        output=$(replace_tags docvars <<<"${output}")
    done

    outfn="${BUILD_DIR}${docvars[filename]}"
    # create any intermediate directories
    mkdir -p $(dirname $outfn)
    echo "${output}">"${outfn}"
    $TOUCH -d "${docvars[date]}" "${outfn}"
    echo -n "."
}

# here we iterate over every file, copy the values from $templatevars,
# and include anything from the json file

workfiles=$(ls -1t content/*.sh | grep -v default.sh | sort)
tab=$'\t'

echo "Working on content"
for n in $workfiles; do
    work_on "${n}" &
done

wait
echo

# finally, copy assets
echo "copying assets"
rsync -at content/assets/ $BUILD_DIR/assets/
echo "done."
