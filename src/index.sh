#!/bin/bash

# $templatevars are used as the base variables for every template,
# sourced from default.json
declare -A templatevars
templatevars['year']=$(date +%Y)

for k in `jq -r 'to_entries[] | .key' <content/default.json`; do
    templatevars[${k}]=$(jq -r ".${k}" <content/default.json)
done

# here we iterate over every file, copy the values from $templatevars,
# and include anything from the json file
for n in `ls -1 content/*.json | grep -v default.json | sort -V`; do
    echo "Processing $n"
    declare -A docvars
    for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done
    # (probably an easier way to do this, but)
    for k in `jq -r 'to_entries[] | .key' <$n`; do
        val=$(cat $n | jq -r ".${k}")
        docvars[$k]=$val
    done
    # "template" is a special value that is the location of the base template to include
    output=$(cat ${docvars['template']})
    # "content" is more special, it's a filename that we cat the contents of to get the
    # actual value. might make it this more explicit rather than implicit later
    docvars[content]=$(cat ${docvars[content]})
    for i in "${!docvars[@]}"
    do
        # hopefully this is enough to handle any ;s in the value
        baseregexval=$(echo ${docvars[$i]} | sed -e 's/;/\\;/g')
        # replace the template tags
        regex=$(echo "s;<% $i %>;$baseregexval;g")
        output=$(echo $output | sed -e "$regex")
    done
    outfn="$BUILD_DIR/${docvars[filename]}"
    echo $output>$outfn
done
