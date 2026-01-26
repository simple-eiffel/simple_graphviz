# ArchViz - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_graphviz | Core diagram rendering | DIAGRAM_GENERATOR uses builders and renderer |
| simple_xml | Parse ECF and POM files | ECF_PROJECT_PARSER, MAVEN_PROJECT_PARSER |
| simple_json | Parse package.json, output | NPM_PROJECT_PARSER, JSON output mode |
| simple_yaml | Parse YAML configs | GENERIC_PROJECT_PARSER, config loading |
| simple_file | File system operations | All parsers, output writing |
| simple_cli | Argument parsing | ARCHVIZ_CLI command routing |
| simple_config | Settings management | ARCHVIZ_CONFIG load/save/merge |
| simple_logger | Logging infrastructure | All components for diagnostics |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_toml | Parse TOML configs | Python pyproject.toml parsing |
| simple_watcher | File change detection | Watch mode (`archviz watch`) |
| simple_template | HTML report generation | HTML output format |
| simple_diff | Architecture diffing | Diff command (`archviz diff`) |
| simple_cache | Cache parsed results | Large projects, repeat runs |
| simple_eiffel_parser | Deep Eiffel analysis | Class-level Eiffel diagrams |

## Integration Patterns

### simple_graphviz Integration

**Purpose:** Core diagram generation - DOT building and rendering to output formats.

**Usage:**
```eiffel
-- Creating a dependency diagram
generate_dependency_diagram (a_deps: DEPENDENCY_MAP): GRAPHVIZ_RESULT
    local
        l_gv: SIMPLE_GRAPHVIZ
        l_builder: DEPENDENCY_BUILDER
    do
        create l_gv.make
        l_builder := l_gv.dependency_graph

        -- Configure diagram
        l_builder.set_title (project_name + " - Dependencies")

        -- Add internal dependencies
        across a_deps.internal as ic loop
            l_builder.add_library (ic.name, False)
            across ic.depends_on as dep loop
                l_builder.add_dependency (ic.name, dep)
            end
        end

        -- Add external dependencies (if configured)
        if config.include_externals then
            across a_deps.external as ic loop
                l_builder.add_library (ic.name, True)
                across ic.depends_on as dep loop
                    l_builder.add_dependency (ic.name, dep)
                end
            end
        end

        -- Render to file
        Result := l_builder.to_svg_file (output_path)
    end
```

**Data flow:**
```
DEPENDENCY_MAP --> DEPENDENCY_BUILDER --> DOT string --> GRAPHVIZ_RENDERER --> SVG/PDF/PNG
```

### simple_xml Integration

**Purpose:** Parse XML-based configuration files (ECF, POM).

**Usage:**
```eiffel
-- Parsing an Eiffel ECF file
parse_ecf_file (a_path: STRING): ECF_PROJECT
    local
        l_xml: SIMPLE_XML
        l_doc: SIMPLE_XML_DOCUMENT
    do
        create l_xml.make
        l_doc := l_xml.parse_file (a_path)

        if l_doc.is_valid then
            create Result.make

            -- Extract system name
            if attached l_doc.root as root then
                Result.set_name (root.attr ("name"))

                -- Extract targets
                across root.elements ("target") as target loop
                    Result.add_target (parse_target (target))
                end
            end
        end
    end
```

**Data flow:**
```
ECF file --> SIMPLE_XML --> SIMPLE_XML_DOCUMENT --> ECF_PROJECT model
```

### simple_json Integration

**Purpose:** Parse JSON manifests (package.json), provide JSON output mode.

**Usage:**
```eiffel
-- Parsing NPM package.json
parse_package_json (a_path: STRING): NPM_PROJECT
    local
        l_json: SIMPLE_JSON
        l_obj: JSON_OBJECT
    do
        create l_json.make
        l_obj := l_json.parse_file (a_path)

        create Result.make
        Result.set_name (l_obj.string_item ("name"))
        Result.set_version (l_obj.string_item ("version"))

        -- Parse dependencies
        if attached l_obj.object_item ("dependencies") as deps then
            across deps.keys as key loop
                Result.add_dependency (key, deps.string_item (key))
            end
        end

        -- Parse devDependencies
        if attached l_obj.object_item ("devDependencies") as deps then
            across deps.keys as key loop
                Result.add_dev_dependency (key, deps.string_item (key))
            end
        end
    end
```

**Data flow:**
```
package.json --> SIMPLE_JSON --> JSON_OBJECT --> NPM_PROJECT model
```

### simple_cli Integration

**Purpose:** Command-line argument parsing and routing.

