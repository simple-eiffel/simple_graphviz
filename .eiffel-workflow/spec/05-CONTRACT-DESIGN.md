# CONTRACT DESIGN: simple_graphviz

## MML Model Queries

For collections requiring frame conditions:

| Class | Attribute | Type | Model Query | MML Type |
|-------|-----------|------|-------------|----------|
| DOT_GRAPH | nodes | ARRAYED_LIST | nodes_model | MML_SEQUENCE |
| DOT_GRAPH | edges | ARRAYED_LIST | edges_model | MML_SEQUENCE |
| DOT_GRAPH | subgraphs | ARRAYED_LIST | subgraphs_model | MML_SEQUENCE |
| DOT_ATTRIBUTES | items | HASH_TABLE | items_model | MML_MAP |
| DOT_SUBGRAPH | nodes | ARRAYED_LIST | nodes_model | MML_SEQUENCE |

## Class Contracts

### SIMPLE_GRAPHVIZ (Facade)

**Creation Contract:**
```eiffel
make
    ensure
        not_configured: graph.nodes.is_empty
        default_style: style.name.is_equal ("bon")
        default_engine: renderer.engine.is_equal ("dot")
        default_timeout: renderer.timeout = 30
```

**Configuration Contracts:**
```eiffel
title (a_title: READABLE_STRING_GENERAL): like Current
    require
        title_not_empty: a_title /= Void and then not a_title.is_empty
    ensure
        title_set: graph.graph_attributes.item ("label").is_equal (a_title.to_string_8)
        result_is_current: Result = Current

style_bon: like Current
    ensure
        style_is_bon: style.name.is_equal ("bon")
        result_is_current: Result = Current

from_file (a_path: READABLE_STRING_GENERAL): like Current
    require
        path_not_empty: a_path /= Void and then not a_path.is_empty
        file_exists: (create {RAW_FILE}.make (a_path.to_string_8)).exists
    ensure
        classes_added: graph.nodes.count >= old graph.nodes.count
        result_is_current: Result = Current

from_directory (a_path: READABLE_STRING_GENERAL): like Current
    require
        path_not_empty: a_path /= Void and then not a_path.is_empty
        directory_exists: (create {DIRECTORY}.make (a_path.to_string_8)).exists
    ensure
        result_is_current: Result = Current
```

**Output Contracts:**
```eiffel
to_dot: STRING
    ensure
        result_not_empty: Result /= Void and then not Result.is_empty
        valid_dot: Result.starts_with ("digraph") or Result.starts_with ("graph")

to_svg: detachable STRING
    require
        graphviz_available: is_graphviz_available
    ensure
        success_has_content: Result /= Void implies Result.has_substring ("<svg")
        failure_has_error: Result = Void implies last_error /= Void

to_svg_file (a_path: READABLE_STRING_GENERAL): BOOLEAN
    require
        graphviz_available: is_graphviz_available
        path_not_empty: a_path /= Void and then not a_path.is_empty
    ensure
        success_file_exists: Result implies (create {RAW_FILE}.make (a_path.to_string_8)).exists
        failure_has_error: not Result implies last_error /= Void
```

**Status Contracts:**
```eiffel
is_graphviz_available: BOOLEAN
    -- Pure query, no preconditions needed

last_error: detachable STRING
    -- Pure query, no preconditions needed
```

**Invariant:**
```eiffel
invariant
    graph_exists: graph /= Void
    renderer_exists: renderer /= Void
    style_exists: style /= Void
    builder_exists: builder /= Void
```

### DOT_GRAPH

**Creation Contracts:**
```eiffel
make_digraph (a_name: STRING)
    require
        name_not_empty: a_name /= Void and then not a_name.is_empty
    ensure
        name_set: name.is_equal (a_name)
        is_directed: is_directed
        empty_nodes: nodes.is_empty
        empty_edges: edges.is_empty

make_graph (a_name: STRING)
    require
        name_not_empty: a_name /= Void and then not a_name.is_empty
    ensure
        name_set: name.is_equal (a_name)
        not_directed: not is_directed
        empty_nodes: nodes.is_empty
```

**Modification Contracts:**
```eiffel
add_node (a_node: DOT_NODE)
    require
        node_not_void: a_node /= Void
        unique_id: not has_node (a_node.id)
    ensure
        node_added: has_node (a_node.id)
        count_increased: nodes.count = old nodes.count + 1
        others_unchanged: nodes_model.remove (nodes.count) |=| old nodes_model

add_edge (a_edge: DOT_EDGE)
    require
        edge_not_void: a_edge /= Void
        from_exists: has_node (a_edge.from_id)
        to_exists: has_node (a_edge.to_id)
    ensure
        edge_added: edges.has (a_edge)
        count_increased: edges.count = old edges.count + 1
        nodes_unchanged: nodes_model |=| old nodes_model
```

**Output Contracts:**
```eiffel
to_dot: STRING
    ensure
        result_not_empty: Result /= Void and then not Result.is_empty
        starts_with_graph: (is_directed implies Result.starts_with ("digraph"))
                           and (not is_directed implies Result.starts_with ("graph"))
        contains_name: Result.has_substring (name)
        ends_with_brace: Result.ends_with ("}")
```

**Invariant:**
```eiffel
invariant
    name_not_empty: name /= Void and then not name.is_empty
    nodes_exist: nodes /= Void
    edges_exist: edges /= Void
    subgraphs_exist: subgraphs /= Void
    all_edge_endpoints_valid: across edges as e all has_node (e.from_id) and has_node (e.to_id) end
```

### DOT_NODE

