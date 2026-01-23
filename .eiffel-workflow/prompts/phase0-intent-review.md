# Intent Review Request

**Instructions:** Review the intent document below and generate probing questions
to clarify vague language, identify missing requirements, and surface implicit assumptions.

## Review Criteria

Look for:
1. **Vague language:** Words like "fast", "secure", "easy", "flexible" without concrete definitions
2. **Missing edge cases:** What happens with empty input? Maximum size? Invalid data?
3. **Untestable criteria:** Are acceptance criteria specific and measurable?
4. **Hidden dependencies:** What external systems or libraries are assumed?
5. **Scope ambiguity:** Is "out of scope" clearly defined?

## Output Format

Provide 5-10 probing questions. For each:
- Quote the vague phrase
- Explain why it's vague
- Offer 2-3 concrete alternatives the user can choose from

---

## Intent Document to Review

# Intent: simple_graphviz

## What

A **general-purpose GraphViz library for Eiffel** that generates any type of diagram using the DOT language. The library provides:

1. **Type-safe DOT builder** - Core classes (DOT_GRAPH, DOT_NODE, DOT_EDGE) for constructing any graph structure
2. **GraphViz renderer** - SCOOP-safe subprocess execution to render DOT to SVG/PDF/PNG
3. **Specialized diagram builders** - Pre-built builders for common diagram types
4. **Fluent API** - Easy-to-use facade for quick diagram generation

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

| Diagram Type | Builder Class | Description |
|--------------|---------------|-------------|
| **Generic Graph** | DOT_GRAPH | Any directed/undirected graph |
| **BON Class Diagram** | BON_DIAGRAM_BUILDER | Eiffel class hierarchies with BON notation |
| **Inheritance Tree** | INHERITANCE_BUILDER | Class inheritance visualization |
| **Dependency Graph** | DEPENDENCY_BUILDER | Library/package dependencies |
| **Flowchart** | FLOWCHART_BUILDER | Process flows with decision nodes |
| **State Machine** | STATE_MACHINE_BUILDER | States and transitions |

### Tier 2: Extended (v1.1)
| Diagram Type | Builder Class | Description |
|--------------|---------------|-------------|
| Call Graph | CALL_GRAPH_BUILDER | Feature call relationships |
| Mind Map | MIND_MAP_BUILDER | Hierarchical idea organization |
| ER Diagram | ER_DIAGRAM_BUILDER | Entity-relationship for databases |
| Network Diagram | NETWORK_BUILDER | Nodes and connections |
| Org Chart | ORG_CHART_BUILDER | Organizational hierarchy |
| Timeline | TIMELINE_BUILDER | Sequential events |

### Tier 3: Future (v2.0)
| Diagram Type | Description |
|--------------|-------------|
| Sequence Diagram | Message passing between objects |
| Activity Diagram | UML activity flows |
| Component Diagram | System architecture |
| Deployment Diagram | Infrastructure layout |

## Users

| User | Use Case | API Level |
|------|----------|-----------|
| Any Eiffel Developer | Generate any diagram type | High-level facade |
| Library Authors | BON diagrams for documentation | BON_DIAGRAM_BUILDER |
| DevOps/CI | Dependency graphs, architecture diagrams | DEPENDENCY_BUILDER |
| Application Developers | State machines, flowcharts | Specialized builders |
| Tool Developers | Custom diagram generation | Low-level DOT builder |

## Example Usage

### Generic Graph (Low-Level)
```eiffel
create graph.make_digraph ("MyGraph")
graph.add_node (create {DOT_NODE}.make ("A"))
graph.add_node (create {DOT_NODE}.make ("B"))
graph.add_edge (create {DOT_EDGE}.make ("A", "B"))
svg := renderer.render_svg (graph.to_dot)
```

### BON Class Diagram
```eiffel
create graphviz.make
graphviz.bon_diagram
    .from_directory ("src/")
    .include_features
    .to_svg_file ("docs/classes.svg")
```

### Flowchart
```eiffel
create graphviz.make
graphviz.flowchart
    .start ("Begin")
    .decision ("Valid?", "Yes", "No")
    .process ("Process Data")
    .end_node ("Done")
    .to_svg_file ("flow.svg")
```

### State Machine
```eiffel
create graphviz.make
graphviz.state_machine
    .initial ("Idle")
    .state ("Running")
    .state ("Paused")
    .transition ("Idle", "Running", "start")
    .transition ("Running", "Paused", "pause")
    .transition ("Paused", "Running", "resume")
    .transition ("Running", "Idle", "stop")
    .to_svg_file ("states.svg")
```

### Dependency Graph
```eiffel
create graphviz.make
graphviz.dependency_graph
    .from_ecf ("my_project.ecf")
    .show_external (True)
    .to_svg_file ("dependencies.svg")
```

