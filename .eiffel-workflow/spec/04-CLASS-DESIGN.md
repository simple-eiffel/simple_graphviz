# CLASS DESIGN: simple_graphviz

## Class Inventory

| Class | Role | Single Responsibility |
|-------|------|----------------------|
| SIMPLE_GRAPHVIZ | Facade | Coordinate library use, fluent API |
| DOT_GRAPH | Data | Hold graph structure (nodes, edges, subgraphs) |
| DOT_NODE | Data | Hold single node with attributes |
| DOT_EDGE | Data | Hold edge between two nodes |
| DOT_SUBGRAPH | Data | Hold cluster/subgraph of nodes |
| DOT_ATTRIBUTES | Helper | Manage key-value attribute pairs |
| GRAPHVIZ_RENDERER | Engine | Execute GraphViz subprocess, capture output |
| GRAPHVIZ_RESULT | Data | Hold rendering result (success/failure, content) |
| GRAPHVIZ_STYLE | Config | Define visual style presets (BON, UML, minimal) |
| BON_DIAGRAM_BUILDER | Adapter | Convert Eiffel AST to DOT_GRAPH |

**Total: 10 classes**

## Facade Design: SIMPLE_GRAPHVIZ

**Purpose:** Single entry point for library functionality
**Responsibility:** Coordinate parser, builder, graph, and renderer

**Public Interface:**
```eiffel
class SIMPLE_GRAPHVIZ

create
    make

feature -- Configuration (Builder Pattern)

    title (a_title: READABLE_STRING_GENERAL): like Current
        -- Set diagram title. Returns Current for chaining.

    style_bon: like Current
        -- Use BON notation defaults. Returns Current.

    style_uml: like Current
        -- Use UML-like notation. Returns Current.

    include_features: like Current
        -- Include class features in diagram. Returns Current.

    include_private: like Current
        -- Include private features. Returns Current.

    layout_engine (a_engine: READABLE_STRING_GENERAL): like Current
        -- Set layout engine (dot, neato, fdp, etc.). Returns Current.

    timeout (a_seconds: INTEGER): like Current
        -- Set rendering timeout. Returns Current.

feature -- Input Sources

    from_file (a_path: READABLE_STRING_GENERAL): like Current
        -- Add classes from single .e file.

    from_files (a_paths: ITERABLE [READABLE_STRING_GENERAL]): like Current
        -- Add classes from multiple .e files.

    from_directory (a_path: READABLE_STRING_GENERAL): like Current
        -- Add classes from directory (recursive).

    from_ast (a_ast: EIFFEL_AST): like Current
        -- Add classes from parsed AST.

    from_graph (a_graph: DOT_GRAPH): like Current
        -- Use pre-built DOT graph.

feature -- Output

    to_dot: STRING
        -- Generate DOT source string.

    to_svg: detachable STRING
        -- Render to SVG string. Void if rendering fails.

    to_svg_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
        -- Render to SVG file. True if successful.

    to_pdf: detachable STRING
        -- Render to PDF bytes (as string). Void if fails.

    to_pdf_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
        -- Render to PDF file. True if successful.

    to_dot_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
        -- Save DOT source to file. True if successful.

feature -- Status

    is_graphviz_available: BOOLEAN
        -- Is GraphViz installed and accessible?

    graphviz_version: detachable STRING
        -- GraphViz version string, or Void if not available.

    last_error: detachable STRING
        -- Error from last operation, or Void if successful.

    graph: DOT_GRAPH
        -- The underlying DOT graph (for advanced manipulation).
```

**Hides:**
- BON_DIAGRAM_BUILDER: AST-to-graph conversion
- GRAPHVIZ_RENDERER: subprocess execution
- GRAPHVIZ_STYLE: style preset details

## DOT AST Classes

### DOT_GRAPH

**Purpose:** Hold complete graph structure
**Responsibility:** Manage nodes, edges, subgraphs

```eiffel
class DOT_GRAPH

create
    make_graph,
    make_digraph

feature -- Access

    name: STRING
    is_directed: BOOLEAN
    nodes: ARRAYED_LIST [DOT_NODE]
    edges: ARRAYED_LIST [DOT_EDGE]
    subgraphs: ARRAYED_LIST [DOT_SUBGRAPH]
    graph_attributes: DOT_ATTRIBUTES
    node_defaults: DOT_ATTRIBUTES
    edge_defaults: DOT_ATTRIBUTES

feature -- Modification

    add_node (a_node: DOT_NODE)
    add_edge (a_edge: DOT_EDGE)
    add_subgraph (a_subgraph: DOT_SUBGRAPH)
    set_graph_attribute (a_key, a_value: STRING)
    set_node_default (a_key, a_value: STRING)
    set_edge_default (a_key, a_value: STRING)

feature -- Query

    has_node (a_id: STRING): BOOLEAN
    node_by_id (a_id: STRING): detachable DOT_NODE

feature -- Output

    to_dot: STRING
        -- Serialize to DOT language string.
```

