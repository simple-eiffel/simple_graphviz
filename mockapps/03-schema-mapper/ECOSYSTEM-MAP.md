# SchemaMap - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_graphviz | Core diagram rendering | ER_DIAGRAM_GENERATOR uses custom DOT building |
| simple_sql | Database connectivity | All database extractors |
| simple_json | Metadata storage, output | SCHEMAMAP_CONFIG, JSON export |
| simple_file | File system operations | DDL parsing, output writing |
| simple_cli | Argument parsing | SCHEMAMAP_CLI command routing |
| simple_config | Settings management | Connection storage, preferences |
| simple_logger | Logging infrastructure | All components for diagnostics |
| simple_csv | Data export | CSV schema export |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_template | HTML report generation | HTML output format |
| simple_diff | Schema comparison | Compare command |
| simple_cache | Cache schema metadata | Large databases, repeat runs |
| simple_validation | DDL validation | Validate command |
| simple_encryption | Credential encryption | Secure connection storage |
| simple_watcher | DDL file monitoring | Watch mode |

## Integration Patterns

### simple_graphviz Integration

**Purpose:** Generate ER diagrams with custom DOT structures for table representation.

**Usage:**
```eiffel
-- Creating an ER diagram
generate_er_diagram (a_schema: SCHEMA_MODEL): GRAPHVIZ_RESULT
    local
        l_gv: SIMPLE_GRAPHVIZ
        l_graph: DOT_GRAPH
        l_table_node: DOT_NODE
        l_fk_edge: DOT_EDGE
        l_label: STRING
    do
        create l_gv.make
        l_graph := l_gv.graph

        -- Configure for ER diagram layout
        l_graph.attributes.put ("rankdir", "LR")
        l_graph.attributes.put ("splines", "ortho")
        l_graph.attributes.put ("nodesep", "1.0")

        -- Add tables as record-style nodes
        across a_schema.tables as table loop
            l_label := build_table_label (table)

            l_table_node := l_graph.new_node (table.name)
            l_table_node.attributes.put ("shape", "record")
            l_table_node.attributes.put ("label", l_label)
            l_table_node.attributes.put ("fontname", "Courier")

            -- Style based on table type
            if table.is_junction_table then
                l_table_node.attributes.put ("fillcolor", "#E0E0E0")
            else
                l_table_node.attributes.put ("fillcolor", "#FFFFFF")
            end
        end

        -- Add relationships
        across a_schema.relationships as rel loop
            l_fk_edge := l_graph.new_edge (rel.from_table, rel.to_table)
            l_fk_edge.attributes.put ("label", rel.from_column + " -> " + rel.to_column)

            -- Show cardinality
            if rel.is_one_to_many then
                l_fk_edge.attributes.put ("arrowhead", "crow")
            else
                l_fk_edge.attributes.put ("arrowhead", "normal")
            end
        end

        -- Render to file
        Result := l_gv.render_svg (l_graph.to_dot)
    end

build_table_label (a_table: TABLE_MODEL): STRING
        -- Build GraphViz record label for table.
    do
        create Result.make (200)
        Result.append ("{")
        Result.append (a_table.name)
        Result.append ("|")

        -- Add columns
        across a_table.columns as col loop
            if col.is_primary_key then
                Result.append ("<pk> ")
            elseif col.is_foreign_key then
                Result.append ("<fk> ")
            end
            Result.append (col.name)
            Result.append (" : ")
            Result.append (col.data_type)
            if not col.is_nullable then
                Result.append (" NOT NULL")
            end
            Result.append ("\l")  -- Left-align in record
        end

        Result.append ("}")
    end
```

**Data flow:**
```
SCHEMA_MODEL --> DOT_GRAPH (record nodes) --> DOT string --> GRAPHVIZ_RENDERER --> SVG/PDF/PNG
```

### simple_sql Integration

**Purpose:** Connect to databases and extract schema metadata.

**Usage:**
```eiffel
-- Extracting PostgreSQL schema
extract_postgresql_schema (a_connection: SQL_CONNECTION): SCHEMA_MODEL
    local
        l_sql: SIMPLE_SQL
        l_tables_query: STRING
        l_columns_query: STRING
        l_fk_query: STRING
        l_result: SQL_RESULT
    do
        create Result.make

        -- Query tables
        l_tables_query := "[
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = $1
              AND table_type = 'BASE TABLE'
            ORDER BY table_name
        ]"

        l_result := a_connection.execute (l_tables_query, <<schema_name>>)
        across l_result as row loop
            Result.add_table (create_table_model (row.string ("table_name")))
        end

        -- Query columns for each table
        l_columns_query := "[
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns
            WHERE table_schema = $1 AND table_name = $2
            ORDER BY ordinal_position
        ]"

        across Result.tables as table loop
            l_result := a_connection.execute (l_columns_query, <<schema_name, table.name>>)
            across l_result as row loop
                table.add_column (create_column_model (row))
            end
        end

        -- Query foreign keys
        l_fk_query := "[
            SELECT
                tc.table_name AS from_table,
                kcu.column_name AS from_column,
                ccu.table_name AS to_table,
                ccu.column_name AS to_column
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage ccu
              ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
              AND tc.table_schema = $1
        ]"

        l_result := a_connection.execute (l_fk_query, <<schema_name>>)
        across l_result as row loop
            Result.add_relationship (create_relationship_model (row))
        end
    end
```

**Data flow:**
```
Database --> simple_sql query --> SQL_RESULT --> SCHEMA_MODEL
```

### simple_cli Integration

**Purpose:** Command-line argument parsing and routing.

