function post_links {
    declare -A templatevars=()
    . content/default.sh
    for fn in $(ls -t1 content/*.post.sh); do
        echo $fn
        declare -A docvars=()
        for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done
        . $fn
        if [[ ${docvars[type]} == 'post' ]]; then
            echo "<li>$(date -d "${docvars[date]}" '+%Y-%m-%d') <a href=\"${docvars[filename]}\">${docvars[title]}</a></li>"
        fi
    done
}