### DOT_NODE

**Purpose:** Represent single graph node
**Responsibility:** Hold node ID, label, and attributes

```eiffel
class DOT_NODE

create
    make

feature -- Access

    id: STRING
    label: detachable STRING
    attributes: DOT_ATTRIBUTES

feature -- Modification

    set_label (a_label: STRING)
    set_attribute (a_key, a_value: STRING)
    set_shape (a_shape: STRING)
    set_style (a_style: STRING)
    set_color (a_color: STRING)
    set_fillcolor (a_fillcolor: STRING)

feature -- Output

    to_dot: STRING
```

### DOT_EDGE

**Purpose:** Represent edge between nodes
**Responsibility:** Hold endpoints and attributes

```eiffel
class DOT_EDGE

create
    make

feature -- Access

    from_id: STRING
    to_id: STRING
    attributes: DOT_ATTRIBUTES

feature -- Modification

    set_attribute (a_key, a_value: STRING)
    set_style (a_style: STRING)
    set_arrowhead (a_arrowhead: STRING)
    set_label (a_label: STRING)

feature -- Output

    to_dot (a_directed: BOOLEAN): STRING
```

### DOT_SUBGRAPH

**Purpose:** Represent cluster/subgraph
**Responsibility:** Group nodes visually

```eiffel
class DOT_SUBGRAPH

create
    make

feature -- Access

    name: STRING
    label: detachable STRING
    nodes: ARRAYED_LIST [DOT_NODE]
    attributes: DOT_ATTRIBUTES

feature -- Modification

    add_node (a_node: DOT_NODE)
    set_label (a_label: STRING)
    set_attribute (a_key, a_value: STRING)

feature -- Output

    to_dot: STRING
```

### DOT_ATTRIBUTES

**Purpose:** Manage key-value attribute pairs
**Responsibility:** Store and serialize DOT attributes

```eiffel
class DOT_ATTRIBUTES

create
    make

feature -- Access

    items: HASH_TABLE [STRING, STRING]
    count: INTEGER

feature -- Modification

    put (a_key, a_value: STRING)
    remove (a_key: STRING)
    clear

feature -- Query

    has (a_key: STRING): BOOLEAN
    item (a_key: STRING): detachable STRING

feature -- Output

    to_dot: STRING
        -- Format as [key=value, ...] or empty if no attributes.

feature -- Utilities

    escape_value (a_value: STRING): STRING
        -- Escape special characters for DOT.
```

## Engine Classes

### GRAPHVIZ_RENDERER

**Purpose:** Execute GraphViz and capture output
**Responsibility:** Subprocess management

```eiffel
class GRAPHVIZ_RENDERER

create
    make

feature -- Configuration

    set_engine (a_engine: STRING)
        -- Set layout engine (dot, neato, fdp, circo, twopi).

    set_timeout (a_seconds: INTEGER)
        -- Set execution timeout.

    set_use_file_io (a_value: BOOLEAN)
        -- Use file-based I/O instead of pipes.

feature -- Status

    is_available: BOOLEAN
        -- Is GraphViz installed?

    version: detachable STRING
        -- GraphViz version string.

    engine: STRING
        -- Current layout engine.

    timeout: INTEGER
        -- Current timeout in seconds.

feature -- Rendering

    render (a_dot: STRING; a_format: STRING): GRAPHVIZ_RESULT
        -- Render DOT to specified format (svg, pdf, png).

    render_svg (a_dot: STRING): GRAPHVIZ_RESULT
        -- Render DOT to SVG.

    render_pdf (a_dot: STRING): GRAPHVIZ_RESULT
        -- Render DOT to PDF.
```

### GRAPHVIZ_RESULT

**Purpose:** Hold rendering result
**Immutable:** YES

```eiffel
class GRAPHVIZ_RESULT

create
    make_success,
    make_failure

feature -- Access

    is_success: BOOLEAN
    content: detachable STRING
    error_message: detachable STRING
    format: STRING

feature -- Operations

    save_to_file (a_path: STRING): BOOLEAN
        -- Save content to file. True if successful.

invariant
    success_xor_error: is_success xor (error_message /= Void)
    success_has_content: is_success implies content /= Void
```

### GRAPHVIZ_STYLE

**Purpose:** Define visual style presets
**Responsibility:** Apply consistent styling

