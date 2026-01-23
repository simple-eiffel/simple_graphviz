note
	description: "[
		Builder for class inheritance tree diagrams.
		Note: MML verification happens at the DOT_GRAPH level, not in builders.
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	INHERITANCE_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
			-- Create builder with `a_renderer`.
		require
			renderer_not_void: a_renderer /= Void
		do
			renderer := a_renderer
			create graph.make_digraph ("InheritanceTree")
			graph.attributes.put ("rankdir", "TB")
			root_class_name := Void
		ensure
			renderer_set: renderer = a_renderer
			top_down: attached graph.attributes ["rankdir"] as r implies r.same_string ("TB")
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Renderer for producing output.

	graph: DOT_GRAPH
			-- Graph being built.

	root_class_name: detachable STRING
			-- Root class to start the tree from (Void = show all).

feature -- Configuration

	root_class (a_name: STRING): like Current
			-- Set root class to filter the tree.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		do
			root_class_name := a_name
			Result := Current
		ensure
			root_set: attached root_class_name as r implies r.same_string (a_name)
			result_is_current: Result = Current
		end

	set_direction (a_direction: STRING): like Current
			-- Set layout direction (TB = top-down, BT = bottom-up).
		require
			direction_not_void: a_direction /= Void
			valid_direction: a_direction.same_string ("TB") or a_direction.same_string ("BT")
		do
			graph.attributes.put ("rankdir", a_direction)
			Result := Current
		ensure
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
			-- 2. Extract class names and parents
			-- 3. Call add_class and add_inheritance
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

	add_class (a_name: STRING)
			-- Add a class node.
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
			l_node.attributes.put ("style", "rounded")
		ensure
			class_added: graph.has_node (a_name)
		end

	add_inheritance (a_child, a_parent: STRING)
			-- Add inheritance relationship (child inherits from parent).
			-- Edge goes from child to parent in the diagram.
		require
			child_not_void: a_child /= Void
			parent_not_void: a_parent /= Void
		local
			l_edge: DOT_EDGE
		do
			-- Create classes if they don't exist
			if not graph.has_node (a_child) then
				add_class (a_child)
			end
			if not graph.has_node (a_parent) then
				add_class (a_parent)
			end

			l_edge := graph.new_edge (a_child, a_parent)
			l_edge.attributes.put ("arrowhead", "empty")
		ensure
			child_exists: graph.has_node (a_child)
			parent_exists: graph.has_node (a_parent)
			edge_added: graph.edge_count > old graph.edge_count
		end

feature -- Filtering

	filter_to_root
			-- Remove classes not connected to root_class.
			-- Only effective after building from source.
		require
			has_root: root_class_name /= Void
		do
			-- Implementation in Phase 4:
			-- 1. Find all ancestors and descendants of root
			-- 2. Remove nodes not in that set
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

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void

end
