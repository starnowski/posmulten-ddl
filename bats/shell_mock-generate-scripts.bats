
function setup {
  #Save previous password
  PREVIOUS_PGPASSWORD="$PGPASSWORD"
  export TIMESTAMP=`date +%s`
  export RUN_SCRIPT="$BATS_TEST_DIRNAME/../bin/posmulten-ddl.sh"
  export VARS_FILE_PATH="$BATS_TEST_DIRNAME/../bin/vars.sh"
  export CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH="$BATS_TEST_DIRNAME/../examples"
  mkdir -p "$BATS_TMPDIR/$TIMESTAMP"
  # Clean the work directory
  rm -rf "$BATS_TEST_DIRNAME/../work"
  # Source the shellmock functions into the shell.
  . shellmock
  shellmock_clean
}

@test "Run executable jar file with passed java properties for valid configuration file" {
  #given
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar .*configuration-jar-${POSMULTEN_JAR_FILE_VERSION}-jar-with-dependencies.jar"

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --createScriptPath "$CREATE_SCRIPT_PATH" --dropScripPath "$DROP_SCRIPT_PATH" "$CONFIGURATION_FILE_PATH"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat shellmock.out  >&3

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]

  #TODO captured
}

function teardown {
  rm -rf "$BATS_TMPDIR/$TIMESTAMP"
  # Clean the work directory
  rm -rf "$BATS_TEST_DIRNAME/../work"
  if [ -z "$TEST_FUNCTION" ]; then
    shellmock_clean
  fi
}