```eiffel
class GRAPHVIZ_STYLE

create
    make_bon,
    make_uml,
    make_minimal

feature -- Access

    name: STRING
    class_shape: STRING
    class_color: STRING
    class_fillcolor: STRING
    deferred_style: STRING
    expanded_fillcolor: STRING
    inheritance_arrowhead: STRING
    client_arrowhead: STRING
    font_name: STRING
    font_size: INTEGER

feature -- Application

    apply_to_class_node (a_node: DOT_NODE; a_class: EIFFEL_CLASS_NODE)
        -- Apply style to node based on class type.

    apply_to_inheritance_edge (a_edge: DOT_EDGE)
        -- Apply inheritance arrow style.

    apply_to_client_edge (a_edge: DOT_EDGE)
        -- Apply client-supplier arrow style.

    apply_to_graph (a_graph: DOT_GRAPH)
        -- Apply graph-level defaults.
```

## Adapter Class

### BON_DIAGRAM_BUILDER

**Purpose:** Convert Eiffel AST to DOT graph
**Responsibility:** AST traversal, graph construction

```eiffel
class BON_DIAGRAM_BUILDER

create
    make

feature -- Configuration

    set_style (a_style: GRAPHVIZ_STYLE)
    set_include_features (a_value: BOOLEAN)
    set_include_private (a_value: BOOLEAN)
    set_show_inheritance (a_value: BOOLEAN)

feature -- Building

    build_from_ast (a_ast: EIFFEL_AST): DOT_GRAPH
        -- Build graph from parsed AST.

    build_from_classes (a_classes: ITERABLE [EIFFEL_CLASS_NODE]): DOT_GRAPH
        -- Build graph from class list.

    add_class (a_class: EIFFEL_CLASS_NODE)
        -- Add single class to current graph.

    add_inheritance_edges
        -- Add inheritance arrows for all classes.

feature -- Access

    graph: DOT_GRAPH
        -- The graph being built.

feature {NONE} -- Implementation

    class_to_node (a_class: EIFFEL_CLASS_NODE): DOT_NODE
    build_class_label (a_class: EIFFEL_CLASS_NODE): STRING
    feature_to_string (a_feature: EIFFEL_FEATURE_NODE): STRING
```

## Inheritance Hierarchy

```
No deferred classes in MVP - all concrete implementations.
Future: Could add GRAPHVIZ_ENGINE deferred base for multiple render backends.
```

**Inheritance Justification:**
| Child | Parent | IS-A Valid? | Liskov OK? |
|-------|--------|-------------|------------|
| (none in MVP) | - | - | - |

## Generic Classes

| Class | Type Parameter | Constraint | Purpose |
|-------|----------------|------------|---------|
| (none in MVP) | - | - | - |

## Class Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      SIMPLE_GRAPHVIZ                            │
│                         (Facade)                                │
├─────────────────────────────────────────────────────────────────┤
│ + make                                                          │
│ + title (STRING): like Current                                  │
│ + style_bon: like Current                                       │
│ + from_file (STRING): like Current                              │
│ + from_directory (STRING): like Current                         │
│ + to_dot: STRING                                                │
│ + to_svg: detachable STRING                                     │
│ + to_pdf_file (STRING): BOOLEAN                                 │
│ + is_graphviz_available: BOOLEAN                                │
├─────────────────────────────────────────────────────────────────┤
│ - builder: BON_DIAGRAM_BUILDER                                  │
│ - renderer: GRAPHVIZ_RENDERER                                   │
│ - style: GRAPHVIZ_STYLE                                         │
└───────────────────────────┬─────────────────────────────────────┘
                            │ uses
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ BON_DIAGRAM_  │   │ DOT_GRAPH     │   │ GRAPHVIZ_     │
│ BUILDER       │   │               │   │ RENDERER      │
├───────────────┤   ├───────────────┤   ├───────────────┤
│ + build_from_ │   │ + add_node    │   │ + render_svg  │
│   ast         │   │ + add_edge    │   │ + render_pdf  │
│ + add_class   │   │ + to_dot      │   │ + is_available│
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        │ uses              │ contains          │ produces
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ EIFFEL_       │   │ DOT_NODE      │   │ GRAPHVIZ_     │
│ CLASS_NODE    │   │ DOT_EDGE      │   │ RESULT        │
│ (parser)      │   │ DOT_SUBGRAPH  │   │               │
└───────────────┘   │ DOT_ATTRIBUTES│   └───────────────┘
                    └───────────────┘
                            │
                    ┌───────────────┐
                    │ GRAPHVIZ_     │
                    │ STYLE         │
                    └───────────────┘
```
