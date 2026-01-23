# Implementation Approach: simple_graphviz

## Overview

A general-purpose GraphViz library for Eiffel using CLI subprocess execution.

## Architecture Summary

```
SIMPLE_GRAPHVIZ (Facade)
    │
    ├── Builders (BON, Flowchart, State Machine, Dependency, Inheritance)
    │       │
    │       └── DOT Core (DOT_GRAPH, DOT_NODE, DOT_EDGE, DOT_SUBGRAPH, DOT_ATTRIBUTES)
    │               │
    │               └── to_dot → String
    │
    └── GRAPHVIZ_RENDERER
            │
            ├── subprocess: dot -T{format} -o {output}
            └── GRAPHVIZ_RESULT (is_success, content, error)
```

## Phase 1 Complete (Contracts + Skeletal Tests)

### Core Classes (6)
- **DOT_ATTRIBUTES**: Key-value pairs with DOT escaping. MML model query `attributes_model`.
- **DOT_NODE**: Node with id and attributes. Fluent setters for 20 common attributes.
- **DOT_EDGE**: Edge between nodes. Fluent setters for 15 common attributes.
- **DOT_SUBGRAPH**: Cluster grouping with `cluster_` prefix convention.
- **DOT_GRAPH**: Complete graph structure. MML models for nodes, edges, subgraphs.
- **GRAPHVIZ_STYLE**: Visual presets (BON, UML, minimal).

### Rendering (3)
- **GRAPHVIZ_RENDERER**: Subprocess execution engine. Configurable timeout and engine.
- **GRAPHVIZ_RESULT**: Result object with success/content/error XOR invariant.
- **GRAPHVIZ_ERROR**: Error codes enum (graphviz_not_found, timeout, invalid_dot, etc.)

### Builders (5)
- **BON_DIAGRAM_BUILDER**: Eiffel BON class diagrams with ellipse shapes.
- **FLOWCHART_BUILDER**: Process flowcharts with auto-linking and decision branches.
- **STATE_MACHINE_BUILDER**: State machines with initial/final states and transitions.
- **DEPENDENCY_BUILDER**: Library dependency graphs with clustering.
- **INHERITANCE_BUILDER**: Class inheritance trees with root filtering.

### Facade (1)
- **SIMPLE_GRAPHVIZ**: Main entry point with builder access and engine/timeout configuration.

## Implementation Strategy (Phase 4)

### Priority Order

1. **DOT Core** (no dependencies)
   - `DOT_ATTRIBUTES.to_dot` - already implemented
   - `DOT_NODE.to_dot` - already implemented
   - `DOT_EDGE.to_dot` - already implemented
   - `DOT_GRAPH.to_dot` - already implemented

2. **GRAPHVIZ_RENDERER** (depends on simple_process)
   - `is_graphviz_available` - execute `dot -V`, check exit code
   - `graphviz_version` - parse `dot -V` output
   - `render` - write temp DOT file, execute GraphViz, read output
   - `render_to_file` - direct output to file

3. **Builders** (depend on DOT Core)
   - All builders already construct valid DOT graphs
   - `from_file`/`from_directory` require simple_eiffel_parser (Phase 4)
   - `from_ecf` requires simple_xml (Phase 4)

### Key Implementation Details

#### GRAPHVIZ_RENDERER.render
```
1. Check is_graphviz_available
2. Write a_dot to temp file (PROCESS_TEMP.create_temp_file)
3. Build command: "{engine} -T{format} {temp_input} -o {temp_output}"
4. Execute via SIMPLE_PROCESS with timeout
5. If exit_code = 0:
   - Read temp_output into STRING
   - Return make_success (content)
6. Else:
   - Parse stderr for error type
   - Return make_failure (GRAPHVIZ_ERROR)
7. Cleanup temp files
```

#### DOT Escaping
Already implemented in `DOT_ATTRIBUTES.escape_value`:
- Quotes strings with spaces, quotes, special chars
- Escapes internal quotes as `\"`
- Escapes backslashes as `\\`
- Escapes newlines as `\n`

#### Fluent API Pattern
All setters return `like Current` for chaining:
```eiffel
l_builder := l_builder.start("Begin").process("Step").end_node("Done")
```

When not consuming the result, use `.do_nothing`:
```eiffel
a_node.set_shape (class_shape).do_nothing
```

### Dependencies

| Library | Usage |
|---------|-------|
| simple_process | Subprocess execution for GraphViz CLI |
| simple_file | Temp file creation and I/O |
| simple_eiffel_parser | Parse .e files for BON/Inheritance builders |
| simple_xml | Parse .ecf files for Dependency builder |
| simple_mml | MML postconditions (already used) |

### Testing Strategy

- **35 skeletal tests** already created
- Unit tests for DOT serialization (valid DOT output)
- Integration tests with GraphViz (render small graphs)
- Error handling tests (missing GraphViz, invalid DOT, timeout)
- SCOOP consumer test (verify concurrent safety)

## Open Questions for Review

1. **Timeout handling**: Should timeout use SCOOP's `{EXECUTION_ENVIRONMENT}.sleep` or simple_process's native timeout?

2. **Temp file location**: Use system temp directory or project-relative `.tmp/`?

3. **Error message detail**: Should `invalid_dot` error include GraphViz's stderr verbatim or summarize?

4. **Builder validation**: Should builders validate graph structure before `to_dot`, or let GraphViz report errors?

5. **MML completeness**: Are frame conditions sufficient for all collection operations?
