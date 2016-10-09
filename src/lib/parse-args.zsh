-antigen-parse-args () {
    local key
    local value
    local index=0

    while [[ $# -gt 0 ]]; do
        argkey="${1%\=*}"
        key="${argkey//--/}"
        value="${1#*=}"

        case "$argkey" in
            --url|--loc|--branch|--btype)
                if [[ "$value" == "$argkey" ]]; then
                    echo "Required argument for '$key' not provided."
                else
                    echo "local $key='$value'"
                fi
            ;;
            --no-local-clone)
                echo "local no_local_clone='true'"
            ;;
            --*)
                echo "Unknown argument '$key'."
            ;;
            *)
                value=$key
                case $index in
                    0) key=url ;;
                    1) key=loc ;;
                esac
                let index+=1
                echo "local $key='$value'"
            ;;
        esac

        shift
    done
}
