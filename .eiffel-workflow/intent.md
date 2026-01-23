# Intent: simple_graphviz (v2 - Refined)

## What

A **general-purpose GraphViz library for Eiffel** that generates any type of diagram using the DOT language. The library provides:

1. **Type-safe DOT builder** - Core classes (DOT_GRAPH, DOT_NODE, DOT_EDGE) for constructing any graph structure with arbitrary attribute support
2. **GraphViz renderer** - SCOOP-safe subprocess execution to render DOT to SVG/PDF/PNG via GraphViz 2.40+
3. **Specialized diagram builders** - Pre-built builders for 6 common diagram types with automatic layout engine selection
4. **Fluent API** - Facade requiring 3-5 lines of code for basic diagrams, returning GRAPHVIZ_RESULT objects

This is NOT just a BON diagram tool - it's a complete GraphViz integration library that happens to include BON support as one of many diagram types.

## Why

1. **No Eiffel GraphViz library exists** - Major ecosystem gap
2. **Diagrams are everywhere** - Architecture, workflows, state machines, dependencies
3. **Automation need** - CI/CD pipelines need programmatic diagram generation
4. **GraphViz is powerful** - Excellent layout algorithms, widely used, stable
5. **Type safety** - Eiffel's contracts make graph construction more reliable than string templates

## Diagram Types Supported

### Tier 1: Core (v1.0)
These are built into the library with dedicated builder classes:

| Diagram Type | Builder Class | Layout Engine | Description |
|--------------|---------------|---------------|-------------|
| **Generic Graph** | DOT_GRAPH | dot (default) | Any directed/undirected graph |
| **BON Class Diagram** | BON_DIAGRAM_BUILDER | dot | Eiffel class hierarchies with BON notation |
| **Inheritance Tree** | INHERITANCE_BUILDER | dot | Class inheritance visualization (top-down) |
| **Dependency Graph** | DEPENDENCY_BUILDER | dot | Library/package dependencies |
| **Flowchart** | FLOWCHART_BUILDER | dot | Process flows with decision nodes |
| **State Machine** | STATE_MACHINE_BUILDER | dot | States and transitions |

### Tier 2: Extended (v1.1)
| Diagram Type | Builder Class | Layout Engine | Description |
|--------------|---------------|---------------|-------------|
| Call Graph | CALL_GRAPH_BUILDER | dot | Feature call relationships |
| Mind Map | MIND_MAP_BUILDER | twopi | Hierarchical idea organization (radial) |
| ER Diagram | ER_DIAGRAM_BUILDER | neato | Entity-relationship for databases |
| Network Diagram | NETWORK_BUILDER | fdp | Nodes and connections (force-directed) |
| Org Chart | ORG_CHART_BUILDER | dot | Organizational hierarchy |
| Timeline | TIMELINE_BUILDER | dot | Sequential events (left-to-right) |

### Tier 3: Future (v2.0)
| Diagram Type | Description |
|--------------|-------------|
| Sequence Diagram | Message passing between objects (requires subgraphs) |
| Activity Diagram | UML activity flows (swimlanes) |
| Component Diagram | System architecture with ports |
| Deployment Diagram | Infrastructure layout |

## Users

| User | Use Case | API Level |
|------|----------|-----------|
| Any Eiffel Developer | Generate any diagram type | High-level facade (3-5 lines) |
| Library Authors | BON diagrams for documentation | BON_DIAGRAM_BUILDER |
| DevOps/CI | Dependency graphs, architecture diagrams | DEPENDENCY_BUILDER |
| Application Developers | State machines, flowcharts | Specialized builders |
| Tool Developers | Custom diagram generation | Low-level DOT builder with arbitrary attributes |

## Example Usage

### Generic Graph (Low-Level)
```eiffel
create graph.make_digraph ("MyGraph")
graph.add_node (create {DOT_NODE}.make ("A"))
graph.add_node (create {DOT_NODE}.make ("B"))
graph.add_edge (create {DOT_EDGE}.make ("A", "B"))
Result := renderer.render_svg (graph.to_dot)
-- Result: GRAPHVIZ_RESULT with is_success, content, error
```

### BON Class Diagram (3 lines)
```eiffel
create graphviz.make
Result := graphviz.bon_diagram
    .from_directory ("src/")
    .include_features
    .to_svg_file ("docs/classes.svg")
```

### Flowchart (4 lines)
```eiffel
create graphviz.make
Result := graphviz.flowchart
    .start ("Begin")
    .decision ("Valid?", "Yes", "No")
    .process ("Process Data")
    .end_node ("Done")
    .to_svg_file ("flow.svg")
```

### State Machine (5 lines)
```eiffel
create graphviz.make
Result := graphviz.state_machine
    .initial ("Idle")
    .state ("Running")
    .state ("Paused")
    .transition ("Idle", "Running", "start")
    .transition ("Running", "Paused", "pause")
    .transition ("Paused", "Running", "resume")
    .transition ("Running", "Idle", "stop")
    .to_svg_file ("states.svg")
```

