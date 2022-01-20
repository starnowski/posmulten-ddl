
function setup {
  #Save previous password
  PREVIOUS_PGPASSWORD="$PGPASSWORD"
  export TIMESTAMP=`date +%s`
  export RUN_SCRIPT="$BATS_TEST_DIRNAME/../bin/posmulten-ddl.sh"
  export VARS_SOURCE_SCRIPT="$BATS_TEST_DIRNAME/../bin/vars.sh"
  export CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH="$BATS_TEST_DIRNAME/../examples"
  mkdir -p "$BATS_TMPDIR/$TIMESTAMP"
  # Clean the work directory
  rm -rf "$BATS_TEST_DIRNAME/../work"
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

@test "Run executable jar file with passed java properties for valid configuration file and custom script file paths" {
  #given
  CONFIGURATION_FILE_PATH="$CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH/all-fields.yaml"
  [ -f "$CONFIGURATION_FILE_PATH" ]
  mkdir -p "$BATS_TMPDIR/$TIMESTAMP/custom_dir"
  # Results files
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/custom_dir/cscript.sql" ]
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/custom_dir/dscript.sql" ]

  #when
  run "$RUN_SCRIPT" --createScriptPath "$BATS_TMPDIR/$TIMESTAMP/custom_dir/cscript.sql" --dropScripPath "$BATS_TMPDIR/$TIMESTAMP/custom_dir/dscript.sql" "$CONFIGURATION_FILE_PATH"

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/custom_dir/cscript.sql" ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/custom_dir/dscript.sql" ]

  #Smoke tests for scripts content
  grep 'CREATE POLICY' "$BATS_TMPDIR/$TIMESTAMP/custom_dir/cscript.sql"
  grep 'DROP POLICY IF EXISTS' "$BATS_TMPDIR/$TIMESTAMP/custom_dir/dscript.sql"
}

@test "should print usage for the h option" {
  #given


  #when
  run "$RUN_SCRIPT" -h

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]

  [ "${lines[0]}" = 'USAGE:' ]
}

@test "should print usage for the help option" {
  #given


  #when
  run "$RUN_SCRIPT" --help

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]

  [ "${lines[0]}" = 'USAGE:' ]
}

@test "Run executable jar file with verbose parameter for valid configuration file" {
  #given
  CONFIGURATION_FILE_PATH="$CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH/all-fields.yaml"
  [ -f "$CONFIGURATION_FILE_PATH" ]
  # Results files
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/create_script.sql" ]
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql" ]

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --verbose "$CONFIGURATION_FILE_PATH"
  popd

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/create_script.sql" ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql" ]

  #Smoke tests for scripts content
  grep 'CREATE POLICY' "$BATS_TMPDIR/$TIMESTAMP/create_script.sql"
  grep 'DROP POLICY IF EXISTS' "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql"
  echo "$output" > "$BATS_TMPDIR/$TIMESTAMP/output_file"
  grep 'INFO:' "$BATS_TMPDIR/$TIMESTAMP/output_file"
}

@test "Run executable jar file for specific version of jar file" {
  #given
  CONFIGURATION_FILE_PATH="$CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH/all-fields-0.3.0-valid.yaml"
  TEST_JAR_VERSION="0.3.0"
  [ -f "$CONFIGURATION_FILE_PATH" ]
  # Results files
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/create_script.sql" ]
  [ ! -f "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql" ]
  [ ! -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --jarVersion "$TEST_JAR_VERSION" "$CONFIGURATION_FILE_PATH"
  popd

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/create_script.sql" ]
  [ -f "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql" ]
  [ -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]

  #Smoke tests for scripts content
  grep 'CREATE POLICY' "$BATS_TMPDIR/$TIMESTAMP/create_script.sql"
  grep 'DROP POLICY IF EXISTS' "$BATS_TMPDIR/$TIMESTAMP/drop_script.sql"
}

@test "Script should print script and jar file version during execution" {
  #given
  CONFIGURATION_FILE_PATH="$CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH/all-fields.yaml"
  [ -f "$CONFIGURATION_FILE_PATH" ]
  source "$VARS_SOURCE_SCRIPT"

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" "$CONFIGURATION_FILE_PATH"
  popd

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]

  [ "${lines[0]}" = "posmulten-ddl script version: ${POSMULTEN_DDL_VERSION}" ]
  [ "${lines[1]}" = "posmulten jar file version: ${POSMULTEN_JAR_FILE_VERSION}" ]
}

@test "Script should print yaml schema guide" {
  #given
  CONFIGURATION_FILE_PATH="$CONFIGURATION_YAML_TEST_RESOURCES_DIR_PATH/all-fields.yaml"
  [ -f "$CONFIGURATION_FILE_PATH" ]
  source "$VARS_SOURCE_SCRIPT"

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --printYamlSchemaGuide
  popd

  #then
  echo "output is --> $output <--"  >&3
  [ "$status" -eq 0 ]

  [ "${lines[0]}" = "# Configuration-yaml-interpreter" ]
}

function teardown {
  rm -rf "$BATS_TMPDIR/$TIMESTAMP"
  # Clean the work directory
  rm -rf "$BATS_TEST_DIRNAME/../work"
}