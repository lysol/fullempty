#!/bin/bash

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

# here we iterate over every file, copy the values from $templatevars,
# and include anything from the json file

workfiles=$(ls -1t content/*.sh | grep -v default.sh | sort)
tab=$'\t'

for n in $workfiles; do
    echo "Working on ${n}"
    # initialize document associative array prefilled with templatevars' values
    declare -A docvars=()
    for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done

    # source file to set variables
    . "${n}"

    # "template" is a special value that is the location of the base template to include
    if [ "${docvars[template]}" == "" ]; then
        echo "Using blank template for ${n}."
        output="<% content %>"
    else
        output=$(< "${docvars['template']}")
    fi

    # if "date" is present, make a nice human-readable date.
    if [ ${docvars[date]+_} ]; then
        docvars[nicedate]="$(date -d "${docvars[date]}" '+%Y-%m-%d')"
    fi

    # "content" is more special, it's a filename that we cat the contents of to get the
    # actual value. might make it this more explicit rather than implicit later
    contentPath="${docvars[content]}"

    if [ -z "${contentPath}" ]; then
        echo "No content property in ${n}. Skipping."
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
    touch -d "${docvars[date]}" "${outfn}"
done

# finally, copy assets
echo copying assets
rsync -at content/assets/ $BUILD_DIR/assets/
