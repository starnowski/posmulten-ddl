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
    A wrapper script for project https://github.com/starnowski/posmulten/tree/master/configuration-parent/configuration-jar that allows to creates the shared schema strategy for multi-tenant approach.
    For the passed path to the configuration file, the wrapper creates two SQL scripts. One contains DDL statements that create a shared schema strategy, and the other one drops it.
    Important, wrapper required installed java in version 8 or newer.
    Please check module https://github.com/starnowski/posmulten/tree/master/configuration-parent/configuration-yaml-interpreter to find out how to prepare a configuration file.

    $BASH_SOURCE {Options} {Path to configuration file}

ARGUMENTS:
    1 - Path to configuration file

OPTIONS:
    -h, --help                  Prints the usage information
        --createScriptPath      Sets path for a script that contains DDL statements that create a shared schema strategy. By default, a file with the name create_script.sql is being created in the current directory.
        --dropScripPath         Sets path for a script that contains DDL statements that drop a shared schema strategy. By default, a file with the name drop_script.sql is being created in the current directory.
        --jarVersion            Sets version of jar file that should be used to generate ddl statements.
                                To check what version is available please check https://search.maven.org/artifact/com.github.starnowski.posmulten.configuration/configuration-jar site.
        --verbose               Sets a higher logging level. Useful for debugging purposes.

EXAMPLES:

    posmulten-ddl.sh ../examples/all-fields.yaml
    # Passing parameters with paths where result script should be created
    posmulten-ddl.sh --createScriptPath "../examples/cscript.sql" --dropScripPath "../examples/dscript.sql" ../examples/all-fields.yaml
    # Setting version of jar file which should be used
    posmulten-ddl.sh --jarVersion "0.3.0" ../examples/all-fields-0.3.0-valid.yaml

EOF
}



# Call getopt to validate the provided input.
options=$(getopt -o "h" --long help,createScriptPath:,dropScripPath:,verbose,jarVersion: -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    print_usage
    exit 1
}

CURRENT_DIR=`pwd`
CREATE_SCRIPT_PATH="${CURRENT_DIR}/create_script.sql"
DROP_SCRIPT_PATH="${CURRENT_DIR}/drop_script.sql"
VERBOSE="false"
JAR_VERSION=""
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
    --jarVersion)
        shift;
        JAR_VERSION="$1"
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
set -e

mkdir -p "$SCRIPT_DIR/../work"
CURRENT_JAR_VERSION=""
if [[ "$JAR_VERSION" == "" ]]; then
    cp "$SCRIPT_DIR/../lib/configuration-jar-${POSMULTEN_JAR_FILE_VERSION}-jar-with-dependencies.jar" "$SCRIPT_DIR/../work"
    CURRENT_JAR_VERSION="$POSMULTEN_JAR_FILE_VERSION"
else
    if [[ ! -e "$SCRIPT_DIR/../work/configuration-jar-${JAR_VERSION}-jar-with-dependencies.jar" ]]; then
        set +e
        #Download
        curl "https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${JAR_VERSION}/configuration-jar-${JAR_VERSION}-jar-with-dependencies.jar" --output "$SCRIPT_DIR/../work/configuration-jar-${JAR_VERSION}-jar-with-dependencies.jar"
        DOWNLOAD_STATUS="$?"
        if [[ ! "$DOWNLOAD_STATUS" == "0" ]]; then
            echo "Unable to download jar file for version ${JAR_VERSION}"
            exit 1
        fi
        set -e
    fi
    CURRENT_JAR_VERSION="$JAR_VERSION"
fi

JAR_FILE_PATH="$SCRIPT_DIR/../work/configuration-jar-${CURRENT_JAR_VERSION}-jar-with-dependencies.jar"

echo "posmulten-ddl script version: ${POSMULTEN_DDL_VERSION}"
echo "posmulten jar file version: ${CURRENT_JAR_VERSION}"

if [[ ${VERBOSE} == "true" ]]; then
    unzip -p "$JAR_FILE_PATH" debug-logging.properties > "$SCRIPT_DIR/../bin/debug-logging.properties"
    java -Djava.util.logging.config.file="$SCRIPT_DIR/../bin/debug-logging.properties" -Dposmulten.configuration.config.file.path="$1" -Dposmulten.configuration.create.script.path="$CREATE_SCRIPT_PATH" -Dposmulten.configuration.drop.script.path="$DROP_SCRIPT_PATH" -jar "$JAR_FILE_PATH"
else
    java -Dposmulten.configuration.config.file.path="$1" -Dposmulten.configuration.create.script.path="$CREATE_SCRIPT_PATH" -Dposmulten.configuration.drop.script.path="$DROP_SCRIPT_PATH" -jar "$JAR_FILE_PATH"
fi