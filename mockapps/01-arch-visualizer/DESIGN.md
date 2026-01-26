# ArchViz - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                          ARCHVIZ                                  |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - ARCHVIZ_CLI: Argument parsing, command routing               |
|    - ARCHVIZ_COMMANDS: Command implementations                    |
|    - ARCHVIZ_OUTPUT: Output formatting (text, JSON, quiet)        |
+------------------------------------------------------------------+
|  Business Logic Layer                                             |
|    - ARCHVIZ_ENGINE: Orchestrates parsing and generation          |
|    - PROJECT_ANALYZER: Detects project type, gathers metadata     |
|    - DIAGRAM_GENERATOR: Creates appropriate diagram types         |
|    - VIEW_COMPOSER: Combines multiple diagrams into views         |
+------------------------------------------------------------------+
|  Parser Layer                                                     |
|    - ECF_PROJECT_PARSER: Eiffel .ecf files                        |
|    - NPM_PROJECT_PARSER: package.json                             |
|    - MAVEN_PROJECT_PARSER: pom.xml                                |
|    - PYTHON_PROJECT_PARSER: requirements.txt, pyproject.toml      |
|    - GENERIC_PROJECT_PARSER: YAML/JSON dependency definitions     |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_graphviz: DOT generation and rendering                |
|    - simple_xml: XML config file parsing                          |
|    - simple_json: JSON manifest parsing                           |
|    - simple_yaml: YAML config parsing                             |
|    - simple_file: File system operations                          |
|    - simple_config: Settings management                           |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| ARCHVIZ_CLI | Command-line interface | parse_args, route_command, format_output |
| ARCHVIZ_ENGINE | Core orchestration | analyze_project, generate_diagrams, compose_views |
| ARCHVIZ_CONFIG | Configuration management | load_config, validate, merge_defaults |
| PROJECT_ANALYZER | Project detection | detect_type, gather_dependencies, extract_modules |
| DIAGRAM_GENERATOR | Diagram creation | dependency_diagram, hierarchy_diagram, module_diagram |
| VIEW_COMPOSER | Multi-diagram views | create_overview, create_detail_view, create_diff_view |
| ECF_PROJECT_PARSER | Eiffel project parsing | parse_ecf, extract_clusters, extract_libraries |
| NPM_PROJECT_PARSER | NPM project parsing | parse_package_json, resolve_dependencies |
| MAVEN_PROJECT_PARSER | Maven project parsing | parse_pom, resolve_artifacts |
| PYTHON_PROJECT_PARSER | Python project parsing | parse_requirements, parse_pyproject |
| GENERIC_PROJECT_PARSER | Generic parsing | parse_yaml, parse_json |
| ARCHVIZ_REPORTER | Output generation | to_svg, to_pdf, to_png, to_html |

### Command Structure

```bash
archviz <command> [options] [arguments]

Commands:
  generate    Generate architecture diagrams from project files
  analyze     Analyze project structure without generating diagrams
  diff        Compare architecture between two commits/branches
  watch       Watch for changes and regenerate diagrams
  init        Initialize archviz configuration for a project
  version     Show version information
  help        Show help for a command

Generate Options:
  -p, --project <path>    Project root directory (default: current)
  -o, --output <dir>      Output directory for diagrams (default: ./archviz-out)
  -f, --format <fmt>      Output format: svg, pdf, png, all (default: svg)
  -t, --type <type>       Diagram type: deps, hierarchy, modules, all (default: all)
  -c, --config <file>     Configuration file (default: .archviz.yaml)
  --engine <engine>       GraphViz layout engine: dot, neato, fdp (default: dot)
  --title <title>         Custom diagram title
  --no-externals          Exclude external dependencies
  --depth <n>             Maximum dependency depth (default: unlimited)

Global Options:
  -v, --verbose           Verbose output
  -q, --quiet             Quiet mode (errors only)
  --json                  Output results as JSON
  --help                  Show help

Examples:
  archviz generate -p ./my-project -o ./docs/architecture
  archviz generate -t deps -f pdf --no-externals
  archviz diff main..feature/new-module -o ./diff-report
  archviz watch -p ./src -o ./docs/live
  archviz analyze -p . --json
```

### Data Flow

```
Input Sources                    Processing                      Output
+-------------+                 +-----------+                 +----------+
| ECF files   |--+              |           |                 | SVG      |
+-------------+  |              |  PROJECT  |                 +----------+
| package.json|--+-->  parse -->| ANALYZER  |--> DOT model -->| PDF      |
+-------------+  |              |           |                 +----------+
| pom.xml     |--+              +-----------+                 | PNG      |
+-------------+  |                   |                        +----------+
| YAML/JSON   |--+                   v                        | HTML     |
+-------------+               +-------------+                 +----------+
                              |   DIAGRAM   |
                              |  GENERATOR  |
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
# .archviz.yaml
archviz:
  version: 1

  # Project settings
  project:
    name: "My Application"
    type: auto  # auto, eiffel, npm, maven, python, generic
    root: "."

  # Output settings
  output:
    directory: "./docs/architecture"
    formats:
      - svg
      - pdf
    engine: dot

  # Diagram settings
  diagrams:
    dependencies:
      enabled: true
      include_externals: false
      max_depth: 3
      group_by: cluster  # cluster, module, none

    hierarchy:
      enabled: true
      show_features: false
      hide_inherited: true

    modules:
      enabled: true
      granularity: package  # package, file, class

  # Styling
  style:
    theme: default  # default, dark, minimal, corporate
    colors:
      internal: "#4A90D9"
      external: "#7B8794"
      highlight: "#F5A623"
    font:
      family: "Arial"
      size: 12

  # Filtering
  filters:
    include:
      - "src/**"
      - "lib/**"
    exclude:
      - "**/test/**"
      - "**/vendor/**"
      - "node_modules/**"
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Project not found | Exit with code 1 | "Error: Project directory not found: {path}" |
| Unknown project type | Exit with code 1 | "Error: Could not detect project type. Use --type to specify." |
| Parse error | Exit with code 2 | "Error: Failed to parse {file}: {details}" |
| GraphViz not available | Fallback to DOT only | "Warning: GraphViz not installed. Generating DOT files only." |
| Permission denied | Exit with code 3 | "Error: Cannot write to {path}. Check permissions." |
| Config invalid | Exit with code 4 | "Error: Invalid configuration: {details}" |
| Timeout | Exit with code 5 | "Error: Diagram generation timed out. Try reducing depth." |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Web Dashboard (GUI)**
   - REST API wrapper around CLI commands
   - Diagram history and versioning
   - Side-by-side diff visualization
   - Team collaboration features
   - Webhook integration for auto-updates

2. **Interactive Explorer (TUI)**
   - Navigate dependency tree interactively
   - Drill down into modules
   - Highlight specific paths
   - Real-time watch mode with updates

3. **IDE Integration**
   - VS Code extension calling CLI
   - EiffelStudio plugin
   - IntelliJ plugin
   - Diagram preview pane

**Shared components between CLI/GUI:**
- ARCHVIZ_ENGINE (core logic)
- All parsers
- DIAGRAM_GENERATOR
- Configuration handling
- Error handling

**What changes for GUI/TUI:**
- Input: HTTP requests / keyboard events instead of command args
- Output: JSON/WebSocket instead of file writes
- State: Persistent session instead of one-shot execution
