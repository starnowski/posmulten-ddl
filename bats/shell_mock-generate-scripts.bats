
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

function should_print_yaml_schema_guide_test {
  #given
  TEST_JAR_VERSION="$1"
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.yaml.syntax.guide.print=true -jar .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  shellmock_expect curl --status 0 --type regex --match "https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  [ ! -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]
  #Get script version

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --printYamlSchemaGuide --jarVersion "$TEST_JAR_VERSION"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 0 ]
  [[ "${capture[0]}" =~ "curl-stub https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output" ]]
  [[ "${capture[1]}" =~ "java-stub -Dposmulten.configuration.config.yaml.syntax.guide.print="true" -jar" ]]

  [ "${lines[0]}" = "posmulten-ddl script version: ${POSMULTEN_DDL_VERSION}" ]
  [ "${lines[1]}" = "posmulten jar file version: ${TEST_JAR_VERSION}" ]
}

function should_not_print_yaml_schema_guide_test {
  #given
  TEST_JAR_VERSION="$1"
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.yaml.syntax.guide.print=true -jar .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  [ ! -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]
  #Get script version

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --printYamlSchemaGuide --jarVersion "$TEST_JAR_VERSION"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 1 ]
  [[ "${capture[0]}" =~ "curl-stub https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output" ]]

  [ "${lines[0]}" = "posmulten-ddl script version: ${POSMULTEN_DDL_VERSION}" ]
  [ "${lines[1]}" = "posmulten jar file version: ${TEST_JAR_VERSION}" ]
  [ "${lines[2]}" = "The '--printYamlSchemaGuide' option is available since version 0.5.0, current version is ${TEST_JAR_VERSION}" ]
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
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 0 ]
  [[ "${capture[0]}" =~ "java-stub -Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar" ]]
}

@test "Run executable jar file for specific version of jar file and download jar file if not exists" {
  #given
  TEST_JAR_VERSION="9.9.9"
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  shellmock_expect curl --status 0 --type regex --match "https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  [ ! -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --createScriptPath "$CREATE_SCRIPT_PATH" --dropScripPath "$DROP_SCRIPT_PATH" --jarVersion "$TEST_JAR_VERSION" "$CONFIGURATION_FILE_PATH"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 0 ]
  [[ "${capture[0]}" =~ "curl-stub https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output" ]]
  [[ "${capture[1]}" =~ "java-stub -Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar" ]]
}

@test "Run executable jar file for specific version of jar file and do not download jar file if exists" {
  #given
  TEST_JAR_VERSION="13.6.22"
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  shellmock_expect curl --status 1
  # creating fake jar file
  mkdir -p "$BATS_TEST_DIRNAME/../work"
  touch "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --createScriptPath "$CREATE_SCRIPT_PATH" --dropScripPath "$DROP_SCRIPT_PATH" --jarVersion "$TEST_JAR_VERSION" "$CONFIGURATION_FILE_PATH"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 0 ]
  [[ "${capture[0]}" =~ "java-stub -Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar" ]]
}

@test "Script should fail for specific version of jar file and print error message when download does not work" {
  #given
  TEST_JAR_VERSION="5.223.1"
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  shellmock_expect curl --status 1 --type regex --match "https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  [ ! -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --createScriptPath "$CREATE_SCRIPT_PATH" --dropScripPath "$DROP_SCRIPT_PATH" --jarVersion "$TEST_JAR_VERSION" "$CONFIGURATION_FILE_PATH"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 1 ]
  [[ "${capture[0]}" =~ "curl-stub https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output" ]]
  [[ ! "${capture[1]}" =~ "java-stub" ]]
  # Check error message
  echo "$output" > "$BATS_TMPDIR/$TIMESTAMP/output_file"
  grep "Unable to download jar file for version ${TEST_JAR_VERSION}" "$BATS_TMPDIR/$TIMESTAMP/output_file"
}

