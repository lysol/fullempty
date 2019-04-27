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
                case "${c}" in
                    " ")
                        # eat it
                        ;;
                    "${cmd_char}")
                        # cmd ending
                        current_token="${c}"
                        ;;
                    "${close_tag}")
                        # cmd ending
                        if [[ "${current_token}" == "${cmd_char}" ]]; then
                            current_state="${BODY}"
                            val=$($current_token)
                            newoutput="${newoutput}${val}"
                            current_token=""
                        fi
                        ;;
                    *)
                        current_state="${IN_CMD}"
                        current_token="${c}"
                        ;;
                esac
                ;;
            "${IN_CMD}")
                case "${c}" in
                    "${cmd_char}")
                        # ending IN_CMD
                        # execute code
                        current_state="${CMD}"
                        ;;
                    *)
                        current_token="${current_token}${c}"
                        ;;
                esac
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
