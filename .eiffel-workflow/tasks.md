# Implementation Tasks: simple_graphviz

## Overview

15 classes, organized by dependency order:
- **Tier 0**: Already complete (DOT serialization)
- **Tier 1**: GRAPHVIZ_RENDERER (depends on simple_process)
- **Tier 2**: GRAPHVIZ_STYLE application methods (already implemented)
- **Tier 3**: Builder source-parsing features (depend on simple_eiffel_parser, simple_xml)

## Tier 0: DOT Core (COMPLETE - No Implementation Needed)

The following are already fully implemented with working `to_dot` methods:
- DOT_ATTRIBUTES - key/value with escaping
- DOT_NODE - node serialization
- DOT_EDGE - edge serialization with directed/undirected
- DOT_SUBGRAPH - cluster serialization
- DOT_GRAPH - complete graph serialization
- GRAPHVIZ_ERROR - error codes enum
- GRAPHVIZ_RESULT - result object
- GRAPHVIZ_STYLE - style presets and application
- All builders' manual building and `to_dot` methods

**Status**: Contract bodies already filled in Phase 1. Ready to render once GRAPHVIZ_RENDERER is implemented.

---

## Task 1: GRAPHVIZ_RENDERER Core Rendering
**Files:** src/graphviz_renderer.e
**Features:** `is_graphviz_available`, `graphviz_version`, `render`, `render_to_file`

### Acceptance Criteria
- [ ] `is_graphviz_available` executes `dot -V` and returns True if exit code = 0
- [ ] `graphviz_version` parses `dot -V` output to extract version string
- [ ] `render` writes DOT to temp file, executes GraphViz, returns GRAPHVIZ_RESULT
- [ ] `render_to_file` outputs directly to specified path
- [ ] Timeout enforced via simple_process
- [ ] Error types correctly classified (graphviz_not_found, timeout, invalid_dot, etc.)
- [ ] Temp files cleaned up after render
- [ ] Compiles clean with simple_process dependency
- [ ] Unit tests pass for all render variants

### Implementation Notes
From approach.md:
```
1. Check is_graphviz_available
2. Write a_dot to temp file
3. Build command: "{engine} -T{format} {temp_input} -o {temp_output}"
4. Execute via SIMPLE_PROCESS with timeout
5. If exit_code = 0: Read temp_output, return make_success
6. Else: Parse stderr for error type, return make_failure
7. Cleanup temp files
```

### Dependencies
- simple_process (subprocess execution)
- simple_file (temp file I/O) - or use ISE's file classes

---

## Task 2: Add Documentation Notes (C01, C02, C05)
**Files:** src/dot_subgraph.e, src/dot_graph.e, builder classes

### Acceptance Criteria
- [ ] DOT_SUBGRAPH.make_cluster: note that `cluster_` prefix is recommended but not enforced by DOT
- [ ] DOT_GRAPH.add_edge: note that DOT allows edges to reference non-existent nodes (implicit creation)
- [ ] All builders: note that MML verification is at DOT_GRAPH level, not builder level
- [ ] Compiles clean after documentation additions

### Implementation Notes
From synopsis.md review findings - documentation clarifications only.

### Dependencies
None - can be done immediately.

---

## Task 3: BON_DIAGRAM_BUILDER Source Parsing
**Files:** src/bon_diagram_builder.e
**Features:** `from_file`, `from_directory`

### Acceptance Criteria
- [ ] `from_file` parses Eiffel source file using simple_eiffel_parser
- [ ] Extracts class name, parent classes, deferred/expanded status
- [ ] Calls `add_class` or `add_class_with_features` for each class
- [ ] Calls `add_inheritance` for each inherit clause
- [ ] `from_directory` scans directory for *.e files and calls `from_file`
- [ ] Compiles clean with simple_eiffel_parser dependency
- [ ] Tests parse real Eiffel files from simple_* ecosystem