### Custom Attributes
```eiffel
node.set_attribute ("fontname", "Helvetica")
node.set_attribute ("fontsize", "12")
node.set_attribute ("penwidth", "2.0")
-- Arbitrary GraphViz attributes supported
```

### Layout Engine Override
```eiffel
graphviz.set_engine ("neato")  -- Force-directed layout
graphviz.set_engine ("circo")  -- Circular layout
```

## Acceptance Criteria

### Core Infrastructure
- [ ] Generate valid DOT language accepted by GraphViz `dot` command
- [ ] Support directed graphs (digraph) and undirected graphs (graph)
- [ ] Render to SVG, PDF, PNG formats via GraphViz native output
- [ ] Detect GraphViz 2.40+ availability via `is_graphviz_available` (uses `dot -V`)
- [ ] Handle rendering failures with GRAPHVIZ_ERROR object (code enum + message)
- [ ] Configurable timeout (default 30s); render 100+ node graphs within timeout
- [ ] 100% DBC coverage: all public features have preconditions/postconditions; invariants on collection classes
- [ ] SCOOP-compatible: no internal threads; subprocess isolation ensures safety
- [ ] 40+ unit tests passing
- [ ] Empty graph input returns valid empty DOT output (no error)

### DOT Builder (Core)
- [ ] DOT_NODE with 20 common attributes as dedicated setters (shape, color, label, style, fillcolor, fontname, fontsize, width, height, penwidth, etc.)
- [ ] DOT_NODE with `set_attribute (key, value)` for arbitrary attributes
- [ ] DOT_EDGE with 15 common attributes (style, arrowhead, arrowtail, label, color, penwidth, etc.)
- [ ] DOT_EDGE with `set_attribute (key, value)` for arbitrary attributes
- [ ] DOT_SUBGRAPH for clustering/grouping with `cluster_` prefix convention
- [ ] DOT_ATTRIBUTES with proper escaping (quotes, backslashes, newlines)
- [ ] Serialize to valid DOT string via `to_dot`

### BON Diagram Builder
- [ ] Parse Eiffel files via simple_eiffel_parser
- [ ] Ellipse shapes for classes (BON standard per OOSC2)
- [ ] Inheritance arrows (child → parent, empty arrowhead)
- [ ] Deferred classes (dashed border via style=dashed)
- [ ] Expanded classes (gray fill via fillcolor=gray90)
- [ ] Optional feature display in labels via `include_features`

### Flowchart Builder
- [ ] Start/End nodes (rounded rectangles via shape=box, style=rounded)
- [ ] Process nodes (rectangles via shape=box)
- [ ] Decision nodes (diamonds via shape=diamond)
- [ ] Automatic edge routing via dot layout engine

### State Machine Builder
- [ ] Initial state indicator (small filled circle via shape=point)
- [ ] Final state indicator (double circle via shape=doublecircle)
- [ ] State nodes (rounded rectangles via shape=box, style=rounded)
- [ ] Transition edges with labels

### Dependency Builder
- [ ] Parse ECF files for library dependencies
- [ ] Show internal vs external libraries (different colors)
- [ ] Cluster by category using DOT_SUBGRAPH

### Inheritance Builder
- [ ] Build tree from parsed classes
- [ ] Optional: show only subtree from root class via `root_class`
- [ ] Top-down layout (default) or bottom-up via `set_direction`

### Layout Engine Support
- [ ] Default engine: `dot` (hierarchical)
- [ ] Support `set_engine` for: dot, neato, fdp, circo, twopi, osage, sfdp
- [ ] Builders automatically select appropriate engine

### Error Handling
- [ ] GRAPHVIZ_ERROR class with code enum:
  - `graphviz_not_found` - GraphViz not installed
  - `timeout` - Render exceeded timeout
  - `invalid_dot` - DOT syntax error
  - `output_error` - File write failed
  - `version_mismatch` - GraphViz version too old
- [ ] Error includes message STRING for details
- [ ] GRAPHVIZ_RESULT has `is_success`, `content`, `error`

## Out of Scope (v1.0)

| Feature | Reason | Future? |
|---------|--------|---------|
| Native GraphViz C binding | Subprocess pattern simpler, proven | No |
| Custom layout algorithms | GraphViz handles excellently | No |
| Interactive diagrams | Web concern | v2.0 |
| AI-assisted layout | No clear value | Post-MVP |
| Bundled GraphViz binaries | ~100MB, licensing | v1.1 |
| simple_pdf integration | GraphViz native PDF sufficient | No |
| Layout algorithm customization | Out of scope; use engine selection | No |

## Dependencies (simple_* First)

| Need | Library | Justification |
|------|---------|---------------|
| Parse .e files | simple_eiffel_parser | Class structure extraction for BON |
| Subprocess | simple_process | SCOOP-safe GraphViz execution |
| File I/O | simple_file | Write DOT temp files, read output |
| MML | simple_mml | Frame conditions for collections |
| Core types | base (ISE) | No alternative |

