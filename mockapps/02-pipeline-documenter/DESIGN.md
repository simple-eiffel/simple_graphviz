# PipeDoc - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                          PIPEDOC                                  |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - PIPEDOC_CLI: Argument parsing, command routing               |
|    - PIPEDOC_COMMANDS: Command implementations                    |
|    - PIPEDOC_OUTPUT: Output formatting (text, JSON, quiet)        |
+------------------------------------------------------------------+
|  Business Logic Layer                                             |
|    - PIPEDOC_ENGINE: Orchestrates parsing and generation          |
|    - PIPELINE_ANALYZER: Detects platform, extracts structure      |
|    - WORKFLOW_DIAGRAM_GENERATOR: Creates workflow visualizations  |
|    - JOB_DETAIL_GENERATOR: Creates detailed job step diagrams     |
|    - DEPENDENCY_EXTRACTOR: Identifies job dependencies            |
+------------------------------------------------------------------+
|  Parser Layer                                                     |
|    - GITHUB_ACTIONS_PARSER: .github/workflows/*.yml               |
|    - GITLAB_CI_PARSER: .gitlab-ci.yml                             |
|    - AZURE_PIPELINES_PARSER: azure-pipelines.yml                  |
|    - JENKINS_PARSER: Jenkinsfile (declarative)                    |
|    - CIRCLECI_PARSER: .circleci/config.yml                        |
|    - GENERIC_PIPELINE_PARSER: Custom YAML definitions             |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_graphviz: DOT generation and rendering                |
|    - simple_yaml: Pipeline YAML parsing                           |
|    - simple_json: JSON config parsing, output                     |
|    - simple_file: File system operations                          |
|    - simple_watcher: Watch mode for live updates                  |
|    - simple_template: Report generation                           |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| PIPEDOC_CLI | Command-line interface | parse_args, route_command, format_output |
| PIPEDOC_ENGINE | Core orchestration | analyze_pipeline, generate_diagrams |
| PIPEDOC_CONFIG | Configuration management | load_config, validate, merge_defaults |
| PIPELINE_ANALYZER | Pipeline detection | detect_platform, extract_workflows, extract_jobs |
| WORKFLOW_DIAGRAM_GENERATOR | Workflow diagrams | create_overview, create_detailed |
| JOB_DETAIL_GENERATOR | Job step diagrams | create_step_diagram, show_conditions |
| DEPENDENCY_EXTRACTOR | Find dependencies | extract_needs, extract_triggers |
| GITHUB_ACTIONS_PARSER | GitHub Actions | parse_workflow, resolve_reusables |
| GITLAB_CI_PARSER | GitLab CI | parse_config, resolve_includes, resolve_extends |
| AZURE_PIPELINES_PARSER | Azure Pipelines | parse_yaml, resolve_templates |
| JENKINS_PARSER | Jenkinsfile | parse_declarative, extract_stages |
| CIRCLECI_PARSER | CircleCI | parse_config, resolve_orbs |
| PIPELINE_MODEL | Universal model | jobs, stages, dependencies, conditions |
| PIPEDOC_REPORTER | Output generation | to_svg, to_pdf, to_png, to_html |

### Command Structure

```bash
pipedoc <command> [options] [arguments]

Commands:
  generate    Generate pipeline diagrams
  analyze     Analyze pipeline structure
  validate    Validate pipeline syntax
  compare     Compare pipelines across branches/repos
  watch       Watch for changes and regenerate
  list        List detected pipelines in project
  help        Show help

Generate Options:
  -p, --path <path>       Pipeline file or directory (default: auto-detect)
  -o, --output <dir>      Output directory (default: ./pipedoc-out)
  -f, --format <fmt>      Output format: svg, pdf, png, html (default: svg)
  -s, --style <style>     Diagram style: full, compact, minimal (default: full)
  --platform <name>       Force platform: github, gitlab, azure, jenkins, circleci
  --include-steps         Include individual steps in diagram
  --show-conditions       Show conditional execution paths
  --highlight <job>       Highlight specific job and its dependencies

Global Options:
  -v, --verbose           Verbose output
  -q, --quiet             Quiet mode (errors only)
  --json                  Output results as JSON
  --color                 Force colored output
  --no-color              Disable colored output
  --help                  Show help

Examples:
  pipedoc generate                           # Auto-detect and generate
  pipedoc generate -p .github/workflows      # GitHub Actions workflows
  pipedoc generate -p .gitlab-ci.yml -f pdf  # GitLab CI to PDF
  pipedoc generate --include-steps           # Show job steps
  pipedoc generate --highlight deploy        # Highlight deploy job
  pipedoc watch -o ./docs/pipeline           # Live regeneration
  pipedoc compare main feature/new-ci        # Compare pipeline versions
  pipedoc list                               # Show detected pipelines
```

### Data Flow

```
Pipeline Sources                Processing                      Output
+-----------------+            +------------+                 +----------+
| .github/        |            |            |                 | SVG      |
|  workflows/*.yml|--+         | PIPELINE   |                 +----------+
+-----------------+  |         | ANALYZER   |                 | PDF      |
| .gitlab-ci.yml  |--+-> parse | (detect,   |--> DOT model -->+----------+
+-----------------+  |         |  extract)  |                 | PNG      |
| azure-pipelines |--+         |            |                 +----------+
|   .yml          |  |         +------------+                 | HTML     |
+-----------------+  |              |                         +----------+
| Jenkinsfile     |--+              v
+-----------------+            +------------+
| .circleci/      |            | WORKFLOW   |
|   config.yml    |            | DIAGRAM    |
+-----------------+            | GENERATOR  |
                               +------------+
                                    |
                                    v
                               +------------+
                               | GRAPHVIZ   |
                               | RENDERER   |
                               +------------+
```

### Configuration Schema

```yaml
# .pipedoc.yaml
pipedoc:
  version: 1

  # Detection settings
  detection:
    auto: true
    paths:
      - .github/workflows
      - .gitlab-ci.yml
      - azure-pipelines.yml
      - Jenkinsfile
      - .circleci/config.yml

  # Output settings
  output:
    directory: "./docs/pipeline"
    formats:
      - svg
      - html
    naming: "{workflow}-{date}"  # Diagram file naming

  # Diagram settings
  diagrams:
    style: full  # full, compact, minimal

    overview:
      enabled: true
      show_triggers: true
      show_conditions: true
      group_by: stage  # stage, runner, none

    detail:
      enabled: true
      include_steps: true
      include_env_vars: false
      max_steps: 20  # Collapse if more than N steps

  # Styling
  style:
    theme: default  # default, dark, github, gitlab
    colors:
      success: "#28A745"
      failure: "#DC3545"
      pending: "#FFC107"
      skipped: "#6C757D"
      running: "#17A2B8"
    shapes:
      job: box
      stage: subgraph
      condition: diamond
      trigger: ellipse

  # Filtering
  filters:
    include_workflows:
      - "*"
    exclude_workflows:
      - "*.disabled.yml"
    include_jobs:
      - "*"
    exclude_jobs:
      - "debug-*"
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| No pipeline found | Exit with code 1 | "Error: No pipeline files detected. Use -p to specify." |
| Invalid YAML | Exit with code 2 | "Error: Invalid YAML in {file}: {line}: {message}" |
| Unsupported platform | Exit with code 3 | "Error: Unknown pipeline format. Use --platform to specify." |
| Circular dependency | Warning, continue | "Warning: Circular dependency detected: {job} -> {job}" |
| Missing reference | Warning, continue | "Warning: Referenced job not found: {job}" |
| GraphViz not available | Fallback to DOT | "Warning: GraphViz not installed. Generating DOT files only." |
| Permission denied | Exit with code 4 | "Error: Cannot write to {path}. Check permissions." |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Web Dashboard (GUI)**
   - Real-time pipeline status overlay
   - Historical run tracking
   - Cross-repo pipeline comparison
   - Team notifications on changes
   - Integration with GitHub/GitLab APIs

2. **Interactive Explorer (TUI)**
   - Navigate job tree
   - Drill down into steps
   - Live status updates
   - Trigger manual runs

3. **IDE Integration**
   - VS Code extension with preview pane
   - Pipeline validation on save
   - Quick navigation to job definitions

**Shared components between CLI/GUI:**
- PIPEDOC_ENGINE (core logic)
- All platform parsers
- WORKFLOW_DIAGRAM_GENERATOR
- Configuration handling
- Error handling

**What changes for GUI/TUI:**
- Input: HTTP requests / keyboard events
- Output: JSON/WebSocket streams
- State: Persistent session with live updates
- Data: Real-time API integration for status
