#!/usr/bin/env bash

if [[ $0 != $BASH_SOURCE ]]; then
    SCRIPT_DIR="$(dirname $BASH_SOURCE)"
else
    SCRIPT_DIR="$(dirname $0)"
fi

source "$SCRIPT_DIR/vars.sh"

function print_usage
{
cat << EOF
USAGE:

EOF
}



# Call getopt to validate the provided input.
options=$(getopt -o "h" --long help,createSriptPath,dropScripPath: -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}

CURRENT_DIR=`pwd`
CREATE_SCRIPT_PATH="${CURRENT_DIR}/create_script.sql"
DROP_SCRIPT_PATH="${CURRENT_DIR}/drop_script.sql"
eval set -- "$options"
while true; do
    case "$1" in
    --h,help)
        print_usage
        exit 0
        ;;
    --createSriptPath)
        shift;
        CREATE_SCRIPT_PATH="$1"
        ;;
    --dropScripPath)
        shift;
        DROP_SCRIPT_PATH="$1"
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

JAR_FILE_PATH="$SCRIPT_DIR/../lib/configuration-jar-${POSMULTEN_JAR_FILE_VERSION}-jar-with-dependencies.jar"

java -Dposmulten.configuration.config.file.path="$1" -Dposmulten.configuration.create.script.path="$CREATE_SCRIPT_PATH" -Dposmulten.configuration.drop.script.path="$DROP_SCRIPT_PATH" -jar "$JAR_FILE_PATH"