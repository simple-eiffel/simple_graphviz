# SPECIFICATION: simple_graphviz

## Overview

simple_graphviz is an Eiffel library for generating BON (Business Object Notation) class diagrams from Eiffel source code. It generates GraphViz DOT language, invokes the `dot` command for rendering, and produces SVG/PDF output. The library integrates with simple_eiffel_parser for source analysis and simple_process for SCOOP-safe subprocess execution.

## Class Specifications

### SIMPLE_GRAPHVIZ (Facade)

```eiffel
note
    description: "Facade for GraphViz diagram generation from Eiffel source"
    author: "Larry Rix"

class
    SIMPLE_GRAPHVIZ

create
    make

feature {NONE} -- Initialization

    make
            -- Create with BON style defaults.
        do
            create graph.make_digraph ("EiffelDiagram")
            create renderer.make
            create style.make_bon
            create builder.make
            builder.set_style (style)
        ensure
            not_configured: graph.nodes.is_empty
            default_style: style.name.is_equal ("bon")
            default_engine: renderer.engine.is_equal ("dot")
        end

feature -- Configuration

    title (a_title: READABLE_STRING_GENERAL): like Current
            -- Set diagram title.
        require
            title_not_empty: a_title /= Void and then not a_title.is_empty
        do
            graph.set_graph_attribute ("label", a_title.to_string_8)
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    style_bon: like Current
            -- Use BON notation defaults.
        do
            create style.make_bon
            builder.set_style (style)
            Result := Current
        ensure
            style_is_bon: style.name.is_equal ("bon")
            result_is_current: Result = Current
        end

    style_uml: like Current
            -- Use UML-like notation.
        do
            create style.make_uml
            builder.set_style (style)
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    include_features: like Current
            -- Include class features in diagram.
        do
            builder.set_include_features (True)
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    layout_engine (a_engine: READABLE_STRING_GENERAL): like Current
            -- Set layout engine (dot, neato, fdp, circo, twopi).
        require
            engine_not_empty: a_engine /= Void and then not a_engine.is_empty
        do
            renderer.set_engine (a_engine.to_string_8)
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    timeout (a_seconds: INTEGER): like Current
            -- Set rendering timeout in seconds.
        require
            positive: a_seconds > 0
        do
            renderer.set_timeout (a_seconds)
            Result := Current
        ensure
            result_is_current: Result = Current
        end

feature -- Input Sources

    from_file (a_path: READABLE_STRING_GENERAL): like Current
            -- Add classes from single .e file.
        require
            path_not_empty: a_path /= Void and then not a_path.is_empty
        local
            parser: SIMPLE_EIFFEL_PARSER
            ast: EIFFEL_AST
        do
            create parser.make
            ast := parser.parse_file (a_path.to_string_8)
            across ast.classes as c loop
                builder.add_class (c)
            end
            graph := builder.graph
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    from_directory (a_path: READABLE_STRING_GENERAL): like Current
            -- Add classes from directory (recursive .e files).
        require
            path_not_empty: a_path /= Void and then not a_path.is_empty
        do
            -- Implementation: scan directory for .e files, parse each
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    from_ast (a_ast: EIFFEL_AST): like Current
            -- Add classes from parsed AST.
        require
            ast_not_void: a_ast /= Void
        do
            graph := builder.build_from_ast (a_ast)
            Result := Current
        ensure
            result_is_current: Result = Current
        end

    from_graph (a_graph: DOT_GRAPH): like Current
            -- Use pre-built DOT graph.
        require
            graph_not_void: a_graph /= Void
        do
            graph := a_graph
            Result := Current
        ensure
            graph_set: graph = a_graph
            result_is_current: Result = Current
        end

feature -- Output

    to_dot: STRING
            -- Generate DOT source string.
        do
            builder.add_inheritance_edges
            Result := graph.to_dot
        ensure
            result_not_empty: Result /= Void and then not Result.is_empty
        end

    to_svg: detachable STRING
            -- Render to SVG string. Void if rendering fails.
        require
            graphviz_available: is_graphviz_available
        local
            result_obj: GRAPHVIZ_RESULT
        do
            result_obj := renderer.render_svg (to_dot)
            if result_obj.is_success then
                Result := result_obj.content
            else
                last_error_internal := result_obj.error_message
            end
        ensure
            success_has_content: Result /= Void implies Result.has_substring ("<svg")
            failure_has_error: Result = Void implies last_error /= Void
        end

    to_svg_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
            -- Render to SVG file. True if successful.
        require
            graphviz_available: is_graphviz_available
            path_not_empty: a_path /= Void and then not a_path.is_empty
        local
            result_obj: GRAPHVIZ_RESULT
        do
            result_obj := renderer.render_svg (to_dot)
            if result_obj.is_success then
                Result := result_obj.save_to_file (a_path.to_string_8)
            else
                last_error_internal := result_obj.error_message
            end
        ensure
            failure_has_error: not Result implies last_error /= Void
        end

    to_pdf_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
            -- Render to PDF file. True if successful.
        require
            graphviz_available: is_graphviz_available
            path_not_empty: a_path /= Void and then not a_path.is_empty
        local
            result_obj: GRAPHVIZ_RESULT
        do
            result_obj := renderer.render_pdf (to_dot)
            if result_obj.is_success then
                Result := result_obj.save_to_file (a_path.to_string_8)
            else
                last_error_internal := result_obj.error_message
            end
        ensure
            failure_has_error: not Result implies last_error /= Void
        end

    to_dot_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
            -- Save DOT source to file.
        require
            path_not_empty: a_path /= Void and then not a_path.is_empty
        local
            file: SIMPLE_FILE
        do
            create file.make (a_path.to_string_8)
            file.write_string (to_dot)
            Result := True
        rescue
            Result := False
            last_error_internal := "Failed to write DOT file"
        end

feature -- Status

    is_graphviz_available: BOOLEAN
            -- Is GraphViz installed and accessible?
        do
            Result := renderer.is_available
        end

    graphviz_version: detachable STRING
            -- GraphViz version string, or Void if not available.
        do
            Result := renderer.version
        end

    last_error: detachable STRING
            -- Error from last operation, or Void if successful.
        do
            Result := last_error_internal
        end

    graph: DOT_GRAPH
            -- The underlying DOT graph.

feature {NONE} -- Implementation

    renderer: GRAPHVIZ_RENDERER
    style: GRAPHVIZ_STYLE
    builder: BON_DIAGRAM_BUILDER
    last_error_internal: detachable STRING

invariant
    graph_exists: graph /= Void
    renderer_exists: renderer /= Void
    style_exists: style /= Void
    builder_exists: builder /= Void

end
```