**Usage:**
```eiffel
-- CLI setup
setup_cli: SIMPLE_CLI
    do
        create Result.make ("schemamap", "Database Schema Visualization")

        -- Add generate command
        Result.add_command ("generate", "Generate ER diagrams")
            .add_option ("-c", "--connection", "Named connection", "")
            .add_option ("-u", "--url", "Database URL", "")
            .add_option ("-d", "--ddl", "DDL file or directory", "")
            .add_option ("-o", "--output", "Output directory", "./schemamap-out")
            .add_option ("-f", "--format", "Output format", "svg")
            .add_option ("-t", "--tables", "Include tables", "")
            .add_option ("-s", "--schema", "Database schema", "")
            .add_option ("--focus", "Focus table", "")
            .add_option ("--depth", "Traversal depth", "2")
            .add_flag ("--no-columns", "Hide columns")
            .add_flag ("--show-indexes", "Show indexes")
            .add_flag ("--infer-relationships", "Detect implicit FKs")

        -- Add analyze command
        Result.add_command ("analyze", "Analyze schema")
            .add_option ("-c", "--connection", "Named connection", "")
            .add_option ("-u", "--url", "Database URL", "")
            .add_flag ("--json", "Output as JSON")

        -- Add compare command
        Result.add_command ("compare", "Compare schemas")
            .add_option ("--source", "Source connection", "")
            .add_option ("--target", "Target connection", "")
            .add_option ("-o", "--output", "Output directory", "")

        -- Add export command
        Result.add_command ("export", "Export schema")
            .add_option ("-c", "--connection", "Named connection", "")
            .add_option ("-f", "--format", "Export format: ddl, json, csv", "ddl")
            .add_option ("-o", "--output", "Output file", "")

        -- Add connections command
        Result.add_command ("connections", "Manage connections")
            .add_subcommand ("list", "List connections")
            .add_subcommand ("add", "Add connection")
            .add_subcommand ("remove", "Remove connection")
            .add_subcommand ("test", "Test connection")
    end
```

### simple_config Integration

**Purpose:** Manage database connections and application settings securely.

**Usage:**
```eiffel
-- Connection management
save_connection (a_name: STRING; a_url: STRING)
    local
        l_config: SIMPLE_CONFIG
    do
        create l_config.make

        -- Load existing connections
        if l_config.file_exists (".schemamap.yaml") then
            l_config.load_yaml (".schemamap.yaml")
        end

        -- Add/update connection
        l_config.set ("connections." + a_name + ".url", a_url)

        -- Save
        l_config.save_yaml (".schemamap.yaml")
    end

get_connection (a_name: STRING): detachable STRING
    local
        l_config: SIMPLE_CONFIG
        l_url: STRING
    do
        create l_config.make

        if l_config.file_exists (".schemamap.yaml") then
            l_config.load_yaml (".schemamap.yaml")

            -- Get URL, resolving environment variables
            l_url := l_config.string ("connections." + a_name + ".url")

            -- Expand ${VAR} references
            Result := expand_env_vars (l_url)
        end
    end
```

## Dependency Graph

```
schemamap
    |
    +-- simple_graphviz (REQUIRED)
    |       |
    |       +-- simple_mml
    |       +-- simple_process
    |
    +-- simple_sql (REQUIRED)
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
    +-- simple_csv (REQUIRED)
    |
    +-- simple_template (optional - HTML output)
    |
    +-- simple_diff (optional - compare command)
    |
    +-- simple_cache (optional - performance)
    |
    +-- simple_validation (optional - validate command)
    |
    +-- simple_encryption (optional - secure credentials)
    |
    +-- simple_watcher (optional - DDL watch mode)
    |
    +-- ISE base (REQUIRED)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="schemamap" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0">
    <target name="schemamap">
        <root class="SCHEMAMAP_ENGINE" feature="default_create"/>

        <option warning="true" void_safety="all">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>

        <!-- Required simple_* libraries -->
        <library name="simple_graphviz" location="$SIMPLE_EIFFEL\simple_graphviz\simple_graphviz.ecf"/>
        <library name="simple_sql" location="$SIMPLE_EIFFEL\simple_sql\simple_sql.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
        <library name="simple_config" location="$SIMPLE_EIFFEL\simple_config\simple_config.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL\simple_logger\simple_logger.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL\simple_csv\simple_csv.ecf"/>

        <!-- Optional libraries (uncomment as needed) -->
        <!-- <library name="simple_template" location="$SIMPLE_EIFFEL\simple_template\simple_template.ecf"/> -->
        <!-- <library name="simple_diff" location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/> -->
        <!-- <library name="simple_cache" location="$SIMPLE_EIFFEL\simple_cache\simple_cache.ecf"/> -->
        <!-- <library name="simple_validation" location="$SIMPLE_EIFFEL\simple_validation\simple_validation.ecf"/> -->
        <!-- <library name="simple_encryption" location="$SIMPLE_EIFFEL\simple_encryption\simple_encryption.ecf"/> -->
        <!-- <library name="simple_watcher" location="$SIMPLE_EIFFEL\simple_watcher\simple_watcher.ecf"/> -->

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
        <library name="time" location="$ISE_LIBRARY\library\time\time.ecf"/>
    </target>

    <!-- Test target -->
    <target name="schemamap_tests" extends="schemamap">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

    <!-- CLI executable target -->
    <target name="schemamap_cli" extends="schemamap">
        <root class="SCHEMAMAP_CLI" feature="make"/>
        <setting name="executable_name" value="schemamap"/>
    </target>
</system>
```
