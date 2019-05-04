function reading_links {
    declare -A templatevars=()
    . content/default.sh
    for fn in $(ls -t -R -1 content/reading-list-*.sh); do
        declare -A docvars=()
        for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done
        . $fn
        echo "<li><i>$(date -d "${docvars[date]}" '+%Y-%m-%d')</i><br>${docvars[description]}</li>"
    done
}
