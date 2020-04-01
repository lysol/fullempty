function rss_items {
    declare -A templatevars=()
    . content/default.sh
    for fn in $(ls -t -d -1 -R $*); do
        declare -A docvars=()
        for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done
        . $fn
        rssdate=$(${DATE} -d "${docvars[date]}" -R)
        if [ "${docvars[content]}" == "" ]; then
            docvars[content]="${docvars[description]}"
        else
            contentfn="${docvars[content]}"
            filecontent="$(< "${contentfn}")"
            docvars[content]="${filecontent}"
        fi
        echo "<item> \
  <title>${docvars[title]}</title> \
  <description><![CDATA[${docvars[content]}]]></description> \
  <link>https://fullempty.sh/${docvars[filename]}</link> \
  <guid isPermaLink='true'>https://fullempty.sh/${docvars[filename]}</guid> \
  <pubDate>${rssdate}</pubDate> \
 </item>"
    done
}