### DOT_GRAPH

```eiffel
note
    description: "GraphViz DOT graph structure"
    author: "Larry Rix"

class
    DOT_GRAPH

create
    make_digraph,
    make_graph

feature {NONE} -- Initialization

    make_digraph (a_name: STRING)
            -- Create directed graph.
        require
            name_not_empty: a_name /= Void and then not a_name.is_empty
        do
            name := a_name
            is_directed := True
            create nodes.make (20)
            create edges.make (50)
            create subgraphs.make (5)
            create graph_attributes.make
            create node_defaults.make
            create edge_defaults.make
        ensure
            name_set: name.is_equal (a_name)
            is_directed: is_directed
            empty: nodes.is_empty and edges.is_empty
        end

    make_graph (a_name: STRING)
            -- Create undirected graph.
        require
            name_not_empty: a_name /= Void and then not a_name.is_empty
        do
            name := a_name
            is_directed := False
            create nodes.make (20)
            create edges.make (50)
            create subgraphs.make (5)
            create graph_attributes.make
            create node_defaults.make
            create edge_defaults.make
        ensure
            name_set: name.is_equal (a_name)
            not_directed: not is_directed
        end

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
            -- Add node to graph.
        require
            node_not_void: a_node /= Void
            unique_id: not has_node (a_node.id)
        do
            nodes.extend (a_node)
        ensure
            node_added: has_node (a_node.id)
            count_increased: nodes.count = old nodes.count + 1
        end

    add_edge (a_edge: DOT_EDGE)
            -- Add edge to graph.
        require
            edge_not_void: a_edge /= Void
            from_exists: has_node (a_edge.from_id)
            to_exists: has_node (a_edge.to_id)
        do
            edges.extend (a_edge)
        ensure
            edge_added: edges.has (a_edge)
        end

    add_subgraph (a_subgraph: DOT_SUBGRAPH)
            -- Add subgraph/cluster.
        require
            subgraph_not_void: a_subgraph /= Void
        do
            subgraphs.extend (a_subgraph)
        ensure
            subgraph_added: subgraphs.has (a_subgraph)
        end

    set_graph_attribute (a_key, a_value: STRING)
        do
            graph_attributes.put (a_key, a_value)
        end

    set_node_default (a_key, a_value: STRING)
        do
            node_defaults.put (a_key, a_value)
        end

    set_edge_default (a_key, a_value: STRING)
        do
            edge_defaults.put (a_key, a_value)
        end

feature -- Query

    has_node (a_id: STRING): BOOLEAN
            -- Does graph contain node with `a_id`?
        do
            Result := across nodes as n some n.id.is_equal (a_id) end
        end

    node_by_id (a_id: STRING): detachable DOT_NODE
            -- Find node by ID.
        do
            across nodes as n loop
                if n.id.is_equal (a_id) then
                    Result := n
                end
            end
        end

feature -- Output

    to_dot: STRING
            -- Serialize to DOT language.
        do
            create Result.make (1000)
            if is_directed then
                Result.append ("digraph ")
            else
                Result.append ("graph ")
            end
            Result.append (name)
            Result.append (" {%N")

            -- Graph attributes
            if graph_attributes.count > 0 then
                across graph_attributes.items as attr loop
                    Result.append ("  ")
                    Result.append (attr.key)
                    Result.append ("=")
                    Result.append ("%"" + attr.item + "%"")
                    Result.append (";%N")
                end
            end

            -- Node defaults
            if node_defaults.count > 0 then
                Result.append ("  node ")
                Result.append (node_defaults.to_dot)
                Result.append (";%N")
            end

            -- Edge defaults
            if edge_defaults.count > 0 then
                Result.append ("  edge ")
                Result.append (edge_defaults.to_dot)
                Result.append (";%N")
            end

            -- Subgraphs
            across subgraphs as sg loop
                Result.append (sg.to_dot)
            end

            -- Nodes
            across nodes as n loop
                Result.append ("  ")
                Result.append (n.to_dot)
                Result.append ("%N")
            end

            -- Edges
            across edges as e loop
                Result.append ("  ")
                Result.append (e.to_dot (is_directed))
                Result.append ("%N")
            end

            Result.append ("}%N")
        ensure
            result_not_empty: Result /= Void and then not Result.is_empty
        end

invariant
    name_not_empty: name /= Void and then not name.is_empty
    nodes_exist: nodes /= Void
    edges_exist: edges /= Void

end
```

