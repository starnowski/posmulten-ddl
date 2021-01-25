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
    A wrapper script for project https://github.com/starnowski/posmulten/tree/master/configuration-parent that allows to creates the shared schema strategy for multi-tenant approach.
    For the passed path to the configuration file, the wrapper creates two SQL scripts. One contains DDL statements that create a shared schema strategy, and the other one drops it.

    $BASH_SOURCE {Options} {Path to configuration file}

ARGUMENTS:
    1 - Path to configuration file

OPTIONS:
    -h, --help                  Prints the usage information
        --createScriptPath      Sets path for a script that contains DDL statements that create a shared schema strategy. By default, a file with the name create_script.sql is being created in the current directory.
        --dropScripPath         Sets path for a script that contains DDL statements that drop a shared schema strategy. By default, a file with the name drop_script.sql is being created in the current directory.

EXAMPLES:

    posmulten-ddl.sh ../examples/all-fields.yaml
    posmulten-ddl.sh --createScriptPath "../examples/cscript.sql" --dropScripPath "../examples/dscript.sql" ../examples/all-fields.yaml

EOF
}



# Call getopt to validate the provided input.
options=$(getopt -o "h" --long help,createScriptPath:,dropScripPath:,verbose -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    print_usage
    exit 1
}

CURRENT_DIR=`pwd`
CREATE_SCRIPT_PATH="${CURRENT_DIR}/create_script.sql"
DROP_SCRIPT_PATH="${CURRENT_DIR}/drop_script.sql"
VERBOSE="false"
eval set -- "$options"
while true; do
    case "$1" in
    -h)
        print_usage
        exit 0
        ;;
    --verbose)
        VERBOSE="true"
        ;;
    --help)
        print_usage
        exit 0
        ;;
    --createScriptPath)
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

if [[ $# -eq 0 ]]; then
    echo "Invalid number of arguments"
    print_usage
    exit 1
fi

JAR_FILE_PATH="$SCRIPT_DIR/../lib/configuration-jar-${POSMULTEN_JAR_FILE_VERSION}-jar-with-dependencies.jar"

if [[ ${VERBOSE} == "true" ]]; then
    unzip -p "$JAR_FILE_PATH" debug-logging.properties > "$SCRIPT_DIR/../bin/debug-logging.properties"
    java -Djava.util.logging.config.file="$SCRIPT_DIR/../bin/debug-logging.properties" -Dposmulten.configuration.config.file.path="$1" -Dposmulten.configuration.create.script.path="$CREATE_SCRIPT_PATH" -Dposmulten.configuration.drop.script.path="$DROP_SCRIPT_PATH" -jar "$JAR_FILE_PATH"
else
    java -Dposmulten.configuration.config.file.path="$1" -Dposmulten.configuration.create.script.path="$CREATE_SCRIPT_PATH" -Dposmulten.configuration.drop.script.path="$DROP_SCRIPT_PATH" -jar "$JAR_FILE_PATH"
fi