**Creation Contract:**
```eiffel
make (a_id: STRING)
    require
        id_not_empty: a_id /= Void and then not a_id.is_empty
    ensure
        id_set: id.is_equal (a_id)
        no_label: label = Void
        empty_attributes: attributes.count = 0
```

**Modification Contracts:**
```eiffel
set_label (a_label: STRING)
    require
        label_not_void: a_label /= Void
    ensure
        label_set: attached label as l and then l.is_equal (a_label)

set_attribute (a_key, a_value: STRING)
    require
        key_not_empty: a_key /= Void and then not a_key.is_empty
        value_not_void: a_value /= Void
    ensure
        attribute_set: attached attributes.item (a_key) as v and then v.is_equal (a_value)
```

**Output Contract:**
```eiffel
to_dot: STRING
    ensure
        result_not_empty: Result /= Void
        contains_id: Result.has_substring (id)
```

**Invariant:**
```eiffel
invariant
    id_not_empty: id /= Void and then not id.is_empty
    attributes_exist: attributes /= Void
```

### DOT_EDGE

**Creation Contract:**
```eiffel
make (a_from, a_to: STRING)
    require
        from_not_empty: a_from /= Void and then not a_from.is_empty
        to_not_empty: a_to /= Void and then not a_to.is_empty
    ensure
        from_set: from_id.is_equal (a_from)
        to_set: to_id.is_equal (a_to)
        empty_attributes: attributes.count = 0
```

**Output Contract:**
```eiffel
to_dot (a_directed: BOOLEAN): STRING
    ensure
        result_not_empty: Result /= Void
        contains_from: Result.has_substring (from_id)
        contains_to: Result.has_substring (to_id)
        correct_arrow: (a_directed implies Result.has_substring ("->"))
                       and (not a_directed implies Result.has_substring ("--"))
```

**Invariant:**
```eiffel
invariant
    from_not_empty: from_id /= Void and then not from_id.is_empty
    to_not_empty: to_id /= Void and then not to_id.is_empty
    attributes_exist: attributes /= Void
```

### GRAPHVIZ_RENDERER

**Creation Contract:**
```eiffel
make
    ensure
        default_engine: engine.is_equal ("dot")
        default_timeout: timeout = 30
        not_using_file_io: not use_file_io
```

**Configuration Contracts:**
```eiffel
set_engine (a_engine: STRING)
    require
        engine_not_empty: a_engine /= Void and then not a_engine.is_empty
        valid_engine: valid_engines.has (a_engine)
    ensure
        engine_set: engine.is_equal (a_engine)

set_timeout (a_seconds: INTEGER)
    require
        positive: a_seconds > 0
    ensure
        timeout_set: timeout = a_seconds
```

**Rendering Contracts:**
```eiffel
render (a_dot: STRING; a_format: STRING): GRAPHVIZ_RESULT
    require
        dot_not_empty: a_dot /= Void and then not a_dot.is_empty
        format_valid: valid_formats.has (a_format)
        graphviz_available: is_available
    ensure
        result_not_void: Result /= Void
        result_format: Result.format.is_equal (a_format)
```

**Invariant:**
```eiffel
invariant
    engine_not_empty: engine /= Void and then not engine.is_empty
    timeout_positive: timeout > 0
    valid_engine: valid_engines.has (engine)
```

### GRAPHVIZ_RESULT

**Creation Contracts:**
```eiffel
make_success (a_content: STRING; a_format: STRING)
    require
        content_not_void: a_content /= Void
        format_not_empty: a_format /= Void and then not a_format.is_empty
    ensure
        is_success: is_success
        content_set: content = a_content
        no_error: error_message = Void
        format_set: format.is_equal (a_format)

make_failure (a_error: STRING; a_format: STRING)
    require
        error_not_empty: a_error /= Void and then not a_error.is_empty
        format_not_empty: a_format /= Void and then not a_format.is_empty
    ensure
        not_success: not is_success
        no_content: content = Void
        error_set: attached error_message as e and then e.is_equal (a_error)
        format_set: format.is_equal (a_format)
```

**Invariant:**
```eiffel
invariant
    success_xor_error: is_success xor (error_message /= Void)
    success_has_content: is_success implies content /= Void
    format_not_empty: format /= Void and then not format.is_empty
```

### BON_DIAGRAM_BUILDER

**Creation Contract:**
```eiffel
make
    ensure
        default_style: style.name.is_equal ("bon")
        include_features: include_features = False
        include_private: include_private = False
        show_inheritance: show_inheritance = True
```

**Building Contracts:**
```eiffel
build_from_ast (a_ast: EIFFEL_AST): DOT_GRAPH
    require
        ast_not_void: a_ast /= Void
    ensure
        result_not_void: Result /= Void
        has_nodes: Result.nodes.count >= a_ast.classes.count

add_class (a_class: EIFFEL_CLASS_NODE)
    require
        class_not_void: a_class /= Void
        graph_exists: graph /= Void
    ensure
        class_added: graph.has_node (a_class.name)
```

## Contract Completeness Checklist

Every postcondition must answer:
- [x] **What changed?** (direct effect)
- [x] **How did it change?** (relationship to `old` state)
- [x] **What did NOT change?** (frame conditions via MML `|=|`)

## Escaping Utility Contract

```eiffel
-- In DOT_ATTRIBUTES class
escape_value (a_value: STRING): STRING
    require
        value_not_void: a_value /= Void
    ensure
        result_not_void: Result /= Void
        quotes_escaped: a_value.has ('"') implies Result.has_substring ("\%"")
        backslashes_escaped: a_value.has ('\') implies Result.has_substring ("\\")
        newlines_escaped: a_value.has ('%N') implies Result.has_substring ("\n")
```
