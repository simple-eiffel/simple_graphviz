# S03: CONTRACTS - simple_graphviz

**Document**: S03-CONTRACTS.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## SIMPLE_GRAPHVIZ Contracts

### Class Invariant
```eiffel
invariant
    renderer_not_void: renderer /= Void
```

### Configuration
```eiffel
set_engine (a_engine: STRING): like Current
    require
        engine_not_void: a_engine /= Void
        engine_valid: renderer.is_valid_engine (a_engine)
    ensure
        engine_set: renderer.engine.same_string (a_engine)
        result_is_current: Result = Current
```

### Builder Access
```eiffel
flowchart: FLOWCHART_BUILDER
    ensure
        result_not_void: Result /= Void

graph: DOT_GRAPH
    ensure
        result_not_void: Result /= Void
        is_directed: Result.is_directed
```

## DOT_GRAPH Contracts

### Class Invariant
```eiffel
invariant
    name_not_void: name /= Void
    name_not_empty: not name.is_empty
    attributes_not_void: attributes /= Void
    internal_nodes_not_void: internal_nodes /= Void
    internal_edges_not_void: internal_edges /= Void
    internal_subgraphs_not_void: internal_subgraphs /= Void
```

### Creation
```eiffel
make_digraph (a_name: STRING)
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
    ensure
        name_set: name.same_string (a_name)
        is_directed: is_directed
        no_nodes: node_count = 0
        no_edges: edge_count = 0
```

### Element Change
```eiffel
add_node (a_node: DOT_NODE)
    require
        node_not_void: a_node /= Void
        not_duplicate: not has_node (a_node.id)
    ensure
        node_added: has_node (a_node.id)
        count_incremented: node_count = old node_count + 1
        edges_unchanged: edges_model |=| old edges_model

new_edge (a_from, a_to: STRING): DOT_EDGE
    require
        from_not_void: a_from /= Void
        from_not_empty: not a_from.is_empty
        to_not_void: a_to /= Void
        to_not_empty: not a_to.is_empty
    ensure
        result_not_void: Result /= Void
        edge_added: edge_count = old edge_count + 1
```

## GRAPHVIZ_RENDERER Contracts

### Class Invariant
```eiffel
invariant
    timeout_positive: timeout_ms > 0
    engine_not_void: engine /= Void
    engine_valid: is_valid_engine (engine)
```

### Rendering
```eiffel
render_svg (a_dot: STRING): GRAPHVIZ_RESULT
    require
        dot_not_void: a_dot /= Void
    ensure
        result_not_void: Result /= Void
```