**Usage:**
```eiffel
-- CLI setup
setup_cli: SIMPLE_CLI
    do
        create Result.make ("archviz", "Architecture Visualization Tool")

        -- Add generate command
        Result.add_command ("generate", "Generate architecture diagrams")
            .add_option ("-p", "--project", "Project directory", ".")
            .add_option ("-o", "--output", "Output directory", "./archviz-out")
            .add_option ("-f", "--format", "Output format", "svg")
            .add_option ("-t", "--type", "Diagram type", "all")
            .add_flag ("-v", "--verbose", "Verbose output")
            .add_flag ("--no-externals", "Exclude external deps")

        -- Add analyze command
        Result.add_command ("analyze", "Analyze project structure")
            .add_option ("-p", "--project", "Project directory", ".")
            .add_flag ("--json", "Output as JSON")

        -- Add diff command
        Result.add_command ("diff", "Compare architectures")
            .add_argument ("range", "Commit range (e.g., main..feature)")
            .add_option ("-o", "--output", "Output directory")
    end
```

**Data flow:**
```
Command-line args --> SIMPLE_CLI --> Parsed command + options --> Route to handler
```

### simple_config Integration

**Purpose:** Load, validate, and merge configuration from multiple sources.

**Usage:**
```eiffel
-- Load configuration with defaults
load_configuration (a_config_path: detachable STRING): ARCHVIZ_CONFIG
    local
        l_config: SIMPLE_CONFIG
    do
        create l_config.make

        -- Set defaults
        l_config.set_default ("output.directory", "./archviz-out")
        l_config.set_default ("output.format", "svg")
        l_config.set_default ("diagrams.dependencies.enabled", True)
        l_config.set_default ("diagrams.dependencies.max_depth", 3)

        -- Load from file if provided
        if attached a_config_path as path then
            l_config.load_yaml (path)
        elseif l_config.file_exists (".archviz.yaml") then
            l_config.load_yaml (".archviz.yaml")
        end

        -- Create typed config object
        create Result.make_from_config (l_config)
    end
```

**Data flow:**
```
.archviz.yaml + CLI args + defaults --> SIMPLE_CONFIG --> ARCHVIZ_CONFIG object
```

## Dependency Graph

```
archviz
    |
    +-- simple_graphviz (REQUIRED)
    |       |
    |       +-- simple_mml
    |       +-- simple_process
    |
    +-- simple_xml (REQUIRED)
    |
    +-- simple_json (REQUIRED)
    |
    +-- simple_yaml (REQUIRED)
    |
    +-- simple_file (REQUIRED)
    |
    +-- simple_cli (REQUIRED)
    |
    +-- simple_config (REQUIRED)
    |
    +-- simple_logger (REQUIRED)
    |
    +-- simple_toml (optional - Python projects)
    |
    +-- simple_watcher (optional - watch mode)
    |
    +-- simple_template (optional - HTML output)
    |
    +-- simple_diff (optional - diff command)
    |
    +-- simple_cache (optional - performance)
    |
    +-- simple_eiffel_parser (optional - deep Eiffel analysis)
    |
    +-- ISE base (REQUIRED)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="archviz" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0">
    <target name="archviz">
        <root class="ARCHVIZ_CLI" feature="make"/>

        <option warning="true" void_safety="all">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>

        <!-- Required simple_* libraries -->
        <library name="simple_graphviz" location="$SIMPLE_EIFFEL\simple_graphviz\simple_graphviz.ecf"/>
        <library name="simple_xml" location="$SIMPLE_EIFFEL\simple_xml\simple_xml.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_yaml" location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
        <library name="simple_config" location="$SIMPLE_EIFFEL\simple_config\simple_config.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL\simple_logger\simple_logger.ecf"/>

        <!-- Optional libraries (uncomment as needed) -->
        <!-- <library name="simple_toml" location="$SIMPLE_EIFFEL\simple_toml\simple_toml.ecf"/> -->
        <!-- <library name="simple_watcher" location="$SIMPLE_EIFFEL\simple_watcher\simple_watcher.ecf"/> -->
        <!-- <library name="simple_template" location="$SIMPLE_EIFFEL\simple_template\simple_template.ecf"/> -->
        <!-- <library name="simple_diff" location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/> -->
        <!-- <library name="simple_cache" location="$SIMPLE_EIFFEL\simple_cache\simple_cache.ecf"/> -->
        <!-- <library name="simple_eiffel_parser" location="$SIMPLE_EIFFEL\simple_eiffel_parser\simple_eiffel_parser.ecf"/> -->

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
        <library name="time" location="$ISE_LIBRARY\library\time\time.ecf"/>
    </target>

    <!-- Test target -->
    <target name="archviz_tests" extends="archviz">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

    <!-- CLI executable target -->
    <target name="archviz_cli" extends="archviz">
        <root class="ARCHVIZ_CLI" feature="make"/>
        <setting name="executable_name" value="archviz"/>
    </target>
</system>
```