### Inheritance Tree
```eiffel
create graphviz.make
graphviz.inheritance_tree
    .root_class ("ANIMAL")
    .from_directory ("src/")
    .to_svg_file ("hierarchy.svg")
```

## Acceptance Criteria

### Core Infrastructure
- [ ] Generate valid DOT language accepted by GraphViz `dot` command
- [ ] Support directed graphs (digraph) and undirected graphs (graph)
- [ ] Render to SVG, PDF, PNG formats
- [ ] Detect GraphViz availability via `is_graphviz_available`
- [ ] Handle rendering failures gracefully with `last_error`
- [ ] Configurable timeout (default 30s)
- [ ] Full Design by Contract coverage
- [ ] SCOOP-compatible
- [ ] 40+ unit tests passing

### DOT Builder (Core)
- [ ] DOT_NODE with all standard attributes (shape, color, label, style)
- [ ] DOT_EDGE with all standard attributes (style, arrowhead, label)
- [ ] DOT_SUBGRAPH for clustering/grouping
- [ ] DOT_ATTRIBUTES with proper escaping
- [ ] Serialize to valid DOT string

### BON Diagram Builder
- [ ] Parse Eiffel files via simple_eiffel_parser
- [ ] Ellipse shapes for classes
- [ ] Inheritance arrows (child → parent, empty arrowhead)
- [ ] Deferred classes (dashed border)
- [ ] Expanded classes (gray fill)
- [ ] Optional feature display in labels

### Flowchart Builder
- [ ] Start/End nodes (rounded rectangles)
- [ ] Process nodes (rectangles)
- [ ] Decision nodes (diamonds)
- [ ] Automatic edge routing

### State Machine Builder
- [ ] Initial state indicator
- [ ] Final state indicator
- [ ] State nodes (rounded rectangles)
- [ ] Transition edges with labels

### Dependency Builder
- [ ] Parse ECF files for library dependencies
- [ ] Show internal vs external libraries
- [ ] Cluster by category

### Inheritance Builder
- [ ] Build tree from parsed classes
- [ ] Optional: show only subtree from root class
- [ ] Top-down or bottom-up layout

## Out of Scope (v1.0)

| Feature | Reason | Future? |
|---------|--------|---------|
| Native GraphViz C binding | Subprocess pattern simpler, proven | No |
| Custom layout algorithms | GraphViz handles excellently | No |
| Interactive diagrams | Web concern | v2.0 |
| AI-assisted layout | No clear value | Post-MVP |
| Bundled GraphViz binaries | ~100MB, licensing | v1.1 |

## Dependencies (simple_* First)

| Need | Library | Justification |
|------|---------|---------------|
| Parse .e files | simple_eiffel_parser | Class structure extraction |
| Subprocess | simple_process | SCOOP-safe GraphViz execution |
| File I/O | simple_file | Write DOT, read output |
| PDF export | simple_pdf | Alternative PDF via HTML/SVG |
| MML | simple_mml | Frame conditions for collections |
| Core types | base (ISE) | No alternative |

**External:** GraphViz (detected via `is_graphviz_available`)

## MML Decision

**Decision:** YES - Required

**Rationale:** DOT_GRAPH contains multiple ARRAYED_LIST collections; frame conditions needed for add/remove operations.

## Classes (v1.0)

### Core (6 classes)
| Class | Responsibility |
|-------|----------------|
| SIMPLE_GRAPHVIZ | Main facade with fluent API |
| DOT_GRAPH | Graph structure |
| DOT_NODE | Node with attributes |
| DOT_EDGE | Edge between nodes |
| DOT_SUBGRAPH | Cluster grouping |
| DOT_ATTRIBUTES | Key-value pairs with escaping |

### Rendering (2 classes)
| Class | Responsibility |
|-------|----------------|
| GRAPHVIZ_RENDERER | Subprocess execution |
| GRAPHVIZ_RESULT | Render result |

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

**Total: 14 classes for v1.0**

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
                                        └───────┬───────┘
                                                │
                                                ▼
                                        ┌───────────────┐
                                        │ GRAPHVIZ_     │
                                        │ RESULT        │
                                        │               │
                                        │ content       │
                                        │ save_to_file  │
                                        └───────────────┘
```

## Risk Mitigations

| Risk | Mitigation |
|------|------------|
| GraphViz not installed | `is_graphviz_available`; installation docs |
| Large output buffer | File-based I/O fallback |
| DOT escaping bugs | `escape_value` utility; test suite |
| Subprocess hangs | Configurable timeout |
| Scope creep | Tiered diagram types; clear v1.0 scope |
