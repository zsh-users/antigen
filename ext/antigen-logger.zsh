# logger extension
# logs bundled stuff
#
# TODO add load time per bundle and accumulated load time
local -a bundles; bundles=()

# register the loaded bundles
function -antigen-bundle-log () {
    bundles+=($@)
}

# logger command that prints the logged bundles
function antigen-logger () {
    echo Bundles currently loaded:
    echo
    for bundle in $bundles; do
        echo $bundle
    done
    echo
}

# hooks into antigen-bundle to have access to all 'antigen bundle *' runs
-ext-hook "antigen-bundle" "-antigen-bundle-log"

# add a completion for the extension
-ext-compadd "logger"
