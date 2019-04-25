#!/bin/bash

# $templatevars are used as the base variables for every template,
# sourced from default.json
declare -A templatevars
templatevars['year']=$(date +%Y)
templatevars['date']=$(date)
# set default template vars
. content/default.sh
POST_INDEX="${BUILD_DIR}${POST_INDEX}"

last_replace=""
function replace_tag {
    local key="$1"
    local val="$2"
    local output="$3"

    # hopefully this is enough to handle any ;s in the value
    # also replaces newlines with the escaped equiv so sed can replace it properly
    local baseregexval=$(echo "$val" | sed -e 's/;/\\;/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    # replace the template tags
    # includes those escaped newlines in $baseregexval
    local regex=$(echo "s;<% $key %>;$baseregexval;g")
    last_replace=$(echo "$output" | sed -e "$regex")
}

# here we iterate over every file, copy the values from $templatevars,
# and include anything from the json file

workfiles=$(ls -1 content/*.post.sh | grep -v default.sh | sort -V)
tab=$'\t'

echo First pass
for n in $workfiles; do
    echo "Processing $n"

    # initialize document associative array prefilled with templatevars' values
    declare -A docvars=()
    for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done

    # source file to set variables
    . "${n}"
    if [[ "${docvars[type]}" == 'post' ]]; then
        echo "$(date -d "${docvars[date]}" '+%s')${tab}${docvars[filename]}${tab}${docvars[title]}">>"${POST_INDEX}"
    fi
done

posttext=""
IFS=$'\n'
for line in $(cat "${POST_INDEX}" | sort -n); do
    IFS=$'\t' vars=(${line})
    # abuse the previous IFS little to put a newline in lol
    posttext="${posttext}${IFS}<li>$(date -d @"${vars[0]}" '+%Y-%m-%d') <a href=\"${vars[1]}\">${vars[2]}</a></li>"
done
unset IFS

# set the post list in the base template so it can be used later
templatevars[postitems]=${posttext}

echo Second pass
for n in $workfiles; do
    echo "Working on ${n} (again)"
    # initialize document associative array prefilled with templatevars' values
    declare -A docvars=()
    for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done

    # source file to set variables
    . "${n}"

    # "template" is a special value that is the location of the base template to include
    output=$(< "${docvars['template']}")

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
        # this might be bad but we also go through each existing
        # docvar and do replacements there too
        for j in "${!docvars[@]}"
        do
            if [[ "${i}" != "${j}" ]]; then
                replace_tag "${i}" "${docvars[${i}]}" "${docvars[${j}]}"
                docvars["${j}"]="${last_replace}"
            fi
        done
        replace_tag "${i}" "${docvars[$i]}" "${output}"
        output="${last_replace}"
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
