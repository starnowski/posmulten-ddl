
function setup {
  #Save previous password
  PREVIOUS_PGPASSWORD="$PGPASSWORD"
  export TIMESTAMP=`date +%s`
  export RUN_SCRIPT="$BATS_TEST_DIRNAME/../bin/posmulten-ddl.sh"
  export CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH="$BATS_TEST_DIRNAME/../examples"
  mkdir -p "$BATS_TMPDIR/$TIMESTAMP"
}

@test "Run executable jar file with passed java properties for valid configuration file" {
  #given
  CONFIGURATION_FILE_PATH="$CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH/all-fields.yaml"
  [ -f "$CONFIGURATION_FILE_PATH" ]
  # Results files
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/create_script.sql" ]
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql" ]

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" "$CONFIGURATION_FILE_PATH"
  popd

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/create_script.sql" ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql" ]

  #Smoke tests for scripts content
  grep 'CREATE POLICY' "$BATS_TMPDIR/$TIMESTAMP/create_script.sql"
  grep 'DROP POLICY IF EXISTS' "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql"
}

function teardown {
  rm -rf "$BATS_TMPDIR/$TIMESTAMP"
}