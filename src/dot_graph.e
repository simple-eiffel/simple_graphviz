note
	description: "A complete DOT graph structure with nodes, edges, and subgraphs"
	author: "Larry Rix"
	date: "2026-01-22"

class
	DOT_GRAPH

create
	make_digraph, make_graph

feature {NONE} -- Initialization

	make_digraph (a_name: STRING)
			-- Create directed graph with `a_name`.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			is_directed := True
			create attributes.make
			create internal_nodes.make (20)
			create internal_edges.make (30)
			create internal_subgraphs.make (5)
		ensure
			name_set: name.same_string (a_name)
			is_directed: is_directed
			no_nodes: node_count = 0
			no_edges: edge_count = 0
			no_subgraphs: subgraph_count = 0
		end

	make_graph (a_name: STRING)
			-- Create undirected graph with `a_name`.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			is_directed := False
			create attributes.make
			create internal_nodes.make (20)
			create internal_edges.make (30)
			create internal_subgraphs.make (5)
		ensure
			name_set: name.same_string (a_name)
			not_directed: not is_directed
			no_nodes: node_count = 0
			no_edges: edge_count = 0
			no_subgraphs: subgraph_count = 0
		end

feature -- Access

	name: STRING
			-- Graph name.

	is_directed: BOOLEAN
			-- Is this a directed graph (digraph)?

	attributes: DOT_ATTRIBUTES
			-- Graph-level attributes.

	node_count: INTEGER
			-- Number of nodes.
		do
			Result := internal_nodes.count
		ensure
			non_negative: Result >= 0
		end

	edge_count: INTEGER
			-- Number of edges.
		do
			Result := internal_edges.count
		ensure
			non_negative: Result >= 0
		end

	subgraph_count: INTEGER
			-- Number of subgraphs.
		do
			Result := internal_subgraphs.count
		ensure
			non_negative: Result >= 0
		end

	node (a_id: STRING): detachable DOT_NODE
			-- Node with `a_id`, or Void if not found.
		require
			id_not_void: a_id /= Void
		do
			across internal_nodes as ic until Result /= Void loop
				if ic.id.same_string (a_id) then
					Result := ic
				end
			end
		ensure
			found_if_has: has_node (a_id) implies Result /= Void
			correct_id: attached Result as n implies n.id.same_string (a_id)
		end

feature -- Model Queries

	nodes_model: MML_SEQUENCE [DOT_NODE]
			-- Mathematical model of nodes.
		do
			create Result.default_create
			across internal_nodes as ic loop
				Result := Result & ic
			end
		end

	edges_model: MML_SEQUENCE [DOT_EDGE]
			-- Mathematical model of edges.
		do
			create Result.default_create
			across internal_edges as ic loop
				Result := Result & ic
			end
		end

	subgraphs_model: MML_SEQUENCE [DOT_SUBGRAPH]
			-- Mathematical model of subgraphs.
		do
			create Result.default_create
			across internal_subgraphs as ic loop
				Result := Result & ic
			end
		end

	node_ids_model: MML_SET [STRING]
			-- Set of all node identifiers.
		do
			create Result.default_create
			across internal_nodes as ic loop
				Result := Result & ic.id
			end
		end

feature -- Status Report

	has_node (a_id: STRING): BOOLEAN
			-- Is there a node with `a_id`?
		require
			id_not_void: a_id /= Void
		do
			Result := across internal_nodes as ic some ic.id.same_string (a_id) end
		ensure
			definition: Result = node_ids_model.has (a_id)
		end

	has_subgraph (a_id: STRING): BOOLEAN
			-- Is there a subgraph with `a_id`?
		require
			id_not_void: a_id /= Void
		do
			Result := across internal_subgraphs as ic some ic.id.same_string (a_id) end
		end

	is_empty: BOOLEAN
			-- Does this graph have no nodes?
		do
			Result := internal_nodes.is_empty
		ensure
			definition: Result = (node_count = 0)
		end

feature -- Graph Attribute Setters

	set_rankdir (a_direction: STRING): like Current
			-- Set layout direction (TB, BT, LR, RL).
		require
			direction_not_void: a_direction /= Void
		do
			attributes.put ("rankdir", a_direction)
			Result := Current
		ensure
			rankdir_set: attributes.has ("rankdir")
			result_is_current: Result = Current
		end

	set_bgcolor (a_color: STRING): like Current
			-- Set background color.
		require
			color_not_void: a_color /= Void
		do
			attributes.put ("bgcolor", a_color)
			Result := Current
		ensure
			bgcolor_set: attributes.has ("bgcolor")
			result_is_current: Result = Current
		end

	set_splines (a_splines: STRING): like Current
			-- Set edge routing (ortho, polyline, spline, line, none).
		require
			splines_not_void: a_splines /= Void
		do
			attributes.put ("splines", a_splines)
			Result := Current
		ensure
			splines_set: attributes.has ("splines")
			result_is_current: Result = Current
		end

	set_nodesep (a_sep: REAL): like Current
			-- Set minimum horizontal distance between nodes.
		require
			sep_positive: a_sep > 0
		do
			attributes.put ("nodesep", a_sep.out)
			Result := Current
		ensure
			nodesep_set: attributes.has ("nodesep")
			result_is_current: Result = Current
		end

	set_ranksep (a_sep: REAL): like Current
			-- Set minimum vertical distance between ranks.
		require
			sep_positive: a_sep > 0
		do
			attributes.put ("ranksep", a_sep.out)
			Result := Current
		ensure
			ranksep_set: attributes.has ("ranksep")
			result_is_current: Result = Current
		end