### Implementation Notes
Requires simple_eiffel_parser for AST extraction. May need to check if parser exists and is usable.

### Dependencies
- Task 1 (renderer must work for to_svg)
- simple_eiffel_parser (Eiffel source parsing)

---

## Task 4: INHERITANCE_BUILDER Source Parsing
**Files:** src/inheritance_builder.e
**Features:** `from_file`, `from_directory`, `filter_to_root`

### Acceptance Criteria
- [ ] `from_file` parses Eiffel file for class and inherit clauses
- [ ] Builds inheritance tree with proper parent/child relationships
- [ ] `from_directory` scans for *.e files
- [ ] `filter_to_root` removes classes not connected to root_class
- [ ] Compiles clean
- [ ] Tests with real class hierarchies

### Implementation Notes
Similar to BON_DIAGRAM_BUILDER but focused on inheritance only. Filter algorithm needs BFS/DFS from root.

### Dependencies
- Task 1 (renderer)
- Task 3 (share parsing logic) or simple_eiffel_parser directly

---

## Task 5: DEPENDENCY_BUILDER ECF Parsing
**Files:** src/dependency_builder.e
**Features:** `from_ecf`

### Acceptance Criteria
- [ ] `from_ecf` parses ECF XML file using simple_xml
- [ ] Extracts library dependencies from `<library>` elements
- [ ] Categorizes as internal (simple_*) vs external (ISE, Gobo)
- [ ] Creates nodes with appropriate colors
- [ ] Creates edges for dependencies
- [ ] Handles nested targets correctly
- [ ] Compiles clean with simple_xml dependency
- [ ] Tests with real ECF files

### Implementation Notes
ECF structure:
```xml
<library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
<library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
```

### Dependencies
- Task 1 (renderer)
- simple_xml (XML parsing)

---

## Task 6: GRAPHVIZ_RENDERER Frame Conditions
**Files:** src/graphviz_renderer.e
**Features:** `render`, `render_to_file`

### Acceptance Criteria
- [ ] Add postconditions confirming renderer state unchanged
- [ ] Add comments explaining external side-effect nature
- [ ] Compiles clean

### Implementation Notes
From synopsis.md ISSUE-C04:
```eiffel
ensure
    state_unchanged: timeout_ms = old timeout_ms
    engine_unchanged: engine.same_string (old engine)
```

### Dependencies
- Task 1 (implement render first)

---

## Task 7: Integration Tests with GraphViz CLI
**Files:** test/test_*.e
**Features:** End-to-end tests

### Acceptance Criteria
- [ ] Test renders simple digraph to SVG
- [ ] Test renders flowchart to PNG
- [ ] Test handles missing GraphViz gracefully
- [ ] Test timeout behavior
- [ ] Test invalid DOT error
- [ ] All 35 skeletal tests pass

### Implementation Notes
Tests require GraphViz installed on system. Mark integration tests appropriately.

### Dependencies
- Task 1 (renderer implementation)
- Task 2 (documentation)

---

## Summary

| Task | Description | Depends On | Priority |
|------|-------------|------------|----------|
| 1 | GRAPHVIZ_RENDERER core | simple_process | HIGH |
| 2 | Documentation notes | None | HIGH |
| 3 | BON_DIAGRAM_BUILDER parsing | Task 1, simple_eiffel_parser | MEDIUM |
| 4 | INHERITANCE_BUILDER parsing | Task 1, simple_eiffel_parser | MEDIUM |
| 5 | DEPENDENCY_BUILDER ECF | Task 1, simple_xml | MEDIUM |
| 6 | Renderer frame conditions | Task 1 | LOW |
| 7 | Integration tests | Task 1, Task 2 | HIGH |

**Critical Path:** Task 2 -> Task 1 -> Task 7

**External Dependencies:**
- simple_process (required for Task 1)
- simple_eiffel_parser (required for Tasks 3, 4) - may not exist yet
- simple_xml (required for Task 5)
