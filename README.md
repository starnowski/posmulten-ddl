![Running the bats tests](https://github.com/starnowski/posmulten-ddl/workflows/Running%20the%20bats%20tests/badge.svg)

# posmulten-ddl

A wrapper script for project [configuration-jar](https://github.com/starnowski/posmulten/tree/master/configuration-parent/configuration-jar) that allows to creates the shared schema strategy for multi-tenant approach.
For the passed path to the configuration file, the wrapper creates two SQL scripts. One contains DDL statements that create a shared schema strategy, and the other one drops it.
__Important__, wrapper required installed java in version 8 or newer.
Please check module [configuration-yaml-interpreter](https://github.com/starnowski/posmulten/tree/master/configuration-parent/configuration-yaml-interpreter) to find out how to prepare a configuration file.

### How install script

*   Download or clone repository
*   Add __bin__ directory to PATH

## How to use wrapper

```bash
    posmulten-ddl.sh {Options} {Path to configuration file}
```

ARGUMENTS:

```bash
    1 - Path to configuration file
```

OPTIONS:

```bash
    -h, --help                  Prints the usage information
        --createScriptPath      Sets path for a script that contains DDL statements that create a shared schema strategy. By default, a file with the name create_script.sql is being created in the current directory.
        --dropScripPath         Sets path for a script that contains DDL statements that drop a shared schema strategy. By default, a file with the name drop_script.sql is being created in the current directory.
        --jarVersion            Sets version of jar file that should be used to generate ddl statements.
                                To check what version is available please check https://search.maven.org/artifact/com.github.starnowski.posmulten.configuration/configuration-jar site.
```

EXAMPLES:

```bash
    posmulten-ddl.sh ../examples/all-fields.yaml
    # Passing parameters with paths where result script should be created
    posmulten-ddl.sh --createScriptPath "../examples/cscript.sql" --dropScripPath "../examples/dscript.sql" ../examples/all-fields.yaml
    # Setting version of jar file which should be used
    posmulten-ddl.sh --jarVersion "0.3.0" ../examples/all-fields-0.3.0-valid.yaml
```