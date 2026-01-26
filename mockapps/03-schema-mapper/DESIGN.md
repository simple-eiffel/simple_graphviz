# SchemaMap - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                         SCHEMAMAP                                 |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - SCHEMAMAP_CLI: Argument parsing, command routing             |
|    - SCHEMAMAP_COMMANDS: Command implementations                  |
|    - SCHEMAMAP_OUTPUT: Output formatting (text, JSON, quiet)      |
+------------------------------------------------------------------+
|  Business Logic Layer                                             |
|    - SCHEMAMAP_ENGINE: Orchestrates extraction and generation     |
|    - SCHEMA_ANALYZER: Extracts tables, columns, relationships     |
|    - ER_DIAGRAM_GENERATOR: Creates entity-relationship diagrams   |
|    - DATA_FLOW_GENERATOR: Creates data flow visualizations        |
|    - RELATIONSHIP_INFERRER: Detects implicit relationships        |
+------------------------------------------------------------------+
|  Extractor Layer                                                  |
|    - POSTGRESQL_EXTRACTOR: PostgreSQL information_schema          |
|    - MYSQL_EXTRACTOR: MySQL information_schema                    |
|    - SQLITE_EXTRACTOR: SQLite pragma_table_info                   |
|    - SQLSERVER_EXTRACTOR: SQL Server sys.tables                   |
|    - ORACLE_EXTRACTOR: Oracle ALL_TABLES                          |
|    - DDL_PARSER: Parse CREATE TABLE statements                    |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_graphviz: DOT generation and rendering                |
|    - simple_sql: Database connectivity                            |
|    - simple_csv: Data export                                      |
|    - simple_json: Metadata storage, output                        |
|    - simple_file: File system operations                          |
|    - simple_config: Connection/settings management                |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| SCHEMAMAP_CLI | Command-line interface | parse_args, route_command, format_output |
| SCHEMAMAP_ENGINE | Core orchestration | extract_schema, generate_diagrams |
| SCHEMAMAP_CONFIG | Configuration management | load_connections, validate, store_credentials |
| SCHEMA_ANALYZER | Schema extraction | extract_tables, extract_columns, extract_relationships |
| ER_DIAGRAM_GENERATOR | ER diagram creation | create_full, create_filtered, create_focused |
| DATA_FLOW_GENERATOR | Data flow diagrams | trace_references, show_cascades |
| RELATIONSHIP_INFERRER | Detect implicit FKs | infer_by_naming, infer_by_type |
| POSTGRESQL_EXTRACTOR | PostgreSQL extraction | query_information_schema, query_pg_catalog |
| MYSQL_EXTRACTOR | MySQL extraction | query_information_schema |
| SQLITE_EXTRACTOR | SQLite extraction | query_pragma |
| SQLSERVER_EXTRACTOR | SQL Server extraction | query_sys_tables |
| ORACLE_EXTRACTOR | Oracle extraction | query_all_tables |
| DDL_PARSER | DDL file parsing | parse_create_table, parse_alter_table |
| SCHEMA_MODEL | Universal model | tables, columns, foreign_keys, indexes |
| TABLE_MODEL | Table representation | name, columns, primary_key, indexes |
| COLUMN_MODEL | Column representation | name, type, nullable, default |
| RELATIONSHIP_MODEL | FK representation | from_table, from_column, to_table, to_column |

### Command Structure

```bash
schemamap <command> [options] [arguments]

Commands:
  generate    Generate ER diagrams from database or DDL
  analyze     Analyze schema structure
  compare     Compare schemas between sources
  export      Export schema as DDL/JSON/CSV
  connections Manage database connections
  help        Show help

Generate Options:
  -c, --connection <name>   Named connection from config
  -u, --url <url>           Database connection URL
  -d, --ddl <path>          DDL file or directory
  -o, --output <dir>        Output directory (default: ./schemamap-out)
  -f, --format <fmt>        Output format: svg, pdf, png, html (default: svg)
  -t, --tables <list>       Include only these tables (comma-separated)
  -s, --schema <name>       Database schema (default: public/dbo)
  --focus <table>           Center diagram on specific table
  --depth <n>               Relationship traversal depth (default: 2)
  --no-columns              Hide column details
  --show-indexes            Show index information
  --infer-relationships     Detect implicit foreign keys

Global Options:
  -v, --verbose             Verbose output
  -q, --quiet               Quiet mode (errors only)
  --json                    Output results as JSON
  --help                    Show help

Connection URL Format:
  postgresql://user:pass@host:port/database
  mysql://user:pass@host:port/database
  sqlite:///path/to/database.db
  sqlserver://user:pass@host:port/database
  oracle://user:pass@host:port/service

Examples:
  schemamap generate -c production             # Use saved connection
  schemamap generate -u postgresql://...       # Direct URL
  schemamap generate -d ./migrations           # From DDL files
  schemamap generate --focus users --depth 3   # Focus on users table
  schemamap generate -t users,orders,products  # Specific tables only
  schemamap compare -c dev -c staging          # Compare schemas
  schemamap export -c production -f ddl        # Export as DDL
  schemamap connections add prod "postgresql://..."
  schemamap connections list
```

