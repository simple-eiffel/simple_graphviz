# Eiffel Contract Review Request (Ollama)

You are reviewing Eiffel contracts for a GraphViz library. Find obvious problems.

## Eiffel Background

Eiffel uses Design by Contract:
- `require` = preconditions (caller's responsibility)
- `ensure` = postconditions (callee's guarantee)
- `invariant` = class invariant (always true)
- `old X` = value of X before the call
- MML = Mathematical Model Library for precise postconditions
- `|=|` = MML model equality (same contents)

## Review Checklist

- [ ] Preconditions that are too weak (just `True` or missing)
- [ ] Postconditions that don't constrain anything meaningful
- [ ] Missing invariants on stateful classes
- [ ] Edge cases not handled (empty input, null, duplicates)
- [ ] Missing MML model queries for collection attributes
- [ ] Missing frame conditions (what did NOT change after operation)
- [ ] Contracts that can't be verified at runtime

## Contracts to Review

### DOT_ATTRIBUTES (Key-value pairs with escaping)

```eiffel
class DOT_ATTRIBUTES

inherit
	ANY redefine default_create end

create
	make, default_create

feature {NONE} -- Initialization

	default_create
		do make
		ensure then is_empty: count = 0
		end

	make
		do create internal_table.make (10)
		ensure is_empty: count = 0
		end

feature -- Model Queries

	attributes_model: MML_MAP [STRING, STRING]
		do
			create Result.default_create
			across internal_table as ic loop
				Result := Result.updated (@ic.key, ic)
			end
		end

feature -- Access

	item alias "[]" (a_key: STRING): detachable STRING
		require key_not_void: a_key /= Void
		do Result := internal_table.item (a_key)
		ensure result_if_has: has (a_key) implies Result /= Void
		end

	count: INTEGER
		do Result := internal_table.count
		ensure non_negative: Result >= 0
		end

feature -- Status Report

	is_empty: BOOLEAN
		do Result := internal_table.is_empty
		ensure definition: Result = (count = 0)
		end

	has (a_key: STRING): BOOLEAN
		require key_not_void: a_key /= Void
		do Result := internal_table.has (a_key)
		ensure definition: Result = attributes_model.domain.has (a_key)
		end

feature -- Element Change

	put (a_key, a_value: STRING)
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do internal_table.force (a_value, a_key)
		ensure
			has_key: has (a_key)
			value_set: attached item (a_key) as v implies v.same_string (a_value)
			others_unchanged: attributes_model.removed (a_key).domain |=| old attributes_model.removed (a_key).domain
		end

	remove (a_key: STRING)
		require key_not_void: a_key /= Void
		do internal_table.remove (a_key)
		ensure
			not_has: not has (a_key)
			others_unchanged: attributes_model |=| old attributes_model.removed (a_key)
		end

feature -- Conversion

	to_dot: STRING
		local l_first: BOOLEAN
		do
			if is_empty then
				create Result.make_empty
			else
				create Result.make (50)
				Result.append_character ('[')
				l_first := True
				across internal_table as ic loop
					if not l_first then Result.append_string (", ") end
					Result.append_string (@ic.key)
					Result.append_character ('=')
					Result.append_string (escape_value (ic))
					l_first := False
				end
				Result.append_character (']')
			end
		ensure
			not_void: Result /= Void
			empty_if_none: is_empty implies Result.is_empty
			bracketed_if_any: not is_empty implies (Result.starts_with ("[") and Result.ends_with ("]"))
		end

feature -- Utilities

	escape_value (a_value: STRING): STRING
		require value_not_void: a_value /= Void
		-- Escapes quotes, backslashes, newlines; quotes if needed
		ensure
			not_void: Result /= Void
			not_shorter: Result.count >= a_value.count
		end

feature {DOT_GRAPH, DOT_SUBGRAPH} -- Implementation

	internal_table: HASH_TABLE [STRING, STRING]

invariant
	internal_table_exists: internal_table /= Void
	count_consistent: count = internal_table.count

end
```

### DOT_NODE (Graph node with attributes)

```eiffel
class DOT_NODE

create make

feature {NONE} -- Initialization

	make (a_id: STRING)
		require
			id_not_void: a_id /= Void
			id_not_empty: not a_id.is_empty
		do
			id := a_id
			create attributes.make
		ensure
			id_set: id.same_string (a_id)
			no_attributes: attributes.is_empty
		end

feature -- Access

	id: STRING
	attributes: DOT_ATTRIBUTES

	label: detachable STRING
		do Result := attributes ["label"] end

	shape: detachable STRING
		do Result := attributes ["shape"] end

feature -- Common Attribute Setters (all return like Current for fluent API)

	set_label (a_label: STRING): like Current
		require label_not_void: a_label /= Void
		do attributes.put ("label", a_label); Result := Current
		ensure
			label_set: attached label as l implies l.same_string (a_label)
			result_is_current: Result = Current
		end

	set_shape (a_shape: STRING): like Current
		require shape_not_void: a_shape /= Void
		do attributes.put ("shape", a_shape); Result := Current
		ensure
			shape_set: attached shape as s implies s.same_string (a_shape)
			result_is_current: Result = Current
		end

	-- Similar: set_color, set_fillcolor, set_style, set_fontname, set_fontsize,
	-- set_width, set_height, set_penwidth (all follow same pattern)

	set_attribute (a_key, a_value: STRING): like Current
		require
			key_not_void: a_key /= Void
			key_not_empty: not a_key.is_empty
			value_not_void: a_value /= Void
		do attributes.put (a_key, a_value); Result := Current
		ensure
			attribute_set: attributes.has (a_key)
			result_is_current: Result = Current
		end

feature -- Conversion

	to_dot: STRING
		do
			create Result.make (50)
			Result.append_string (attributes.escape_value (id))
			if not attributes.is_empty then
				Result.append_character (' ')
				Result.append_string (attributes.to_dot)
			end
		ensure
			not_void: Result /= Void
			contains_id: Result.has_substring (id) or Result.has_substring (attributes.escape_value (id))
		end

invariant
	id_not_void: id /= Void
	id_not_empty: not id.is_empty
	attributes_not_void: attributes /= Void

end
```

### DOT_EDGE (Edge between nodes)

```eiffel
class DOT_EDGE

create make

feature {NONE} -- Initialization

	make (a_from, a_to: STRING)
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		do
			from_id := a_from
			to_id := a_to
			create attributes.make
		ensure
			from_set: from_id.same_string (a_from)
			to_set: to_id.same_string (a_to)
			no_attributes: attributes.is_empty
		end

feature -- Access

	from_id: STRING
	to_id: STRING
	attributes: DOT_ATTRIBUTES

	label: detachable STRING
		do Result := attributes ["label"] end

feature -- Common Attribute Setters (fluent API, like DOT_NODE)

	set_label, set_color, set_style, set_arrowhead, set_arrowtail,
	set_penwidth, set_fontname, set_fontsize, set_constraint, set_dir,
	set_attribute
	-- All follow same pattern as DOT_NODE

feature -- Conversion

	to_dot (a_directed: BOOLEAN): STRING
		-- Uses "->" for directed, "--" for undirected
		ensure
			not_void: Result /= Void
			has_connector: a_directed implies Result.has_substring ("->")
			has_undirected_connector: not a_directed implies Result.has_substring ("--")
		end

invariant
	from_id_not_void: from_id /= Void
	from_id_not_empty: not from_id.is_empty
	to_id_not_void: to_id /= Void
	to_id_not_empty: not to_id.is_empty
	attributes_not_void: attributes /= Void

end
```

### DOT_SUBGRAPH (Cluster grouping)

```eiffel
class DOT_SUBGRAPH

create make, make_cluster

feature {NONE} -- Initialization

	make (a_id: STRING)
		require
			id_not_void: a_id /= Void
			id_not_empty: not a_id.is_empty
		do
			id := a_id
			is_cluster := False
			create attributes.make
			create internal_nodes.make (10)
			create internal_edges.make (10)
		ensure
			id_set: id.same_string (a_id)
			not_cluster: not is_cluster
			no_nodes: node_count = 0
			no_edges: edge_count = 0
		end

	make_cluster (a_id: STRING)
		require
			id_not_void: a_id /= Void
			id_not_empty: not a_id.is_empty
		do
			make (a_id)
			is_cluster := True
		ensure
			id_set: id.same_string (a_id)
			is_cluster: is_cluster
			no_nodes: node_count = 0
			no_edges: edge_count = 0
		end

feature -- Access

	id: STRING
	is_cluster: BOOLEAN
	attributes: DOT_ATTRIBUTES
	node_count: INTEGER  -- from internal_nodes.count
	edge_count: INTEGER  -- from internal_edges.count

feature -- Model Queries

	nodes_model: MML_SEQUENCE [DOT_NODE]
	edges_model: MML_SEQUENCE [DOT_EDGE]

feature -- Status Report

	has_node (a_id: STRING): BOOLEAN
		require id_not_void: a_id /= Void

feature -- Element Change

	add_node (a_node: DOT_NODE)
		require
			node_not_void: a_node /= Void
			not_has_node: not has_node (a_node.id)
		ensure
			node_added: has_node (a_node.id)
			count_incremented: node_count = old node_count + 1
			edges_unchanged: edges_model |=| old edges_model
		end

	add_edge (a_edge: DOT_EDGE)
		require edge_not_void: a_edge /= Void
		ensure
			edge_added: edge_count = old edge_count + 1
			nodes_unchanged: nodes_model |=| old nodes_model
		end

feature -- Conversion

	to_dot (a_directed: BOOLEAN; a_indent: STRING): STRING
		require indent_not_void: a_indent /= Void
		ensure
			not_void: Result /= Void
			has_subgraph: Result.has_substring ("subgraph")
			has_cluster_prefix: is_cluster implies Result.has_substring ("cluster_")
		end

invariant
	id_not_void: id /= Void
	id_not_empty: not id.is_empty
	attributes_not_void: attributes /= Void
	internal_nodes_not_void: internal_nodes /= Void
	internal_edges_not_void: internal_edges /= Void

end
```

### DOT_GRAPH (Complete graph structure)

```eiffel
class DOT_GRAPH

create make_digraph, make_graph

feature {NONE} -- Initialization

	make_digraph (a_name: STRING)
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		ensure
			name_set: name.same_string (a_name)
			is_directed: is_directed
			no_nodes: node_count = 0
			no_edges: edge_count = 0
			no_subgraphs: subgraph_count = 0
		end

	make_graph (a_name: STRING)
		-- Same preconditions, ensures not is_directed

feature -- Access

	name: STRING
	is_directed: BOOLEAN
	attributes: DOT_ATTRIBUTES
	node_count, edge_count, subgraph_count: INTEGER

	node (a_id: STRING): detachable DOT_NODE
		require id_not_void: a_id /= Void
		ensure
			found_if_has: has_node (a_id) implies Result /= Void
			correct_id: attached Result as n implies n.id.same_string (a_id)
		end

feature -- Model Queries

	nodes_model: MML_SEQUENCE [DOT_NODE]
	edges_model: MML_SEQUENCE [DOT_EDGE]
	subgraphs_model: MML_SEQUENCE [DOT_SUBGRAPH]
	node_ids_model: MML_SET [STRING]

feature -- Status Report

	has_node (a_id: STRING): BOOLEAN
		require id_not_void: a_id /= Void
		ensure definition: Result = node_ids_model.has (a_id)
		end

	has_subgraph (a_id: STRING): BOOLEAN
		require id_not_void: a_id /= Void

	is_empty: BOOLEAN
		ensure definition: Result = (node_count = 0)
		end

feature -- Graph Attribute Setters (fluent API)

	set_rankdir (a_direction: STRING): like Current
		require direction_not_void: a_direction /= Void
		ensure
			rankdir_set: attributes.has ("rankdir")
			result_is_current: Result = Current
		end

	-- Similar: set_bgcolor, set_splines, set_nodesep, set_ranksep

feature -- Element Change

	add_node (a_node: DOT_NODE)
		require
			node_not_void: a_node /= Void
			not_duplicate: not has_node (a_node.id)
		ensure
			node_added: has_node (a_node.id)
			count_incremented: node_count = old node_count + 1
			edges_unchanged: edges_model |=| old edges_model
			subgraphs_unchanged: subgraphs_model |=| old subgraphs_model
		end

	add_edge (a_edge: DOT_EDGE)
		require edge_not_void: a_edge /= Void
		ensure
			edge_added: edge_count = old edge_count + 1
			nodes_unchanged: nodes_model |=| old nodes_model
			subgraphs_unchanged: subgraphs_model |=| old subgraphs_model
		end

	add_subgraph (a_subgraph: DOT_SUBGRAPH)
		require
			subgraph_not_void: a_subgraph /= Void
			not_duplicate: not has_subgraph (a_subgraph.id)
		ensure
			subgraph_added: has_subgraph (a_subgraph.id)
			count_incremented: subgraph_count = old subgraph_count + 1
			nodes_unchanged: nodes_model |=| old nodes_model
			edges_unchanged: edges_model |=| old edges_model
		end

	new_node (a_id: STRING): DOT_NODE
		require
			id_not_void: a_id /= Void
			id_not_empty: not a_id.is_empty
			not_duplicate: not has_node (a_id)
		ensure
			result_not_void: Result /= Void
			result_id: Result.id.same_string (a_id)
			node_added: has_node (a_id)
		end

	new_edge (a_from, a_to: STRING): DOT_EDGE
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		ensure
			result_not_void: Result /= Void
			result_from: Result.from_id.same_string (a_from)
			result_to: Result.to_id.same_string (a_to)
			edge_added: edge_count = old edge_count + 1
		end

feature -- Conversion

	to_dot: STRING
		ensure
			not_void: Result /= Void
			has_graph_type: is_directed implies Result.has_substring ("digraph")
			has_undirected_type: not is_directed implies Result.has_substring ("graph")
			has_name: Result.has_substring (name) or Result.has_substring (attributes.escape_value (name))
		end

invariant
	name_not_void: name /= Void
	name_not_empty: not name.is_empty
	attributes_not_void: attributes /= Void
	internal_nodes_not_void: internal_nodes /= Void
	internal_edges_not_void: internal_edges /= Void
	internal_subgraphs_not_void: internal_subgraphs /= Void

end
```

### GRAPHVIZ_ERROR (Error codes)

```eiffel
class GRAPHVIZ_ERROR

create make

feature {NONE} -- Initialization

	make (a_code: INTEGER; a_message: STRING)
		require
			valid_code: is_valid_error_code (a_code)
			message_not_void: a_message /= Void
		ensure
			code_set: code = a_code
			message_set: message.same_string (a_message)
		end

feature -- Access

	code: INTEGER
	message: STRING

feature -- Error Codes

	Graphviz_not_found: INTEGER = 1
	Timeout: INTEGER = 2
	Invalid_dot: INTEGER = 3
	Output_error: INTEGER = 4
	Version_mismatch: INTEGER = 5
	Unknown_error: INTEGER = 99

feature -- Status Report

	is_valid_error_code (a_code: INTEGER): BOOLEAN
	is_graphviz_not_found: BOOLEAN ensure definition: Result = (code = Graphviz_not_found) end
	is_timeout: BOOLEAN ensure definition: Result = (code = Timeout) end
	is_invalid_dot: BOOLEAN ensure definition: Result = (code = Invalid_dot) end
	is_output_error: BOOLEAN ensure definition: Result = (code = Output_error) end
	is_version_mismatch: BOOLEAN ensure definition: Result = (code = Version_mismatch) end

feature -- Conversion

	to_string: STRING
		ensure
			not_void: Result /= Void
			has_code: Result.has_substring (code.out)
			has_message: Result.has_substring (message)
		end

invariant
	valid_code: is_valid_error_code (code)
	message_not_void: message /= Void

end
```

### GRAPHVIZ_RESULT (Render result)

```eiffel
class GRAPHVIZ_RESULT

create make_success, make_failure

feature {NONE} -- Initialization

	make_success (a_content: STRING)
		require content_not_void: a_content /= Void
		ensure
			is_success: is_success
			content_set: attached content as c implies c.same_string (a_content)
			no_error: error = Void
		end

	make_failure (a_error: GRAPHVIZ_ERROR)
		require error_not_void: a_error /= Void
		ensure
			is_failure: not is_success
			no_content: content = Void
			error_set: error = a_error
		end

feature -- Access

	is_success: BOOLEAN
	content: detachable STRING
	error: detachable GRAPHVIZ_ERROR

feature -- Status Report

	is_failure: BOOLEAN
		ensure definition: Result = not is_success
		end

feature -- Operations

	save_to_file (a_path: STRING): BOOLEAN
		require
			is_success: is_success
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		-- Cannot express file existence in contract

invariant
	success_xor_error: is_success xor (error /= Void)
	success_has_content: is_success implies content /= Void

end
```

### GRAPHVIZ_RENDERER (Subprocess execution)

```eiffel
class GRAPHVIZ_RENDERER

inherit ANY redefine default_create end

create make, default_create

feature {NONE} -- Initialization

	make
		ensure
			default_timeout: timeout_ms = 30_000
			default_engine: engine.same_string ("dot")
		end

feature -- Access

	timeout_ms: INTEGER
	engine: STRING

feature -- Configuration

	set_timeout (a_ms: INTEGER): like Current
		require positive: a_ms > 0
		ensure
			timeout_set: timeout_ms = a_ms
			result_is_current: Result = Current
		end

	set_engine (a_engine: STRING): like Current
		require
			engine_not_void: a_engine /= Void
			engine_valid: is_valid_engine (a_engine)
		ensure
			engine_set: engine.same_string (a_engine)
			result_is_current: Result = Current
		end

feature -- Status Report

	is_graphviz_available: BOOLEAN
	graphviz_version: detachable STRING
	is_valid_engine (a_engine: STRING): BOOLEAN
		require engine_not_void: a_engine /= Void
	is_version_sufficient: BOOLEAN

feature -- Rendering

	render_svg (a_dot: STRING): GRAPHVIZ_RESULT
		require dot_not_void: a_dot /= Void
		ensure result_not_void: Result /= Void
		end

	render_pdf (a_dot: STRING): GRAPHVIZ_RESULT
		require dot_not_void: a_dot /= Void
		ensure result_not_void: Result /= Void
		end

	render_png (a_dot: STRING): GRAPHVIZ_RESULT
		require dot_not_void: a_dot /= Void
		ensure result_not_void: Result /= Void
		end

	render (a_dot, a_format: STRING): GRAPHVIZ_RESULT
		require
			dot_not_void: a_dot /= Void
			format_not_void: a_format /= Void
			format_valid: a_format.same_string ("svg") or a_format.same_string ("pdf") or a_format.same_string ("png")
		ensure result_not_void: Result /= Void
		end

	render_to_file (a_dot, a_format, a_path: STRING): GRAPHVIZ_RESULT
		require
			dot_not_void: a_dot /= Void
			format_not_void: a_format /= Void
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		ensure result_not_void: Result /= Void
		end

invariant
	timeout_positive: timeout_ms > 0
	engine_not_void: engine /= Void
	engine_valid: is_valid_engine (engine)

end
```

### GRAPHVIZ_STYLE (Visual presets)

```eiffel
class GRAPHVIZ_STYLE

create make_bon, make_uml, make_minimal, make_default

feature {NONE} -- Initialization

	make_bon
		ensure
			name_set: name.same_string ("bon")
			class_shape_ellipse: class_shape.same_string ("ellipse")
		end

	make_uml
		ensure
			name_set: name.same_string ("uml")
			class_shape_record: class_shape.same_string ("record")
		end

	make_minimal
		ensure name_set: name.same_string ("minimal")
		end

	make_default
		ensure name_set: name.same_string ("default")
		end

feature -- Access

	name: STRING
	class_shape, class_style, class_fillcolor: STRING
	deferred_style, expanded_fillcolor: STRING
	inheritance_arrowhead, client_arrowhead: STRING
	fontname: STRING
	fontsize: INTEGER

feature -- Application

	apply_to_class_node (a_node: DOT_NODE; a_is_deferred, a_is_expanded: BOOLEAN)
		require node_not_void: a_node /= Void
		-- Applies shape, style, fillcolor, font based on flags

	apply_to_inheritance_edge (a_edge: DOT_EDGE)
		require edge_not_void: a_edge /= Void

	apply_to_client_edge (a_edge: DOT_EDGE)
		require edge_not_void: a_edge /= Void

	apply_defaults_to_graph (a_graph: DOT_GRAPH)
		require graph_not_void: a_graph /= Void

invariant
	name_not_void: name /= Void
	class_shape_not_void: class_shape /= Void
	fontsize_positive: fontsize > 0

end
```

### BON_DIAGRAM_BUILDER

```eiffel
class BON_DIAGRAM_BUILDER

create make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
		require renderer_not_void: a_renderer /= Void
		ensure
			renderer_set: renderer = a_renderer
			style_is_bon: style.name.same_string ("bon")
			not_include_features: not include_features
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
	style: GRAPHVIZ_STYLE
	graph: DOT_GRAPH
	include_features: BOOLEAN

feature -- Configuration

	set_include_features (a_value: BOOLEAN): like Current
		ensure
			include_features_set: include_features = a_value
			result_is_current: Result = Current
		end

	set_style (a_style: GRAPHVIZ_STYLE): like Current
		require style_not_void: a_style /= Void
		ensure
			style_set: style = a_style
			result_is_current: Result = Current
		end

	set_title (a_title: STRING): like Current
		require title_not_void: a_title /= Void
		ensure
			title_set: graph.attributes.has ("label")
			result_is_current: Result = Current
		end

feature -- Building from Source

	from_file (a_path: STRING): like Current
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		ensure result_is_current: Result = Current
		end

	from_directory (a_path: STRING): like Current
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		ensure result_is_current: Result = Current
		end

feature -- Manual Building

	add_class (a_name: STRING; a_is_deferred, a_is_expanded: BOOLEAN)
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		ensure class_added: graph.has_node (a_name)
		end

	add_class_with_features (a_name: STRING; a_features: ITERABLE [STRING]; a_is_deferred, a_is_expanded: BOOLEAN)
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			features_not_void: a_features /= Void
			not_duplicate: not graph.has_node (a_name)
		ensure class_added: graph.has_node (a_name)
		end

	add_inheritance (a_child, a_parent: STRING)
		require
			child_not_void: a_child /= Void
			parent_not_void: a_parent /= Void
		ensure edge_added: graph.edge_count = old graph.edge_count + 1
		end

	add_client_supplier (a_client, a_supplier: STRING; a_label: detachable STRING)
		require
			client_not_void: a_client /= Void
			supplier_not_void: a_supplier /= Void
		ensure edge_added: graph.edge_count = old graph.edge_count + 1
		end

feature -- Output

	to_dot: STRING
		ensure not_void: Result /= Void
		end

	to_svg: GRAPHVIZ_RESULT
		ensure result_not_void: Result /= Void
		end

	to_svg_file (a_path: STRING): GRAPHVIZ_RESULT
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		ensure result_not_void: Result /= Void
		end

invariant
	renderer_not_void: renderer /= Void
	style_not_void: style /= Void
	graph_not_void: graph /= Void

end
```

### FLOWCHART_BUILDER

```eiffel
class FLOWCHART_BUILDER

create make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
		require renderer_not_void: a_renderer /= Void
		ensure renderer_set: renderer = a_renderer
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
	graph: DOT_GRAPH
	last_node_id: detachable STRING

feature -- Status Report

	has_decision: BOOLEAN
		-- Is there a recent decision node for linking?

feature -- Building

	start (a_label: STRING): like Current
		require label_not_void: a_label /= Void
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	end_node (a_label: STRING): like Current
		require label_not_void: a_label /= Void
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	process (a_label: STRING): like Current
		require label_not_void: a_label /= Void
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	decision (a_label, a_yes_label, a_no_label: STRING): like Current
		require
			label_not_void: a_label /= Void
			yes_label_not_void: a_yes_label /= Void
			no_label_not_void: a_no_label /= Void
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	io_node (a_label: STRING): like Current
		require label_not_void: a_label /= Void
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

feature -- Manual Linking

	link (a_from, a_to: STRING): like Current
		require
			from_not_void: a_from /= Void
			to_not_void: a_to /= Void
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
			result_is_current: Result = Current
		end

	link_yes (a_target_id: STRING): like Current
		require
			target_not_void: a_target_id /= Void
			decision_exists: has_decision
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
			result_is_current: Result = Current
		end

	link_no (a_target_id: STRING): like Current
		require
			target_not_void: a_target_id /= Void
			decision_exists: has_decision
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
			result_is_current: Result = Current
		end

feature -- Output

	to_dot: STRING
		ensure not_void: Result /= Void
		end

	to_svg: GRAPHVIZ_RESULT
		ensure result_not_void: Result /= Void
		end

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void

end
```

### STATE_MACHINE_BUILDER

```eiffel
class STATE_MACHINE_BUILDER

create make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
		require renderer_not_void: a_renderer /= Void
		ensure renderer_set: renderer = a_renderer
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
	graph: DOT_GRAPH
	initial_state_name: detachable STRING

feature -- Model Queries

	states_model: MML_SET [STRING]
		-- Set of all state names (excludes internal nodes like __initial__)

feature -- Status Report

	has_state (a_name: STRING): BOOLEAN
		require name_not_void: a_name /= Void

feature -- Building

	initial (a_name: STRING): like Current
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		ensure
			initial_set: attached initial_state_name as i implies i.same_string (a_name)
			state_exists: has_state (a_name)
			result_is_current: Result = Current
		end

	state (a_name: STRING): like Current
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		ensure
			state_added: has_state (a_name)
			result_is_current: Result = Current
		end

	final (a_name: STRING): like Current
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		ensure
			state_added: has_state (a_name)
			result_is_current: Result = Current
		end

	transition (a_from, a_to, a_label: STRING): like Current
		require
			from_not_void: a_from /= Void
			to_not_void: a_to /= Void
			label_not_void: a_label /= Void
		ensure
			from_exists: has_state (a_from)
			to_exists: has_state (a_to)
			edge_added: graph.edge_count > old graph.edge_count
			result_is_current: Result = Current
		end

	self_transition (a_state, a_label: STRING): like Current
		require
			state_not_void: a_state /= Void
			label_not_void: a_label /= Void
		ensure result_is_current: Result = Current
		end

feature -- Configuration

	set_title (a_title: STRING): like Current
		require title_not_void: a_title /= Void
		ensure
			title_set: graph.attributes.has ("label")
			result_is_current: Result = Current
		end

	set_direction (a_direction: STRING): like Current
		require direction_not_void: a_direction /= Void
		ensure result_is_current: Result = Current
		end

feature -- Output

	to_dot: STRING
		ensure not_void: Result /= Void
		end

	to_svg: GRAPHVIZ_RESULT
		ensure result_not_void: Result /= Void
		end

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void

end
```

### DEPENDENCY_BUILDER & INHERITANCE_BUILDER

(Similar patterns to other builders - graph construction with node/edge operations and fluent API)

### SIMPLE_GRAPHVIZ (Facade)

```eiffel
class SIMPLE_GRAPHVIZ

inherit ANY redefine default_create end

create make, default_create

feature {NONE} -- Initialization

	make
		ensure
			renderer_exists: renderer /= Void
			graphviz_checked: True
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER

feature -- Status Report

	is_graphviz_available: BOOLEAN
	graphviz_version: detachable STRING

feature -- Configuration

	set_engine (a_engine: STRING): like Current
		require
			engine_not_void: a_engine /= Void
			engine_valid: renderer.is_valid_engine (a_engine)
		ensure
			engine_set: renderer.engine.same_string (a_engine)
			result_is_current: Result = Current
		end

	set_timeout (a_ms: INTEGER): like Current
		require positive: a_ms > 0
		ensure
			timeout_set: renderer.timeout_ms = a_ms
			result_is_current: Result = Current
		end

feature -- Builder Access

	bon_diagram: BON_DIAGRAM_BUILDER
		ensure result_not_void: Result /= Void
		end

	flowchart: FLOWCHART_BUILDER
		ensure result_not_void: Result /= Void
		end

	state_machine: STATE_MACHINE_BUILDER
		ensure result_not_void: Result /= Void
		end

	dependency_graph: DEPENDENCY_BUILDER
		ensure result_not_void: Result /= Void
		end

	inheritance_tree: INHERITANCE_BUILDER
		ensure result_not_void: Result /= Void
		end

	graph: DOT_GRAPH
		ensure
			result_not_void: Result /= Void
			is_directed: Result.is_directed
		end

	undirected_graph: DOT_GRAPH
		ensure
			result_not_void: Result /= Void
			not_directed: not Result.is_directed
		end

feature -- Direct Rendering

	render_svg (a_dot: STRING): GRAPHVIZ_RESULT
		require dot_not_void: a_dot /= Void
		ensure result_not_void: Result /= Void
		end

	render_pdf (a_dot: STRING): GRAPHVIZ_RESULT
		require dot_not_void: a_dot /= Void
		ensure result_not_void: Result /= Void
		end

	render_png (a_dot: STRING): GRAPHVIZ_RESULT
		require dot_not_void: a_dot /= Void
		ensure result_not_void: Result /= Void
		end

	render_to_file (a_dot, a_format, a_path: STRING): GRAPHVIZ_RESULT
		require
			dot_not_void: a_dot /= Void
			format_not_void: a_format /= Void
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		ensure result_not_void: Result /= Void
		end

invariant
	renderer_not_void: renderer /= Void

end
```

## Implementation Approach

```
SIMPLE_GRAPHVIZ (Facade)
    │
    ├── Builders → DOT Core → to_dot → String
    │
    └── GRAPHVIZ_RENDERER → subprocess: dot -T{format} → GRAPHVIZ_RESULT
```

Key implementation points:
1. DOT Core classes already serialize to valid DOT strings
2. GRAPHVIZ_RENDERER uses subprocess via simple_process
3. Fluent API uses `.do_nothing` to discard unused results
4. MML model queries for collection frame conditions
5. GRAPHVIZ_RESULT uses XOR invariant (success xor error)

## Output Format

List issues found as:
- **ISSUE**: [description]
- **LOCATION**: [class.feature]
- **SEVERITY**: [HIGH/MEDIUM/LOW]
- **SUGGESTION**: [how to fix]

Focus on contract completeness, edge cases, and MML correctness.
