function replace_tags {
    local -n vars=$1
    keys="${!vars[@]}"
    local newoutput=""

    declare -a _tokens=()
    local current_token=''
    # text
    local BODY=1
    # starting cmd
    local CMD=2
    local IN_CMD=3
    local current_state="${BODY}"

    while IFS='' read -n1 c; do
        if [[ "${c}" == "" ]]; then
            c=$'\n'
        fi
        case "${current_state}" in
            "${BODY}")
                case "${c}" in
                    "<")
                        newoutput="${newoutput}${current_token}"
                        current_token="<"
                        ;;
                    "%")
                        if [[ "${current_token}" == "<" ]]; then
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
            "${CMD}")
                case "${c}" in
                    " ")
                        # eat it
                        ;;
                    "%")
                        # cmd ending
                        current_token="%"
                        ;;
                    ">")
                        # cmd ending
                        if [[ "${current_token}" == "%" ]]; then
                            current_state="${BODY}"
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
                    " ")
                        # ending IN_TOKEN
                        for key in $keys; do
                            if [[ "${current_token}" == "${key}" ]]; then
                                val="${vars[${key}]}"
                                newoutput="${newoutput}${val}"
                            fi
                        done
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
