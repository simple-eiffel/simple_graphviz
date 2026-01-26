# PipeDoc - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_graphviz | Core diagram rendering | WORKFLOW_DIAGRAM_GENERATOR uses flowchart and state_machine builders |
| simple_yaml | Parse all pipeline YAML | All platform parsers |
| simple_json | JSON config, output mode | PIPEDOC_CONFIG, JSON output |
| simple_file | File system operations | Pipeline detection, output writing |
| simple_cli | Argument parsing | PIPEDOC_CLI command routing |
| simple_config | Settings management | PIPEDOC_CONFIG load/save/merge |
| simple_logger | Logging infrastructure | All components for diagnostics |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_watcher | File change detection | Watch mode (`pipedoc watch`) |
| simple_template | HTML report generation | HTML output format |
| simple_toml | TOML config files | Alternative config format |
| simple_diff | Pipeline comparison | Compare command |
| simple_cache | Cache parsed results | Large multi-workflow projects |
| simple_http | API calls | Real-time status overlay |

## Integration Patterns

### simple_graphviz Integration

**Purpose:** Generate workflow diagrams using flowchart and state machine builders.

**Usage:**
```eiffel
-- Creating a workflow diagram
generate_workflow_diagram (a_workflow: PIPELINE_WORKFLOW): GRAPHVIZ_RESULT
    local
        l_gv: SIMPLE_GRAPHVIZ
        l_fc: FLOWCHART_BUILDER
        l_job: PIPELINE_JOB
    do
        create l_gv.make
        l_fc := l_gv.flowchart

        -- Add workflow trigger as start
        l_fc := l_fc.start (format_trigger (a_workflow.trigger))

        -- Add jobs grouped by stage
        across a_workflow.stages as stage loop
            l_fc := l_fc.process (stage.name)

            across stage.jobs as job loop
                l_job := job

                -- Add job node with conditional styling
                if l_job.has_condition then
                    l_fc := l_fc.decision (l_job.name, "run", "skip")
                else
                    l_fc := l_fc.process (l_job.name)
                end
            end
        end

        -- Render to file
        Result := l_fc.to_svg_file (output_path)
    end
```

**Data flow:**
```
PIPELINE_WORKFLOW --> FLOWCHART_BUILDER --> DOT string --> GRAPHVIZ_RENDERER --> SVG/PDF/PNG
```

### simple_yaml Integration

**Purpose:** Parse YAML pipeline definitions from all supported platforms.

**Usage:**
```eiffel
-- Parsing GitHub Actions workflow
parse_github_workflow (a_path: STRING): PIPELINE_WORKFLOW
    local
        l_yaml: SIMPLE_YAML
        l_doc: YAML_DOCUMENT
    do
        create l_yaml.make
        l_doc := l_yaml.parse_file (a_path)

        create Result.make (a_path)
        Result.set_platform (Platform_github)

        -- Extract workflow name
        Result.set_name (l_doc.string_at ("name"))

        -- Extract trigger events
        if attached l_doc.value_at ("on") as trigger then
            parse_github_trigger (trigger, Result)
        end

        -- Extract jobs
        if attached l_doc.mapping_at ("jobs") as jobs then
            across jobs.keys as key loop
                Result.add_job (parse_github_job (key, jobs.value_at (key)))
            end
        end
    end

-- Parsing GitLab CI
parse_gitlab_ci (a_path: STRING): PIPELINE_WORKFLOW
    local
        l_yaml: SIMPLE_YAML
        l_doc: YAML_DOCUMENT
    do
        create l_yaml.make
        l_doc := l_yaml.parse_file (a_path)

        create Result.make (a_path)
        Result.set_platform (Platform_gitlab)

        -- Extract stages
        if attached l_doc.sequence_at ("stages") as stages then
            across stages as stage loop
                Result.add_stage (stage.as_string)
            end
        end

        -- Extract jobs (everything else that's not a keyword)
        across l_doc.keys as key loop
            if not is_gitlab_keyword (key) then
                Result.add_job (parse_gitlab_job (key, l_doc.mapping_at (key)))
            end
        end
    end
```

**Data flow:**
```
workflow.yml --> SIMPLE_YAML --> YAML_DOCUMENT --> PIPELINE_WORKFLOW model
```

### simple_cli Integration

**Purpose:** Command-line argument parsing and routing.