**External:** GraphViz 2.40+ (detected via `is_graphviz_available`)

## MML Decision

**Decision:** YES - Required

**Rationale:** DOT_GRAPH contains multiple ARRAYED_LIST collections (nodes, edges, subgraphs); frame conditions needed for add/remove operations to ensure only the modified collection changes.

## Classes (v1.0)

### Core (6 classes)
| Class | Responsibility |
|-------|----------------|
| SIMPLE_GRAPHVIZ | Main facade with fluent API |
| DOT_GRAPH | Graph structure (nodes, edges, subgraphs) |
| DOT_NODE | Node with attributes (20 common + arbitrary) |
| DOT_EDGE | Edge between nodes (15 common + arbitrary) |
| DOT_SUBGRAPH | Cluster grouping |
| DOT_ATTRIBUTES | Key-value pairs with escaping |

### Rendering (3 classes)
| Class | Responsibility |
|-------|----------------|
| GRAPHVIZ_RENDERER | Subprocess execution, engine selection |
| GRAPHVIZ_RESULT | Render result (success/failure, content) |
| GRAPHVIZ_ERROR | Error code enum + message |

### Styles (1 class)
| Class | Responsibility |
|-------|----------------|
| GRAPHVIZ_STYLE | Visual presets (BON, UML, minimal, etc.) |

### Builders (5 classes)
| Class | Responsibility |
|-------|----------------|
| BON_DIAGRAM_BUILDER | Eiffel → BON class diagram |
| INHERITANCE_BUILDER | Class inheritance tree |
| DEPENDENCY_BUILDER | Library dependencies from ECF |
| FLOWCHART_BUILDER | Process flowcharts |
| STATE_MACHINE_BUILDER | State machine diagrams |

**Total: 15 classes for v1.0**

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      SIMPLE_GRAPHVIZ                            │
│                    (Facade - Fluent API)                        │
│                                                                 │
│  .bon_diagram      → BON_DIAGRAM_BUILDER                        │
│  .flowchart        → FLOWCHART_BUILDER                          │
│  .state_machine    → STATE_MACHINE_BUILDER                      │
│  .dependency_graph → DEPENDENCY_BUILDER                         │
│  .inheritance_tree → INHERITANCE_BUILDER                        │
│  .graph            → DOT_GRAPH (direct access)                  │
│  .set_engine       → Engine override (dot/neato/fdp/circo/etc)  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        ▼                                       ▼
┌───────────────────────┐               ┌───────────────┐
│     BUILDERS          │               │ DOT CORE      │
│                       │               │               │
│ BON_DIAGRAM_BUILDER   │──────────────▶│ DOT_GRAPH     │
│ FLOWCHART_BUILDER     │   produces    │ DOT_NODE      │
│ STATE_MACHINE_BUILDER │               │ DOT_EDGE      │
│ DEPENDENCY_BUILDER    │               │ DOT_SUBGRAPH  │
│ INHERITANCE_BUILDER   │               │ DOT_ATTRIBUTES│
│                       │               │               │
│ (any order allowed;   │               │ (arbitrary    │
│  validates at build)  │               │  attributes)  │
└───────────────────────┘               └───────┬───────┘
                                                │
                                                │ to_dot
                                                ▼
                                        ┌───────────────┐
                                        │ GRAPHVIZ_     │
                                        │ RENDERER      │
                                        │               │
                                        │ render_svg    │
                                        │ render_pdf    │
                                        │ render_png    │
                                        │ set_engine    │
                                        │ set_timeout   │
                                        └───────┬───────┘
                                                │
                                                ▼
                                        ┌───────────────┐
                                        │ GRAPHVIZ_     │
                                        │ RESULT        │
                                        │               │
                                        │ is_success    │
                                        │ content       │
                                        │ error         │←── GRAPHVIZ_ERROR
                                        │ save_to_file  │    (code + message)
                                        └───────────────┘
```

## Risk Mitigations

| Risk | Mitigation |
|------|------------|
| GraphViz not installed | `is_graphviz_available` query; `graphviz_not_found` error code; installation docs |
| GraphViz too old | Version check via `dot -V`; `version_mismatch` error if < 2.40 |
| Large output buffer | File-based I/O via simple_file (write temp DOT, read output file) |
| DOT escaping bugs | `DOT_ATTRIBUTES.escape_value` utility; comprehensive test suite |
| Subprocess hangs | Configurable timeout (default 30s); `timeout` error code |
| Scope creep | Tiered diagram types; clear v1.0 scope |
| Builder misuse | Any-order calls allowed; validation at `build` time |
| Invalid DOT | `invalid_dot` error code with GraphViz stderr message |

## Review History

- **v1**: Initial intent (BON-focused)
- **v2**: Expanded to general-purpose; incorporated Ollama + Claude review (16 questions resolved)
