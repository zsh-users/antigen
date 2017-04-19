-antigen-parse-args () {
  local argkey key value index=0
  local match mbegin mend MATCH MBEGIN MEND

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
          0)
            key=url
            local domain=""
            local url_path=$value
            if [[ "$value" =~ "://" || "$value" =~ ":" ]]; then # Full url with protocol or ssh github url (github.com:org/repo)
              if [[ "$value" =~ [@.][^/:]+[:]?[0-9]*[:/]?(.*)@?$ ]]; then
                url_path=$match[1]
                domain=${value/$url_path/}
              fi
            fi

            if [[ "$url_path" =~ '@' ]]; then
              echo "local branch='${url_path#*@}'"
              value="$domain${url_path%@*}"
            else
              value="$domain$url_path"
            fi
          ;;
          1) key=loc ;;
        esac
        let index+=1
        echo "local $key='$value'"
      ;;
    esac

    shift
  done
}
