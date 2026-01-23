# INTERFACE DESIGN: simple_graphviz

## Public API Summary

### Creation

| Feature | Purpose | Typical Use |
|---------|---------|-------------|
| `make` | Default creation | `create graphviz.make` |

### Configuration (Builder Pattern)

| Feature | Returns | Purpose |
|---------|---------|---------|
| `title (STRING)` | like Current | Set diagram title |
| `style_bon` | like Current | Use BON notation |
| `style_uml` | like Current | Use UML-like notation |
| `style_minimal` | like Current | Use minimal styling |
| `include_features` | like Current | Show class features |
| `include_private` | like Current | Include private features |
| `layout_engine (STRING)` | like Current | Set GraphViz engine |
| `timeout (INTEGER)` | like Current | Set render timeout |

### Input Sources

| Feature | Returns | Purpose |
|---------|---------|---------|
| `from_file (STRING)` | like Current | Add classes from .e file |
| `from_files (ITERABLE)` | like Current | Add classes from multiple files |
| `from_directory (STRING)` | like Current | Add classes from directory |
| `from_ast (EIFFEL_AST)` | like Current | Add classes from parsed AST |
| `from_graph (DOT_GRAPH)` | like Current | Use pre-built graph |

### Output Operations

| Feature | Returns | Purpose |
|---------|---------|---------|
| `to_dot` | STRING | Generate DOT source |
| `to_svg` | detachable STRING | Render to SVG |
| `to_svg_file (STRING)` | BOOLEAN | Render SVG to file |
| `to_pdf` | detachable STRING | Render to PDF bytes |
| `to_pdf_file (STRING)` | BOOLEAN | Render PDF to file |
| `to_dot_file (STRING)` | BOOLEAN | Save DOT to file |

### Status Queries

| Feature | Returns | Purpose |
|---------|---------|---------|
| `is_graphviz_available` | BOOLEAN | Check GraphViz installed |
| `graphviz_version` | detachable STRING | Get version string |
| `last_error` | detachable STRING | Get last error message |
| `graph` | DOT_GRAPH | Access underlying graph |

## Fluent API Examples

### Basic BON Diagram
```eiffel
local
    graphviz: SIMPLE_GRAPHVIZ
    svg: detachable STRING
do
    create graphviz.make
    svg := graphviz
        .style_bon
        .from_file ("src/my_class.e")
        .to_svg

    if attached svg as l_svg then
        -- Use SVG content
    end
end
```

### Directory-Based Diagram
```eiffel
local
    graphviz: SIMPLE_GRAPHVIZ
do
    create graphviz.make
    if graphviz
        .title ("My Library Architecture")
        .style_bon
        .include_features
        .from_directory ("src/")
        .to_pdf_file ("docs/architecture.pdf")
    then
        print ("PDF generated successfully%N")
    else
        print ("Error: " + graphviz.last_error + "%N")
    end
end
```

### Multiple Files with Custom Engine
```eiffel
local
    graphviz: SIMPLE_GRAPHVIZ
    files: ARRAYED_LIST [STRING]
do
    create files.make_from_array (<<
        "src/facade.e",
        "src/engine.e",
        "src/result.e"
    >>)

    create graphviz.make
    if graphviz
        .layout_engine ("neato")  -- Force-directed layout
        .timeout (60)              -- Allow more time
        .from_files (files)
        .to_svg_file ("diagram.svg")
    then
        print ("Done%N")
    end
end
```

