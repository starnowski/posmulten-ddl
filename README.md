![Running the bats tests](https://github.com/starnowski/posmulten-ddl/workflows/Running%20the%20bats%20tests/badge.svg)

# posmulten-ddl

A wrapper script for project [configuration-jar](https://github.com/starnowski/posmulten/tree/master/configuration-parent/configuration-jar) that allows to creates the shared schema strategy for multi-tenant approach.
For the passed path to the configuration file, the wrapper creates two SQL scripts. One contains DDL statements that create a shared schema strategy, and the other one drops it.
__Important__, wrapper required installed java in version 8 or newer.
Please check module [configuration-yaml-interpreter](https://github.com/starnowski/posmulten/tree/master/configuration-parent/configuration-yaml-interpreter) how to prepare configuration file.

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
```

EXAMPLES:

```bash
    posmulten-ddl.sh ../examples/all-fields.yaml
    posmulten-ddl.sh --createScriptPath "../examples/cscript.sql" --dropScripPath "../examples/dscript.sql" ../examples/all-fields.yaml
```