function rss_items {
    declare -A templatevars=()
    . content/default.sh
    for fn in $(ls -t -d -1 -R $*); do
        declare -A docvars=()
        for k in "${!templatevars[@]}"; do docvars[$k]="${templatevars[$k]}"; done
        . $fn
        rssdate=$(date -d "${docvars[date]}" -R)
        echo "<item> \
  <title>${docvars[title]}</title> \
  <description><![CDATA[${docvars[description]}]]></description> \
  <link>https://fullempty.sh/${docvars[filename]}</link> \
  <guid isPermaLink='true'>https://fullempty.sh/${docvars[filename]}</guid> \
  <pubDate>${rssdate}</pubDate> \
 </item>"
    done
}