### Low-Level DOT Building
```eiffel
local
    graph: DOT_GRAPH
    node_a, node_b: DOT_NODE
    edge: DOT_EDGE
    renderer: GRAPHVIZ_RENDERER
    result: GRAPHVIZ_RESULT
do
    -- Build graph manually
    create graph.make_digraph ("MyDiagram")

    create node_a.make ("CLASS_A")
    node_a.set_shape ("ellipse")
    node_a.set_label ("CLASS_A")
    graph.add_node (node_a)

    create node_b.make ("CLASS_B")
    node_b.set_shape ("ellipse")
    node_b.set_label ("CLASS_B")
    graph.add_node (node_b)

    create edge.make ("CLASS_B", "CLASS_A")  -- B inherits from A
    edge.set_arrowhead ("empty")
    graph.add_edge (edge)

    -- Render
    create renderer.make
    result := renderer.render_svg (graph.to_dot)

    if result.is_success then
        if attached result.content as svg then
            print (svg)
        end
    else
        print ("Error: " + result.error_message)
    end
end
```

### Check GraphViz Before Use
```eiffel
local
    graphviz: SIMPLE_GRAPHVIZ
do
    create graphviz.make

    if not graphviz.is_graphviz_available then
        print ("GraphViz not found. Please install from https://graphviz.org/download/%N")
    elseif attached graphviz.graphviz_version as v then
        print ("Using GraphViz version: " + v + "%N")
    end
end
```

## Error Handling Pattern

```eiffel
local
    graphviz: SIMPLE_GRAPHVIZ
    svg: detachable STRING
do
    create graphviz.make

    -- Check availability first
    if not graphviz.is_graphviz_available then
        handle_missing_graphviz
    else
        svg := graphviz.from_file ("class.e").to_svg

        if attached svg as l_svg then
            process_svg (l_svg)
        else
            -- Rendering failed
            if attached graphviz.last_error as err then
                handle_error (err)
            end
        end
    end
end
```

## Command-Query Separation

| Feature | Type | Modifies State? | Returns Value? |
|---------|------|-----------------|----------------|
| `style_bon` | Command | YES (sets style) | like Current (chaining) |
| `from_file` | Command | YES (adds classes) | like Current (chaining) |
| `to_dot` | Query | NO | STRING |
| `to_svg` | Function | NO | detachable STRING |
| `to_svg_file` | Command | YES (creates file) | BOOLEAN (success) |
| `is_graphviz_available` | Query | NO | BOOLEAN |
| `last_error` | Query | NO | detachable STRING |
| `graph` | Query | NO | DOT_GRAPH |

**Note:** Builder pattern methods (style_bon, from_file, etc.) technically modify state but return `like Current` to enable fluent chaining. This is an accepted CQS exception for builder patterns.

## DOT_GRAPH Low-Level API

### Node Operations
```eiffel
graph.add_node (create {DOT_NODE}.make ("MY_CLASS"))
graph.node_by_id ("MY_CLASS").set_label ("<<MY_CLASS>>")
graph.has_node ("MY_CLASS")  -- True
```

### Edge Operations
```eiffel
graph.add_edge (create {DOT_EDGE}.make ("CHILD", "PARENT"))
```

### Subgraph Operations
```eiffel
local
    cluster: DOT_SUBGRAPH
do
    create cluster.make ("cluster_core")
    cluster.set_label ("Core Classes")
    cluster.add_node (graph.node_by_id ("CLASS_A"))
    graph.add_subgraph (cluster)
end
```

### Attributes
```eiffel
graph.set_graph_attribute ("rankdir", "BT")  -- Bottom to top
graph.set_node_default ("shape", "ellipse")
graph.set_edge_default ("arrowhead", "empty")
```

## Output Formats

| Format | Method | Engine Support |
|--------|--------|----------------|
| DOT | `to_dot` | N/A (source) |
| SVG | `to_svg`, `to_svg_file` | All |
| PDF | `to_pdf`, `to_pdf_file` | All |
| PNG | (future) | All |

## Layout Engines

| Engine | Best For | Set Via |
|--------|----------|---------|
| dot | Hierarchical/layered (default) | `layout_engine ("dot")` |
| neato | Undirected, force-directed | `layout_engine ("neato")` |
| fdp | Large undirected graphs | `layout_engine ("fdp")` |
| circo | Circular layouts | `layout_engine ("circo")` |
| twopi | Radial layouts | `layout_engine ("twopi")` |