### GRAPHVIZ_RENDERER

```eiffel
note
    description: "GraphViz subprocess renderer"
    author: "Larry Rix"

class
    GRAPHVIZ_RENDERER

create
    make

feature {NONE} -- Initialization

    make
            -- Create with defaults.
        do
            engine := "dot"
            timeout := 30
            use_file_io := False
            create process.make
        ensure
            default_engine: engine.is_equal ("dot")
            default_timeout: timeout = 30
        end

feature -- Configuration

    set_engine (a_engine: STRING)
            -- Set layout engine.
        require
            engine_not_empty: a_engine /= Void and then not a_engine.is_empty
            valid_engine: valid_engines.has (a_engine)
        do
            engine := a_engine
        ensure
            engine_set: engine.is_equal (a_engine)
        end

    set_timeout (a_seconds: INTEGER)
            -- Set execution timeout.
        require
            positive: a_seconds > 0
        do
            timeout := a_seconds
        ensure
            timeout_set: timeout = a_seconds
        end

    set_use_file_io (a_value: BOOLEAN)
            -- Use file-based I/O instead of pipes.
        do
            use_file_io := a_value
        end

feature -- Status

    is_available: BOOLEAN
            -- Is GraphViz installed?
        local
            output: STRING_32
        do
            output := process.output_of_command ("dot -V")
            Result := process.was_successful and then
                      output.has_substring ("graphviz")
        end

    version: detachable STRING
            -- GraphViz version string.
        local
            output: STRING_32
        do
            output := process.output_of_command ("dot -V")
            if process.was_successful then
                Result := output.to_string_8
            end
        end

    engine: STRING
    timeout: INTEGER
    use_file_io: BOOLEAN

feature -- Rendering

    render (a_dot: STRING; a_format: STRING): GRAPHVIZ_RESULT
            -- Render DOT to specified format.
        require
            dot_not_empty: a_dot /= Void and then not a_dot.is_empty
            format_valid: valid_formats.has (a_format)
            available: is_available
        local
            command: STRING
            output: STRING_32
        do
            -- Write DOT to temp file, render, read result
            command := engine + " -T" + a_format + " temp_input.dot -o temp_output." + a_format
            -- ... implementation using simple_process and simple_file

            if process.was_successful then
                create Result.make_success (output.to_string_8, a_format)
            else
                create Result.make_failure (process.last_error.to_string_8, a_format)
            end
        ensure
            result_not_void: Result /= Void
        end

    render_svg (a_dot: STRING): GRAPHVIZ_RESULT
            -- Render DOT to SVG.
        require
            dot_not_empty: a_dot /= Void and then not a_dot.is_empty
        do
            Result := render (a_dot, "svg")
        end

    render_pdf (a_dot: STRING): GRAPHVIZ_RESULT
            -- Render DOT to PDF.
        require
            dot_not_empty: a_dot /= Void and then not a_dot.is_empty
        do
            Result := render (a_dot, "pdf")
        end

feature -- Constants

    valid_engines: ARRAY [STRING]
        once
            Result := <<"dot", "neato", "fdp", "circo", "twopi", "osage">>
        end

    valid_formats: ARRAY [STRING]
        once
            Result := <<"svg", "pdf", "png", "ps", "eps">>
        end

feature {NONE} -- Implementation

    process: SIMPLE_PROCESS

invariant
    engine_not_empty: engine /= Void and then not engine.is_empty
    timeout_positive: timeout > 0

end
```

