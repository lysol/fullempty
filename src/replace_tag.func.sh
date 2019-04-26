last_replace=""
function replace_tag {
    local key="$1"
    local val="$2"
    local output="$3"

    # hopefully this is enough to handle any ;s in the value
    # also replaces newlines with the escaped equiv so sed can replace it properly
    local baseregexval=$(echo "$val" | sed -e 's/\&/\\&/g' | sed -e 's/;/\\;/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    # replace the template tags
    # includes those escaped newlines in $baseregexval
    local regex=$(echo "s;<% $key %>;$baseregexval;g")
    last_replace=$(echo "$output" | sed -e "$regex")
}
