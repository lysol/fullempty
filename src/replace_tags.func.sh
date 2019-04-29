function replace_tags {
    local -n vars=$1
    keys="${!vars[@]}"
    local newoutput=""

    local current_token=''
    local tag_char='%'
    local cmd_char='$'
    local open_tag='<'
    local close_tag='>'
    local new_line=$'\n'
    # text
    local BODY=1
    # starting cmd
    local TAG=2
    local IN_TAG=3
    local CMD=4
    local IN_CMD=5
    local current_state="${BODY}"

    while IFS='' read -n1 c; do
        if [[ "${c}" == "" ]]; then
            c="${new_line}"
        fi
        case "${current_state}" in
            "${BODY}")
                case "${c}" in
                    "${open_tag}")
                        newoutput="${newoutput}${current_token}"
                        current_token="${open_tag}"
                        ;;
                    "${tag_char}")
                        if [[ "${current_token}" == "${open_tag}" ]]; then
                            current_state="${TAG}"
                            current_token=""
                        else
                            current_token="${current_token}${c}"
                        fi
                        ;;
                    "${cmd_char}")
                        if [[ "${current_token}" == "${open_tag}" ]]; then
                            current_state="${CMD}"
                            current_token=""
                        else
                            current_token="${current_token}${c}"
                        fi
                        ;;
                    *)
                        current_token="${current_token}${c}"
                        ;;
                esac
                ;;
            "${TAG}")
                case "${c}" in
                    " ")
                        # eat it
                        ;;
                    "${tag_char}")
                        # tag ending
                        current_token="${c}"
                        ;;
                    "${close_tag}")
                        # tag ending
                        if [[ "${current_token}" == "${tag_char}" ]]; then
                            current_state="${BODY}"
                            current_token=""
                        fi
                        ;;
                    *)
                        current_state="${IN_TAG}"
                        current_token="${c}"
                        ;;
                esac
                ;;
            "${IN_TAG}")
                case "${c}" in
                    " ")
                        # ending IN_TOKEN
                        for key in $keys; do
                            if [[ "${current_token}" == "${key}" ]]; then
                                val="${vars[${key}]}"
                                newoutput="${newoutput}${val}"
                            fi
                        done
                        current_state="${TAG}"
                        ;;
                    *)
                        current_token="${current_token}${c}"
                        ;;
                esac
                ;;
            "${CMD}")
                let "codelen=${#current_token} - 2"
                if [[ "${current_token:${codelen}:2}" == "${cmd_char}${close_tag}" ]]; then
                    # done
                    val=$(eval ${current_token:0:${codelen}})
                    newoutput="${newoutput}${val}"
                    current_token=""
                    current_state="${BODY}"
                else
                    current_token="${current_token}${c}"
                fi
                ;;
            *)
                # pass
                ;;
        esac
    done
    if [[ "${current_state}" == "${BODY}" ]]; then
        newoutput="${newoutput}${current_token}"
    fi
    echo "${newoutput}"
}
