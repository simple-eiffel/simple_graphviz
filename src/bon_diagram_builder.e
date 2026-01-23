note
	description: "[
		Builder for BON (Business Object Notation) class diagrams from Eiffel source.
		Note: MML verification happens at the DOT_GRAPH level, not in builders.
		Builders delegate to DOT_GRAPH which has proper MML model queries.
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	BON_DIAGRAM_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
			-- Create builder with `a_renderer`.
		require
			renderer_not_void: a_renderer /= Void
		do
			renderer := a_renderer
			create style.make_bon
			create graph.make_digraph ("BON_Diagram")
			include_features := False
			graph.set_rankdir ("TB").do_nothing
		ensure
			renderer_set: renderer = a_renderer
			style_is_bon: style.name.same_string ("bon")
			not_include_features: not include_features
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Renderer for producing output.

	style: GRAPHVIZ_STYLE
			-- Visual style (BON by default).

	graph: DOT_GRAPH
			-- Graph being built.

	include_features: BOOLEAN
			-- Should class features be shown in labels?

feature -- Configuration

	set_include_features (a_value: BOOLEAN): like Current
			-- Set whether to include features in class labels.
		do
			include_features := a_value
			Result := Current
		ensure
			include_features_set: include_features = a_value
			result_is_current: Result = Current
		end

	set_style (a_style: GRAPHVIZ_STYLE): like Current
			-- Set visual style.
		require
			style_not_void: a_style /= Void
		do
			style := a_style
			Result := Current
		ensure
			style_set: style = a_style
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

feature -- Building from Source

	from_file (a_path: STRING): like Current
			-- Add classes from Eiffel file at `a_path`.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			-- Implementation in Phase 4:
			-- 1. Use simple_eiffel_parser to parse file
			-- 2. Extract class info
			-- 3. Call add_class for each
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	from_directory (a_path: STRING): like Current
			-- Add classes from all .e files in directory.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			-- Implementation in Phase 4:
			-- 1. Find all .e files
			-- 2. Call from_file for each
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Manual Building

	add_class (a_name: STRING; a_is_deferred, a_is_expanded: BOOLEAN)
			-- Add a class node.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		local
			l_node: DOT_NODE
		do
			l_node := graph.new_node (a_name)
			l_node.set_label (a_name).do_nothing
			style.apply_to_class_node (l_node, a_is_deferred, a_is_expanded)
		ensure
			class_added: graph.has_node (a_name)
		end

	add_class_with_features (a_name: STRING; a_features: ITERABLE [STRING]; a_is_deferred, a_is_expanded: BOOLEAN)
			-- Add a class node with feature list.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			features_not_void: a_features /= Void
			not_duplicate: not graph.has_node (a_name)
		local
			l_node: DOT_NODE
			l_label: STRING
		do
			l_node := graph.new_node (a_name)

			if include_features then
				create l_label.make (a_name.count + 50)
				l_label.append_string (a_name)
				l_label.append_character ('%N')
				across a_features as ic loop
					l_label.append_string (ic)
					l_label.append_character ('%N')
				end
				l_node.set_label (l_label).do_nothing
			else
				l_node.set_label (a_name).do_nothing
			end

			style.apply_to_class_node (l_node, a_is_deferred, a_is_expanded)
		ensure
			class_added: graph.has_node (a_name)
		end

	add_inheritance (a_child, a_parent: STRING)
			-- Add inheritance edge from child to parent.
		require
			child_not_void: a_child /= Void
			parent_not_void: a_parent /= Void
		local
			l_edge: DOT_EDGE
		do
			l_edge := graph.new_edge (a_child, a_parent)
			style.apply_to_inheritance_edge (l_edge)
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
		end

	add_client_supplier (a_client, a_supplier: STRING; a_label: detachable STRING)
			-- Add client-supplier edge.
		require
			client_not_void: a_client /= Void
			supplier_not_void: a_supplier /= Void
		local
			l_edge: DOT_EDGE
		do
			l_edge := graph.new_edge (a_client, a_supplier)
			style.apply_to_client_edge (l_edge)
			if attached a_label as l then
				l_edge.set_label (l).do_nothing
			end
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
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

	to_pdf_file (a_path: STRING): GRAPHVIZ_RESULT
			-- Render to PDF file.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			Result := renderer.render_to_file (graph.to_dot, "pdf", a_path)
		ensure
			result_not_void: Result /= Void
		end

invariant
	renderer_not_void: renderer /= Void
	style_not_void: style /= Void
	graph_not_void: graph /= Void

end
