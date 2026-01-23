note
	description: "A subgraph (cluster) in a DOT graph for grouping nodes"
	author: "Larry Rix"
	date: "2026-01-22"

class
	DOT_SUBGRAPH

create
	make, make_cluster

feature {NONE} -- Initialization

	make (a_id: STRING)
			-- Create subgraph with `a_id`.
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
			-- Create cluster subgraph with `a_id`.
			-- Note: The `cluster_` prefix is recommended for visual grouping in GraphViz,
			-- but not enforced by this class. DOT supports non-cluster subgraphs.
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
			-- Subgraph identifier.

	is_cluster: BOOLEAN
			-- Is this a cluster (drawn with border)?

	attributes: DOT_ATTRIBUTES
			-- Subgraph attributes (label, style, color, etc.).

	node_count: INTEGER
			-- Number of nodes in this subgraph.
		do
			Result := internal_nodes.count
		ensure
			non_negative: Result >= 0
		end

	edge_count: INTEGER
			-- Number of edges in this subgraph.
		do
			Result := internal_edges.count
		ensure
			non_negative: Result >= 0
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

feature -- Status Report

	has_node (a_id: STRING): BOOLEAN
			-- Is there a node with `a_id`?
		require
			id_not_void: a_id /= Void
		do
			Result := across internal_nodes as ic some ic.id.same_string (a_id) end
		end

feature -- Common Attribute Setters

	set_label (a_label: STRING): like Current
			-- Set subgraph label.
		require
			label_not_void: a_label /= Void
		do
			attributes.put ("label", a_label)
			Result := Current
		ensure
			label_set: attributes.has ("label")
			result_is_current: Result = Current
		end

	set_style (a_style: STRING): like Current
			-- Set subgraph style.
		require
			style_not_void: a_style /= Void
		do
			attributes.put ("style", a_style)
			Result := Current
		ensure
			style_set: attributes.has ("style")
			result_is_current: Result = Current
		end

	set_color (a_color: STRING): like Current
			-- Set border color.
		require
			color_not_void: a_color /= Void
		do
			attributes.put ("color", a_color)
			Result := Current
		ensure
			color_set: attributes.has ("color")
			result_is_current: Result = Current
		end

	set_fillcolor (a_color: STRING): like Current
			-- Set background color.
		require
			color_not_void: a_color /= Void
		do
			attributes.put ("fillcolor", a_color)
			Result := Current
		ensure
			fillcolor_set: attributes.has ("fillcolor")
			result_is_current: Result = Current
		end

feature -- Element Change

	add_node (a_node: DOT_NODE)
			-- Add `a_node` to this subgraph.
		require
			node_not_void: a_node /= Void
			not_has_node: not has_node (a_node.id)
		do
			internal_nodes.extend (a_node)
		ensure
			node_added: has_node (a_node.id)
			count_incremented: node_count = old node_count + 1
			edges_unchanged: edges_model |=| old edges_model
		end

	add_edge (a_edge: DOT_EDGE)
			-- Add `a_edge` to this subgraph.
		require
			edge_not_void: a_edge /= Void
		do
			internal_edges.extend (a_edge)
		ensure
			edge_added: edge_count = old edge_count + 1
			nodes_unchanged: nodes_model |=| old nodes_model
		end

feature -- Conversion

	to_dot (a_directed: BOOLEAN; a_indent: STRING): STRING
			-- DOT format string for this subgraph.
		require
			indent_not_void: a_indent /= Void
		local
			l_name: STRING
		do
			create Result.make (200)

			-- Subgraph header
			if is_cluster then
				l_name := "cluster_" + id
			else
				l_name := id
			end
			Result.append_string (a_indent)
			Result.append_string ("subgraph ")
			Result.append_string (attributes.escape_value (l_name))
			Result.append_string (" {%N")

			-- Attributes
			across internal_table_from_attributes as ic loop
				Result.append_string (a_indent)
				Result.append_string ("    ")
				Result.append_string (@ic.key)
				Result.append_character ('=')
				Result.append_string (attributes.escape_value (ic))
				Result.append_string (";%N")
			end

			-- Nodes
			across internal_nodes as ic loop
				Result.append_string (a_indent)
				Result.append_string ("    ")
				Result.append_string (ic.to_dot)
				Result.append_string (";%N")
			end

			-- Edges
			across internal_edges as ic loop
				Result.append_string (a_indent)
				Result.append_string ("    ")
				Result.append_string (ic.to_dot (a_directed))
				Result.append_string (";%N")
			end

			Result.append_string (a_indent)
			Result.append_character ('}')
		ensure
			not_void: Result /= Void
			has_subgraph: Result.has_substring ("subgraph")
			has_cluster_prefix: is_cluster implies Result.has_substring ("cluster_")
		end

feature {NONE} -- Implementation

	internal_nodes: ARRAYED_LIST [DOT_NODE]
			-- Nodes in this subgraph.

	internal_edges: ARRAYED_LIST [DOT_EDGE]
			-- Edges in this subgraph.

	internal_table_from_attributes: HASH_TABLE [STRING, STRING]
			-- Access to attributes internal table for iteration.
		do
			Result := attributes.internal_table
		end

invariant
	id_not_void: id /= Void
	id_not_empty: not id.is_empty
	attributes_not_void: attributes /= Void
	internal_nodes_not_void: internal_nodes /= Void
	internal_edges_not_void: internal_edges /= Void

end
