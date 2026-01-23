note
	description: "[
		Builder for dependency graphs showing library/package relationships.
		Note: MML verification happens at the DOT_GRAPH level, not in builders.
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	DEPENDENCY_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
			-- Create builder with `a_renderer`.
		require
			renderer_not_void: a_renderer /= Void
		do
			renderer := a_renderer
			create graph.make_digraph ("Dependencies")
			graph.attributes.put ("rankdir", "TB")
			show_external := True
			create internal_clusters.make (5)
		ensure
			renderer_set: renderer = a_renderer
			show_external_default: show_external
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Renderer for producing output.

	graph: DOT_GRAPH
			-- Graph being built.

	show_external: BOOLEAN
			-- Show external library dependencies?

feature -- Configuration

	set_show_external (a_value: BOOLEAN): like Current
			-- Set whether to show external dependencies.
		do
			show_external := a_value
			Result := Current
		ensure
			show_external_set: show_external = a_value
			result_is_current: Result = Current
		end

	set_title (a_title: STRING): like Current
			-- Set diagram title.
		require
			title_not_void: a_title /= Void
		do
			graph.attributes.put ("label", a_title)
			Result := Current
		ensure
			title_set: graph.attributes.has ("label")
			result_is_current: Result = Current
		end

feature -- Building from ECF

	from_ecf (a_path: STRING): like Current
			-- Parse ECF file and add dependencies.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			-- Implementation in Phase 4:
			-- 1. Parse ECF XML
			-- 2. Extract library dependencies
			-- 3. Categorize as internal vs external
			-- 4. Add nodes and edges
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Manual Building

	add_library (a_name: STRING; a_is_external: BOOLEAN)
			-- Add a library node.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		local
			l_node: DOT_NODE
		do
			l_node := graph.new_node (a_name)
			l_node.attributes.put ("label", a_name)
			l_node.attributes.put ("shape", "box")

			if a_is_external then
				l_node.attributes.put ("style", "filled")
				l_node.attributes.put ("fillcolor", "lightgray")
			else
				l_node.attributes.put ("style", "filled")
				l_node.attributes.put ("fillcolor", "lightblue")
			end
		ensure
			library_added: graph.has_node (a_name)
		end

	add_dependency (a_from, a_to: STRING)
			-- Add dependency edge from `a_from` to `a_to`.
		require
			from_not_void: a_from /= Void
			to_not_void: a_to /= Void
		local
			l_edge: DOT_EDGE
		do
			l_edge := graph.new_edge (a_from, a_to)
			l_edge.attributes.put ("style", "dashed")
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
		end

	add_cluster (a_name: STRING; a_libraries: ITERABLE [STRING])
			-- Add a cluster (subgraph) grouping libraries.
		require
			name_not_void: a_name /= Void
			libraries_not_void: a_libraries /= Void
		local
			l_subgraph: DOT_SUBGRAPH
			l_node: DOT_NODE
		do
			create l_subgraph.make_cluster (a_name)
			l_subgraph.attributes.put ("label", a_name)
			l_subgraph.attributes.put ("style", "filled")
			l_subgraph.attributes.put ("fillcolor", "lightyellow")

			across a_libraries as ic loop
				if not graph.has_node (ic) then
					create l_node.make (ic)
					l_node.attributes.put ("label", ic)
					l_node.attributes.put ("shape", "box")
					l_subgraph.add_node (l_node)
				end
			end

			graph.add_subgraph (l_subgraph)
			internal_clusters.extend (l_subgraph)
		ensure
			cluster_added: graph.has_subgraph (a_name)
		end

feature -- Output

	to_dot: STRING
			-- Generate DOT source.
		do
			Result := graph.to_dot
		ensure
			not_void: Result /= Void
		end

	to_svg: GRAPHVIZ_RESULT
			-- Render to SVG.
		do
			Result := renderer.render_svg (graph.to_dot)
		ensure
			result_not_void: Result /= Void
		end

	to_svg_file (a_path: STRING): GRAPHVIZ_RESULT
			-- Render to SVG file.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			Result := renderer.render_to_file (graph.to_dot, "svg", a_path)
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	internal_clusters: ARRAYED_LIST [DOT_SUBGRAPH]
			-- Clusters added to the graph.

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void
	internal_clusters_not_void: internal_clusters /= Void

end
