#!/usr/bin/env bash

if [[ $0 != $BASH_SOURCE ]]; then
    SCRIPT_DIR="$(dirname $BASH_SOURCE)"
else
    SCRIPT_DIR="$(dirname $0)"
fi

source "$SCRIPT_DIR/vars.sh"

CREATE_SCRIPT_PATH="$2"
DROP_SCRIPT_PATH="$3"
JAR_FILE_PATH="$SCRIPT_DIR/../lib/configuration-jar-${POSMULTEN_JAR_FILE_VERSION}-jar-with-dependencies.jar"

java -Dposmulten.configuration.config.file.path="$1" -Dposmulten.configuration.create.script.path="$CREATE_SCRIPT_PATH" -Dposmulten.configuration.drop.script.path="$DROP_SCRIPT_PATH" -jar "$JAR_FILE_PATH"