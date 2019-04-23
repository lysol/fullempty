#!/bin/bash

# $templatevars are used as the base variables for every template,
# sourced from default.json
declare -A templatevars
templatevars['year']=$(date +%Y)
templatevars['date']=$(date)

defaultjson=$(< content/default.json)
for k in `echo "$defaultjson" | jq -r 'to_entries[] | .key'`; do
    templatevars[${k}]=$(echo $defaultjson | jq -r ".${k}")
done

# here we iterate over every file, copy the values from $templatevars,
# and include anything from the json file
for n in `ls -1 content/*.json | grep -v default.json | sort -V`; do
    echo "Processing $n"

    # initialize document associative array prefilled with tempaltevars' values
    declare -A docvars
    for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done

    # (probably an easier way to do this, but) set the values from the file
    docjson=$(<$n)
    for k in `echo "$docjson" | jq -r 'to_entries[] | .key'`; do
        val=$(echo "$docjson" | jq -r ".${k}")
        docvars[$k]=$val
    done
    # "template" is a special value that is the location of the base template to include
    output=$(cat ${docvars['template']})

    # "content" is more special, it's a filename that we cat the contents of to get the
    # actual value. might make it this more explicit rather than implicit later
    contentPath=${docvars[content]}

    if [ -z "$contentPath" ]; then
        echo "No content property in $n. Skipping."
        continue
    fi

    if [[ -x "$contentPath" ]]; then
        # file is executable, execute it to get our content
        docvars[content]=$($contentPath)
    else
        # otherwise just redirect contents
        docvars[content]=$(< "$contentPath")
    fi

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
    touch -d "${docvars[date]}" $outfn
done