## Dependencies

| Library | Purpose | Version |
|---------|---------|---------|
| simple_mml | MML postconditions | 1.0.1+ |
| simple_eiffel_parser | Parse .e files | 1.0.0+ |
| simple_process | Subprocess execution | 1.0.0+ |
| simple_file | File I/O | 1.0.0+ |
| simple_pdf | PDF export (optional) | 1.0.0+ |
| base | Core data structures | ISE 25.02 |

## File Structure

```
simple_graphviz/
├── src/
│   ├── simple_graphviz.e         (Facade)
│   ├── dot_graph.e               (Graph structure)
│   ├── dot_node.e                (Node structure)
│   ├── dot_edge.e                (Edge structure)
│   ├── dot_subgraph.e            (Cluster structure)
│   ├── dot_attributes.e          (Attribute helper)
│   ├── graphviz_renderer.e       (Subprocess engine)
│   ├── graphviz_result.e         (Result object)
│   ├── graphviz_style.e          (Style presets)
│   └── bon_diagram_builder.e     (AST adapter)
├── testing/
│   ├── test_dot_graph.e          (DOT structure tests)
│   ├── test_graphviz_renderer.e  (Renderer tests)
│   ├── test_bon_builder.e        (Builder tests)
│   ├── test_simple_graphviz.e    (Integration tests)
│   └── application.e             (Test runner)
├── simple_graphviz.ecf           (Library config)
├── README.md
├── CHANGELOG.md
└── LICENSE
```
