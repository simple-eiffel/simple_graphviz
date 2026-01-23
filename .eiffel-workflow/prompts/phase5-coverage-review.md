# Test Coverage Review

## Contracts

### DOT_ATTRIBUTES
- `make`: Creates empty attributes table
- `put (key, value)`: Adds/updates attribute
- `has (key)`: Returns true if key exists
- `item (key)`: Returns value for key
- `to_dot`: Serializes to DOT format
- `escape_value`: Escapes special characters

### DOT_NODE
- `make (id)`: Creates node with id
- `set_label`, `set_shape`, `set_color`: Fluent attribute setters
- `to_dot`: Serializes to DOT format

### DOT_EDGE
- `make (from, to)`: Creates edge
- `to_dot (directed)`: Serializes with -> or --

### DOT_GRAPH
- `make_digraph`, `make_graph`: Creates directed/undirected graph
- `add_node`, `add_edge`: Add elements
- `new_node`, `new_edge`: Create and add elements
- `has_node`, `has_subgraph`: Queries
- `to_dot`: Full DOT serialization

### DOT_SUBGRAPH
- `make`, `make_cluster`: Creates subgraph
- `add_node`: Adds node to subgraph

### GRAPHVIZ_RENDERER
- `make`: Creates with default engine (dot) and timeout (30s)
- `set_engine`, `set_timeout`: Configuration
- `is_graphviz_available`: Checks if dot -V works
- `graphviz_version`: Parses version string
- `is_version_sufficient`: Checks >= 2.40
- `render`, `render_svg`, `render_pdf`, `render_png`: Rendering
- `render_to_file`: Direct file output

### GRAPHVIZ_RESULT
- `make_success (content)`: Creates success result
- `make_failure (error)`: Creates failure result
- `is_success`, `is_failure`: Status queries
- `content`: Output content
- `error`: Error information
- `save_to_file`: Saves content to file
- Invariant: `is_success xor (error /= Void)`

### GRAPHVIZ_ERROR
- `make (code, message)`: Creates error
- Error codes: graphviz_not_found, timeout, invalid_dot, output_error, unknown_error

### GRAPHVIZ_STYLE
- `make_bon`, `make_uml`: Creates predefined styles

### BON_DIAGRAM_BUILDER
- `make (renderer)`: Creates builder
- `add_class`, `add_inheritance`: Build diagram
- `set_style`, `include_feature_signatures`: Configuration
- `from_file`, `from_directory`: Source parsing (DEFERRED)
- `to_dot`, `to_svg`, `to_svg_file`: Output

### FLOWCHART_BUILDER
- `make (renderer)`: Creates builder
- `start`, `end_node`, `process`, `decision`, `io_node`: Node types
- `link`, `link_yes`, `link_no`: Manual linking

### STATE_MACHINE_BUILDER
- `make (renderer)`: Creates builder
- `initial`, `state`, `final`: State types
- `transition`, `self_transition`: Transitions

### DEPENDENCY_BUILDER
- `make (renderer)`: Creates builder
- `add_library`, `add_dependency`, `add_cluster`: Build elements
- `from_ecf`: ECF parsing (DEFERRED)

### INHERITANCE_BUILDER
- `make (renderer)`: Creates builder
- `add_class`, `add_inheritance`: Build tree
- `root_class`, `filter_to_root`: Filtering
- `from_file`, `from_directory`: Source parsing (DEFERRED)

## Tests

Total: 50 tests across 5 categories

### DOT Graph Tests (16 tests)
- attributes_empty, attributes_put_get, attributes_to_dot, attributes_escape
- node_creation, node_fluent, node_to_dot
- edge_creation, edge_directed, edge_undirected
- graph_digraph, graph_add_nodes, graph_new_node, graph_to_dot, graph_undirected
- subgraph_cluster

### Builder Tests (17 tests)
- BON: creation, add_class, add_deferred, add_inheritance, to_dot
- Flowchart: creation, basic, decision
- State Machine: creation, states, transitions
- Dependency: creation, add_libraries
- Inheritance: creation, add_classes, root_filter

### Facade Tests (9 tests)
- creation, builder_access, graph_access, undirected_graph
- engine_setting, timeout_setting
- bon_workflow, state_machine_workflow, flowchart_workflow

### SCOOP Tests (1 test)
- scoop_compatibility

### Renderer Tests (8 tests)
- creation, engine_setting, timeout_setting
- version_parsing, result_success, result_failure, error_types
- graphviz_available (conditional)

## Check For

- [x] Postconditions verified by tests (all key features tested)
- [x] Edge cases tested (empty attributes, version comparison edge cases)
- [ ] Source parsing tests (DEFERRED - requires simple_eiffel_parser)
- [ ] Actual render tests (requires GraphViz installation)
- [x] Precondition boundary tests (engine validation, timeout > 0)

## Coverage Gaps

1. **Source Parsing** (DEFERRED): `from_file`, `from_directory`, `from_ecf` are stub implementations
2. **Actual Rendering**: Tests skip actual GraphViz calls if not installed
3. **save_to_file**: GRAPHVIZ_RESULT.save_to_file not tested
4. **filter_to_root**: INHERITANCE_BUILDER.filter_to_root stub not tested
