note
	description: "[
		Builder for state machine diagrams with states and transitions.
		Note: MML verification happens at the DOT_GRAPH level, not in builders.
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	STATE_MACHINE_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
			-- Create builder with `a_renderer`.
		require
			renderer_not_void: a_renderer /= Void
		do
			renderer := a_renderer
			create graph.make_digraph ("StateMachine")
			graph.attributes.put ("rankdir", "LR")
			initial_state_name := Void
		ensure
			renderer_set: renderer = a_renderer
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Renderer for producing output.

	graph: DOT_GRAPH
			-- Graph being built.

	initial_state_name: detachable STRING
			-- Name of the initial state.

feature -- Model Queries

	states_model: MML_SET [STRING]
			-- Set of all state names.
		do
			Result := graph.node_ids_model
			-- Remove internal nodes (initial marker, final markers)
			Result := Result / "__initial__"
		end

feature -- Status Report

	has_state (a_name: STRING): BOOLEAN
			-- Is there a state with `a_name`?
		require
			name_not_void: a_name /= Void
		do
			Result := graph.has_node (a_name)
		end

feature -- Building

	initial (a_name: STRING): like Current
			-- Set initial state. Creates state if not exists, adds initial marker.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		local
			l_marker: DOT_NODE
			l_edge: DOT_EDGE
		do
			-- Create initial marker (small filled circle)
			if not graph.has_node ("__initial__") then
				l_marker := graph.new_node ("__initial__")
				l_marker.attributes.put ("shape", "point")
				l_marker.attributes.put ("width", "0.25")
			end

			-- Create state if needed
			if not graph.has_node (a_name) then
				add_state (a_name)
			end

			-- Edge from marker to initial state
			l_edge := graph.new_edge ("__initial__", a_name)

			initial_state_name := a_name
			Result := Current
		ensure
			initial_set: attached initial_state_name as i implies i.same_string (a_name)
			state_exists: has_state (a_name)
			result_is_current: Result = Current
		end

	state (a_name: STRING): like Current
			-- Add a state node (rounded rectangle).
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		do
			add_state (a_name)
			Result := Current
		ensure
			state_added: has_state (a_name)
			result_is_current: Result = Current
		end

	final (a_name: STRING): like Current
			-- Add a final state node (double circle).
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			not_duplicate: not graph.has_node (a_name)
		local
			l_node: DOT_NODE
		do
			l_node := graph.new_node (a_name)
			l_node.attributes.put ("label", a_name)
			l_node.attributes.put ("shape", "doublecircle")
			Result := Current
		ensure
			state_added: has_state (a_name)
			result_is_current: Result = Current
		end

	transition (a_from, a_to, a_label: STRING): like Current
			-- Add transition from `a_from` to `a_to` with `a_label`.
		require
			from_not_void: a_from /= Void
			to_not_void: a_to /= Void
			label_not_void: a_label /= Void
		local
			l_edge: DOT_EDGE
		do
			-- Create states if they don't exist
			if not graph.has_node (a_from) then
				add_state (a_from)
			end
			if not graph.has_node (a_to) then
				add_state (a_to)
			end

			l_edge := graph.new_edge (a_from, a_to)
			l_edge.attributes.put ("label", a_label)
			Result := Current
		ensure
			from_exists: has_state (a_from)
			to_exists: has_state (a_to)
			edge_added: graph.edge_count > old graph.edge_count
			result_is_current: Result = Current
		end

	self_transition (a_state, a_label: STRING): like Current
			-- Add self-transition (loop) on `a_state`.
		require
			state_not_void: a_state /= Void
			label_not_void: a_label /= Void
		do
			Result := transition (a_state, a_state, a_label)
		ensure
			result_is_current: Result = Current
		end

feature -- Configuration

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

	set_direction (a_direction: STRING): like Current
			-- Set layout direction (LR, RL, TB, BT).
		require
			direction_not_void: a_direction /= Void
		do
			graph.attributes.put ("rankdir", a_direction)
			Result := Current
		ensure
			result_is_current: Result = Current
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

	add_state (a_name: STRING)
			-- Add a state node internally.
		require
			name_not_void: a_name /= Void
			not_duplicate: not graph.has_node (a_name)
		local
			l_node: DOT_NODE
		do
			l_node := graph.new_node (a_name)
			l_node.attributes.put ("label", a_name)
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "rounded")
		ensure
			state_added: graph.has_node (a_name)
		end

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void

end
