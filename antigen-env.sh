# Setup environment variables from antigen plugins at login time, so they are
# available to all programs in the session, not just those launched from an
# interactive shell. To use, source this script from .profile.
#
# This file must be POSIX-shell compatible, since .profile is sourced by
# /bin/sh, which is often dash (or at least, not zsh).
#

# Should really be called antigen-env, but dash doesn't like functions with
# hyphens in the name.
antigenenv () {
    # We have to use this ugly style since POSIX shell doesn't do process
    # substitution, and the while loop has to be in this shell, not a subshell.
    local tmp="$(mktemp)"

    zsh -s "$@" > "$tmp" <<'EOF'
# Because the parent script is sourced by /bin/sh, we can't programmatically
# work out where the real antigen is - even though this script is in the same
# directory as it!
[[ -z "$ANTIGEN_INSTALL_DIR" ]] && exit 0
source "$ANTIGEN_INSTALL_DIR/antigen.zsh"
-antigen-get-env-scripts-and-locations "$@"
EOF

    local plugin=''
    local script=''
    while IFS='|' read plugin script; do
        ANTIGEN_THIS_PLUGIN_DIR="$plugin"
        . "$script"
        unset ANTIGEN_THIS_PLUGIN_DIR
        export ANTIGEN_PLUGINS_ENVED="$ANTIGEN_PLUGINS_ENVED:$plugin"
    done < "$tmp"

    rm "$tmp"
}

antigen () {
    local cmd="$1"
    if [ -z "$cmd" ]; then
        echo 'Antigen: Please give a command to run.' >&2
        return 1
    fi
    shift

    if [ "$cmd" = 'env' ]; then
        antigenenv "$@"
    else
        echo "Antigen: Inapplicable command: $cmd; only 'antigen env' can be run at this time" >&2
    fi
}