feature -- Element Change

	add_node (a_node: DOT_NODE)
			-- Add `a_node` to the graph.
		require
			node_not_void: a_node /= Void
			not_duplicate: not has_node (a_node.id)
		do
			internal_nodes.extend (a_node)
		ensure
			node_added: has_node (a_node.id)
			count_incremented: node_count = old node_count + 1
			edges_unchanged: edges_model |=| old edges_model
			subgraphs_unchanged: subgraphs_model |=| old subgraphs_model
		end

	add_edge (a_edge: DOT_EDGE)
			-- Add `a_edge` to the graph.
			-- Note: DOT allows edges to reference non-existent nodes (implicit node creation).
			-- This is intentional per DOT specification.
		require
			edge_not_void: a_edge /= Void
		do
			internal_edges.extend (a_edge)
		ensure
			edge_added: edge_count = old edge_count + 1
			nodes_unchanged: nodes_model |=| old nodes_model
			subgraphs_unchanged: subgraphs_model |=| old subgraphs_model
		end

	add_subgraph (a_subgraph: DOT_SUBGRAPH)
			-- Add `a_subgraph` to the graph.
		require
			subgraph_not_void: a_subgraph /= Void
			not_duplicate: not has_subgraph (a_subgraph.id)
		do
			internal_subgraphs.extend (a_subgraph)
		ensure
			subgraph_added: has_subgraph (a_subgraph.id)
			count_incremented: subgraph_count = old subgraph_count + 1
			nodes_unchanged: nodes_model |=| old nodes_model
			edges_unchanged: edges_model |=| old edges_model
		end

	new_node (a_id: STRING): DOT_NODE
			-- Create and add a new node with `a_id`.
		require
			id_not_void: a_id /= Void
			id_not_empty: not a_id.is_empty
			not_duplicate: not has_node (a_id)
		do
			create Result.make (a_id)
			add_node (Result)
		ensure
			result_not_void: Result /= Void
			result_id: Result.id.same_string (a_id)
			node_added: has_node (a_id)
		end

	new_edge (a_from, a_to: STRING): DOT_EDGE
			-- Create and add a new edge from `a_from` to `a_to`.
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		do
			create Result.make (a_from, a_to)
			add_edge (Result)
		ensure
			result_not_void: Result /= Void
			result_from: Result.from_id.same_string (a_from)
			result_to: Result.to_id.same_string (a_to)
			edge_added: edge_count = old edge_count + 1
		end

feature -- Conversion

	to_dot: STRING
			-- Complete DOT language representation.
		local
			l_type: STRING
		do
			if is_directed then
				l_type := "digraph"
			else
				l_type := "graph"
			end

			create Result.make (500)
			Result.append_string (l_type)
			Result.append_character (' ')
			Result.append_string (attributes.escape_value (name))
			Result.append_string (" {%N")

			-- Graph attributes
			across internal_table_from_attributes.current_keys as key loop
				if attached internal_table_from_attributes.item (key) as l_value then
					Result.append_string ("    ")
					Result.append_string (key)
					Result.append_character ('=')
					Result.append_string (attributes.escape_value (l_value))
					Result.append_string (";%N")
				end
			end

			-- Subgraphs
			across internal_subgraphs as ic loop
				Result.append_string (ic.to_dot (is_directed, "    "))
				Result.append_string ("%N")
			end

			-- Nodes
			across internal_nodes as ic loop
				Result.append_string ("    ")
				Result.append_string (ic.to_dot)
				Result.append_string (";%N")
			end

			-- Edges
			across internal_edges as ic loop
				Result.append_string ("    ")
				Result.append_string (ic.to_dot (is_directed))
				Result.append_string (";%N")
			end

			Result.append_character ('}')
		ensure
			not_void: Result /= Void
			has_graph_type: is_directed implies Result.has_substring ("digraph")
			has_undirected_type: not is_directed implies Result.has_substring ("graph")
			has_name: Result.has_substring (name) or Result.has_substring (attributes.escape_value (name))
		end

feature {NONE} -- Implementation

	internal_nodes: ARRAYED_LIST [DOT_NODE]
			-- Nodes in this graph.

	internal_edges: ARRAYED_LIST [DOT_EDGE]
			-- Edges in this graph.

	internal_subgraphs: ARRAYED_LIST [DOT_SUBGRAPH]
			-- Subgraphs in this graph.

	internal_table_from_attributes: HASH_TABLE [STRING, STRING]
			-- Access to attributes internal table for iteration.
		do
			Result := attributes.internal_table
		end

invariant
	name_not_void: name /= Void
	name_not_empty: not name.is_empty
	attributes_not_void: attributes /= Void
	internal_nodes_not_void: internal_nodes /= Void
	internal_edges_not_void: internal_edges /= Void
	internal_subgraphs_not_void: internal_subgraphs /= Void

end