@test "Script should print script and custom jar file version during execution" {
  #given
  TEST_JAR_VERSION="XX.13.9"
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  shellmock_expect curl --status 0 --type regex --match "https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output .*configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar"
  [ ! -f "$BATS_TEST_DIRNAME/../work/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar" ]
  #Get script version

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --createScriptPath "$CREATE_SCRIPT_PATH" --dropScripPath "$DROP_SCRIPT_PATH" --jarVersion "$TEST_JAR_VERSION" "$CONFIGURATION_FILE_PATH"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 0 ]
  [[ "${capture[0]}" =~ "curl-stub https://repo1.maven.org/maven2/com/github/starnowski/posmulten/configuration/configuration-jar/${TEST_JAR_VERSION}/configuration-jar-${TEST_JAR_VERSION}-jar-with-dependencies.jar --output" ]]
  [[ "${capture[1]}" =~ "java-stub -Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar" ]]

  [ "${lines[0]}" = "posmulten-ddl script version: ${POSMULTEN_DDL_VERSION}" ]
  [ "${lines[1]}" = "posmulten jar file version: ${TEST_JAR_VERSION}" ]
}

@test "Run executable jar file with verbose parameter and pass correct file with logging options" {
  #given
  CONFIGURATION_FILE_PATH="/none/existed/dir/all-fields.yaml"
  CREATE_SCRIPT_PATH="create/here/script.sql"
  DROP_SCRIPT_PATH="/drop/script.sql"
  source "$VARS_FILE_PATH"
  shellmock_expect java --status 0 --type regex --match "-Djava.util.logging.config.file=.*/debug-logging.properties -Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -jar .*configuration-jar-${POSMULTEN_JAR_FILE_VERSION}-jar-with-dependencies.jar"

  #when
  pushd "$BATS_TMPDIR/$TIMESTAMP"
  run "$RUN_SCRIPT" --verbose --createScriptPath "$CREATE_SCRIPT_PATH" --dropScripPath "$DROP_SCRIPT_PATH" "$CONFIGURATION_FILE_PATH"
  popd

  shellmock_dump
  shellmock_verify
  echo "shellmock.out output :"  >&3
  cat "$BATS_TEST_DIRNAME/shellmock.out"  >&3

  #then
  echo "output is --> $output <--"  >&3
  echo "capture output ${capture[0]}"  >&3
  [ "$status" -eq 0 ]
  REGEX_PATTERN="java-stub -Djava.util.logging.config.file=.* -Dposmulten.configuration.config.file.path=${CONFIGURATION_FILE_PATH} -Dposmulten.configuration.create.script.path=${CREATE_SCRIPT_PATH} -Dposmulten.configuration.drop.script.path=${DROP_SCRIPT_PATH} -ja"
  [[ "${capture[0]}" =~ $REGEX_PATTERN ]]
}

@test "Script should print yaml schema guide for library version 0.5.1" {
  should_print_yaml_schema_guide_test "0.5.1"
}

@test "Script should print yaml schema guide for library version 0.30.0" {
  should_print_yaml_schema_guide_test "0.30.0"
}

@test "Script should print yaml schema guide for library version 1.1.0" {
  should_print_yaml_schema_guide_test "1.1.0"
}

@test "Script should not print yaml schema guide for library version 0.4.1" {
  should_not_print_yaml_schema_guide_test "0.4.1"
}

@test "Script should not print yaml schema guide for library version 0.3.9" {
  should_not_print_yaml_schema_guide_test "0.3.9"
}

function teardown {
  if [ -e "$BATS_TEST_DIRNAME/shellmock.err" ]; then
      cat "$BATS_TEST_DIRNAME/shellmock.err"  >&3
      echo "shellmock.err output :"  >&3
  fi
  rm -rf "$BATS_TMPDIR/$TIMESTAMP"
  # Clean the work directory
  rm -rf "$BATS_TEST_DIRNAME/../work"
  if [ -z "$TEST_FUNCTION" ]; then
    shellmock_clean
  fi
}