**Usage:**
```eiffel
-- CLI setup
setup_cli: SIMPLE_CLI
    do
        create Result.make ("pipedoc", "Pipeline Documentation Generator")

        -- Add generate command
        Result.add_command ("generate", "Generate pipeline diagrams")
            .add_option ("-p", "--path", "Pipeline file or directory", ".")
            .add_option ("-o", "--output", "Output directory", "./pipedoc-out")
            .add_option ("-f", "--format", "Output format", "svg")
            .add_option ("-s", "--style", "Diagram style", "full")
            .add_option ("--platform", "Force platform", "")
            .add_flag ("--include-steps", "Include job steps")
            .add_flag ("--show-conditions", "Show conditions")
            .add_option ("--highlight", "Highlight job", "")

        -- Add analyze command
        Result.add_command ("analyze", "Analyze pipeline structure")
            .add_option ("-p", "--path", "Pipeline file or directory", ".")
            .add_flag ("--json", "Output as JSON")

        -- Add watch command
        Result.add_command ("watch", "Watch and regenerate")
            .add_option ("-p", "--path", "Pipeline file or directory", ".")
            .add_option ("-o", "--output", "Output directory", "./pipedoc-out")

        -- Add compare command
        Result.add_command ("compare", "Compare pipelines")
            .add_argument ("base", "Base reference")
            .add_argument ("compare", "Compare reference")
            .add_option ("-o", "--output", "Output directory")

        -- Add list command
        Result.add_command ("list", "List detected pipelines")
            .add_option ("-p", "--path", "Search directory", ".")
    end
```

### simple_watcher Integration

**Purpose:** Monitor pipeline files for changes and auto-regenerate diagrams.

**Usage:**
```eiffel
-- Watch mode implementation
run_watch_mode (a_path, a_output: STRING)
    local
        l_watcher: SIMPLE_WATCHER
        l_patterns: ARRAYED_LIST [STRING]
    do
        create l_watcher.make

        -- Configure watch patterns for all supported platforms
        create l_patterns.make (5)
        l_patterns.extend (".github/workflows/*.yml")
        l_patterns.extend (".github/workflows/*.yaml")
        l_patterns.extend (".gitlab-ci.yml")
        l_patterns.extend ("azure-pipelines.yml")
        l_patterns.extend (".circleci/config.yml")
        l_patterns.extend ("Jenkinsfile")

        l_watcher.set_patterns (l_patterns)
        l_watcher.set_debounce_ms (500)

        -- Set callback
        l_watcher.on_change (agent handle_file_change (?, a_output))

        -- Start watching
        log.info ("Watching for pipeline changes...")
        l_watcher.start (a_path)
    end

handle_file_change (a_file: STRING; a_output: STRING)
    do
        log.info ("Change detected: " + a_file)
        regenerate_diagram (a_file, a_output)
    end
```

## Dependency Graph

```
pipedoc
    |
    +-- simple_graphviz (REQUIRED)
    |       |
    |       +-- simple_mml
    |       +-- simple_process
    |
    +-- simple_yaml (REQUIRED)
    |
    +-- simple_json (REQUIRED)
    |
    +-- simple_file (REQUIRED)
    |
    +-- simple_cli (REQUIRED)
    |
    +-- simple_config (REQUIRED)
    |
    +-- simple_logger (REQUIRED)
    |
    +-- simple_watcher (optional - watch mode)
    |
    +-- simple_template (optional - HTML output)
    |
    +-- simple_toml (optional - TOML config)
    |
    +-- simple_diff (optional - compare command)
    |
    +-- simple_cache (optional - performance)
    |
    +-- simple_http (optional - API status)
    |
    +-- ISE base (REQUIRED)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="pipedoc" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0">
    <target name="pipedoc">
        <root class="PIPEDOC_ENGINE" feature="default_create"/>

        <option warning="true" void_safety="all">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>

        <!-- Required simple_* libraries -->
        <library name="simple_graphviz" location="$SIMPLE_EIFFEL\simple_graphviz\simple_graphviz.ecf"/>
        <library name="simple_yaml" location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
        <library name="simple_config" location="$SIMPLE_EIFFEL\simple_config\simple_config.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL\simple_logger\simple_logger.ecf"/>

        <!-- Optional libraries (uncomment as needed) -->
        <!-- <library name="simple_watcher" location="$SIMPLE_EIFFEL\simple_watcher\simple_watcher.ecf"/> -->
        <!-- <library name="simple_template" location="$SIMPLE_EIFFEL\simple_template\simple_template.ecf"/> -->
        <!-- <library name="simple_toml" location="$SIMPLE_EIFFEL\simple_toml\simple_toml.ecf"/> -->
        <!-- <library name="simple_diff" location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/> -->
        <!-- <library name="simple_cache" location="$SIMPLE_EIFFEL\simple_cache\simple_cache.ecf"/> -->
        <!-- <library name="simple_http" location="$SIMPLE_EIFFEL\simple_http\simple_http.ecf"/> -->

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
        <library name="time" location="$ISE_LIBRARY\library\time\time.ecf"/>
    </target>

    <!-- Test target -->
    <target name="pipedoc_tests" extends="pipedoc">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

    <!-- CLI executable target -->
    <target name="pipedoc_cli" extends="pipedoc">
        <root class="PIPEDOC_CLI" feature="make"/>
        <setting name="executable_name" value="pipedoc"/>
    </target>
</system>
```
