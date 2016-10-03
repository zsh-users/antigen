-antigen-parse-args () {
    # An argument parsing functionality to parse arguments the *antigen* way :).
    # Takes one first argument (called spec), which dictates how to parse and
    # the rest of the arguments are parsed. Outputs a piece of valid shell code
    # that can be passed to `eval` inside a function which creates the arguments
    # and their values as local variables. Suggested use is to set the defaults
    # to all arguments first and then eval the output of this function.

    # Spec: Only long argument supported. No support for parsing short options.
    # The spec must have two sections, separated by a `;`.
    #       '<positional-arguments>;<keyword-only-arguments>'
    # Positional arguments are passed as just values, like `command a b`.
    # Keyword arguments are passed as a `--name=value` pair, like `command
    # --arg1=a --arg2=b`.

    # Each argument in the spec is separated by a `,`. Each keyword argument can
    # end in a `:` to specifiy that this argument wants a value, otherwise it
    # doesn't take a value. (The value in the output when the keyword argument
    # doesn't have a `:` is `true`).

    # Arguments in either section can end with a `?` (should come after `:`, if
    # both are present), means optional. FIXME: Not yet implemented.

    # See the test file, tests/arg-parser.t for (working) examples.

    local spec="$1"
    shift

    # Sanitize the spec
    spec="$(echo "$spec" | tr '\n' ' ' | sed 's/[[:space:]]//g')"

    local code=''

    --add-var () {
        test -z "$code" || code="$code\n"
        code="${code}local $1='$2'"
    }

    local positional_args="$(echo "$spec" | cut -d\; -f1)"
    local positional_args_count="$(echo $positional_args |
            awk -F, '{print NF}')"

    # Set spec values based on the positional arguments.
    local i=1
    while [[ -n $1 && $1 != --* ]]; do

        if (( $i > $positional_args_count )); then
            echo "Only $positional_args_count positional arguments allowed." >&2
            echo "Found at least one more: '$1'" >&2
            return
        fi

        local name_spec="$(echo "$positional_args" | cut -d, -f$i)"
        local name="${${name_spec%\?}%:}"
        local value="$1"

        if echo "$code" | grep -l "^local $name=" &> /dev/null; then
            echo "Argument '$name' repeated with the value '$value'". >&2
            return
        fi

        --add-var $name "$value"

        shift
        i=$(($i + 1))
    done

    local keyword_args="$(
            # Positional arguments can double up as keyword arguments too.
            echo "$positional_args" | tr , '\n' |
                while read line; do
                    if [[ $line == *\? ]]; then
                        echo "${line%?}:?"
                    else
                        echo "$line:"
                    fi
                done

            # Specified keyword arguments.
            echo "$spec" | cut -d\; -f2 | tr , '\n'
            )"
    local keyword_args_count="$(echo $keyword_args | awk -F, '{print NF}')"

    # Set spec values from keyword arguments, if any. The remaining arguments
    # are all assumed to be keyword arguments.
    while [[ $1 == --* ]]; do
        # Remove the `--` at the start.
        local arg="${1#--}"

        # Get the argument name and value.
        if [[ $arg != *=* ]]; then
            local name="$arg"
            local value=''
        else
            local name="${arg%\=*}"
            local value="${arg#*=}"
        fi

        if echo "$code" | grep -l "^local $name=" &> /dev/null; then
            echo "Argument '$name' repeated with the value '$value'". >&2
            return
        fi

        # The specification for this argument, used for validations.
        local arg_line="$(echo "$keyword_args" |
                            egrep "^$name:?\??" | head -n1)"

        # Validate argument and value.
        if [[ -z $arg_line ]]; then
            # This argument is not known to us.
            echo "Unknown argument '$name'." >&2
            return

        elif (echo "$arg_line" | grep -l ':' &> /dev/null) &&
                [[ -z $value ]]; then
            # This argument needs a value, but is not provided.
            echo "Required argument for '$name' not provided." >&2
            return

        elif (echo "$arg_line" | grep -vl ':' &> /dev/null) &&
                [[ -n $value ]]; then
            # This argument doesn't need a value, but is provided.
            echo "No argument required for '$name', but provided '$value'." >&2
            return

        fi

        if [[ -z $value ]]; then
            value=true
        fi

        --add-var "${name//-/_}" "$value"
        shift
    done

    echo "$code"

    unfunction -- --add-var

}