### Data Flow

```
Data Sources                     Processing                      Output
+------------------+            +-------------+                +----------+
| Live Database    |            |             |                | SVG      |
| (via simple_sql) |--+         |   SCHEMA    |                +----------+
+------------------+  |         |   ANALYZER  |                | PDF      |
| DDL Files        |--+-> query |  (extract   |--> DOT model -->+----------+
| (CREATE TABLE)   |  |         |   tables,   |                | PNG      |
+------------------+  |         |   columns,  |                +----------+
| Migration Files  |--+         |   FKs)      |                | HTML     |
| (SQL)            |            |             |                +----------+
+------------------+            +-------------+                | DDL      |
                                     |                         +----------+
                                     v                         | JSON     |
                                +-------------+                +----------+
                                | ER_DIAGRAM  |                | CSV      |
                                | GENERATOR   |                +----------+
                                +-------------+
                                     |
                                     v
                                +-------------+
                                | GRAPHVIZ    |
                                | RENDERER    |
                                +-------------+
```

### Configuration Schema

```yaml
# .schemamap.yaml
schemamap:
  version: 1

  # Named connections (credentials can be env vars)
  connections:
    production:
      url: "${DATABASE_URL}"
      schema: public
    staging:
      url: "postgresql://user:pass@staging.example.com:5432/myapp"
      schema: public
    development:
      url: "sqlite:///./dev.db"

  # Output settings
  output:
    directory: "./docs/schema"
    formats:
      - svg
      - html
    naming: "{database}_{schema}_{date}"

  # Diagram settings
  diagrams:
    style: full  # full, compact, minimal

    er_diagram:
      show_columns: true
      show_types: true
      show_nullable: true
      show_indexes: false
      show_defaults: false
      max_columns: 15  # Collapse if more

    relationships:
      show_explicit: true   # Actual foreign keys
      infer_implicit: true  # Naming convention matches
      show_cardinality: true
      show_on_delete: true

  # Filtering
  filters:
    include_tables:
      - "*"
    exclude_tables:
      - "*_backup"
      - "*_temp"
      - "*_log"
    include_schemas:
      - public
    exclude_schemas:
      - pg_catalog
      - information_schema

  # Styling
  style:
    theme: default  # default, dark, minimal, blueprint
    colors:
      table: "#E8E8E8"
      primary_key: "#FFD700"
      foreign_key: "#4169E1"
      nullable: "#90EE90"
      relationship: "#666666"
    table_style: record  # record, box, html
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Connection failed | Exit with code 1 | "Error: Cannot connect to database: {details}" |
| Invalid URL | Exit with code 1 | "Error: Invalid connection URL format" |
| No tables found | Exit with code 2 | "Error: No tables found in schema '{schema}'" |
| Permission denied | Exit with code 3 | "Error: Access denied for database objects" |
| DDL parse error | Exit with code 4 | "Error: Cannot parse DDL at line {line}: {message}" |
| Timeout | Exit with code 5 | "Error: Query timeout. Large schema - use --tables to filter." |
| GraphViz not available | Fallback to DOT | "Warning: GraphViz not installed. Generating DOT files only." |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Web Dashboard (GUI)**
   - Interactive schema browser
   - Real-time schema change notifications
   - Visual query builder based on relationships
   - Schema diff viewer with history
   - Team collaboration on annotations

2. **Interactive Explorer (TUI)**
   - Navigate table hierarchy
   - View column details
   - Trace relationship paths
   - Quick search across schema

3. **IDE Integration**
   - VS Code extension with schema preview
   - Autocomplete from schema metadata
   - Query validation against live schema
   - Migration preview

**Shared components between CLI/GUI:**
- SCHEMAMAP_ENGINE (core logic)
- All database extractors
- ER_DIAGRAM_GENERATOR
- SCHEMA_MODEL
- Configuration handling

**What changes for GUI/TUI:**
- Input: HTTP requests / keyboard events
- Output: JSON/WebSocket streams
- State: Persistent session with live updates
- Data: Continuous schema monitoring
