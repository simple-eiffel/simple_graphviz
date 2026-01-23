note
	description: "[
		Builder for flowchart diagrams with start, end, process, and decision nodes.
		Note: MML verification happens at the DOT_GRAPH level, not in builders.
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	FLOWCHART_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
			-- Create builder with `a_renderer`.
		require
			renderer_not_void: a_renderer /= Void
		do
			renderer := a_renderer
			create graph.make_digraph ("Flowchart")
			graph.attributes.put ("rankdir", "TB")
			graph.attributes.put ("splines", "ortho")
			last_node_id := Void
			node_counter := 0
		ensure
			renderer_set: renderer = a_renderer
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Renderer for producing output.

	graph: DOT_GRAPH
			-- Graph being built.

	last_node_id: detachable STRING
			-- ID of the most recently added node (for auto-linking).

feature -- Status Report

	has_decision: BOOLEAN
			-- Is there a recent decision node for linking?
		do
			Result := last_decision_id /= Void
		end

feature -- Building

	start (a_label: STRING): like Current
			-- Add start node (rounded rectangle).
		require
			label_not_void: a_label /= Void
		local
			l_node: DOT_NODE
			l_id: STRING
		do
			l_id := next_id ("start")
			l_node := graph.new_node (l_id)
			l_node.attributes.put ("label", a_label)
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "rounded,filled")
			l_node.attributes.put ("fillcolor", "lightgreen")
			auto_link (l_id)
			last_node_id := l_id
			Result := Current
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	end_node (a_label: STRING): like Current
			-- Add end node (rounded rectangle).
		require
			label_not_void: a_label /= Void
		local
			l_node: DOT_NODE
			l_id: STRING
		do
			l_id := next_id ("end")
			l_node := graph.new_node (l_id)
			l_node.attributes.put ("label", a_label)
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "rounded,filled")
			l_node.attributes.put ("fillcolor", "lightcoral")
			auto_link (l_id)
			last_node_id := l_id
			Result := Current
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	process (a_label: STRING): like Current
			-- Add process node (rectangle).
		require
			label_not_void: a_label /= Void
		local
			l_node: DOT_NODE
			l_id: STRING
		do
			l_id := next_id ("proc")
			l_node := graph.new_node (l_id)
			l_node.attributes.put ("label", a_label)
			l_node.attributes.put ("shape", "box")
			auto_link (l_id)
			last_node_id := l_id
			Result := Current
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	decision (a_label, a_yes_label, a_no_label: STRING): like Current
			-- Add decision node (diamond).
			-- Note: Next nodes must be linked manually via `link_yes` and `link_no`.
		require
			label_not_void: a_label /= Void
			yes_label_not_void: a_yes_label /= Void
			no_label_not_void: a_no_label /= Void
		local
			l_node: DOT_NODE
			l_id: STRING
		do
			l_id := next_id ("dec")
			l_node := graph.new_node (l_id)
			l_node.attributes.put ("label", a_label)
			l_node.attributes.put ("shape", "diamond")
			l_node.attributes.put ("style", "filled")
			l_node.attributes.put ("fillcolor", "lightyellow")
			auto_link (l_id)
			last_decision_id := l_id
			last_yes_label := a_yes_label
			last_no_label := a_no_label
			last_node_id := l_id
			Result := Current
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

	io_node (a_label: STRING): like Current
			-- Add I/O node (parallelogram).
		require
			label_not_void: a_label /= Void
		local
			l_node: DOT_NODE
			l_id: STRING
		do
			l_id := next_id ("io")
			l_node := graph.new_node (l_id)
			l_node.attributes.put ("label", a_label)
			l_node.attributes.put ("shape", "parallelogram")
			auto_link (l_id)
			last_node_id := l_id
			Result := Current
		ensure
			node_added: graph.node_count = old graph.node_count + 1
			result_is_current: Result = Current
		end

feature -- Manual Linking

	link (a_from, a_to: STRING): like Current
			-- Add edge from `a_from` to `a_to`.
		require
			from_not_void: a_from /= Void
			to_not_void: a_to /= Void
		local
			l_edge: DOT_EDGE
		do
			l_edge := graph.new_edge (a_from, a_to)
			Result := Current
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
			result_is_current: Result = Current
		end

	link_yes (a_target_id: STRING): like Current
			-- Link last decision's Yes branch to `a_target_id`.
		require
			target_not_void: a_target_id /= Void
			decision_exists: has_decision
		local
			l_edge: DOT_EDGE
		do
			if attached last_decision_id as d and attached last_yes_label as y then
				l_edge := graph.new_edge (d, a_target_id)
				l_edge.attributes.put ("label", y)
			end
			Result := Current
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
			result_is_current: Result = Current
		end

	link_no (a_target_id: STRING): like Current
			-- Link last decision's No branch to `a_target_id`.
		require
			target_not_void: a_target_id /= Void
			decision_exists: has_decision
		local
			l_edge: DOT_EDGE
		do
			if attached last_decision_id as d and attached last_no_label as n then
				l_edge := graph.new_edge (d, a_target_id)
				l_edge.attributes.put ("label", n)
			end
			Result := Current
		ensure
			edge_added: graph.edge_count = old graph.edge_count + 1
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

	node_counter: INTEGER
			-- Counter for generating unique node IDs.

	last_decision_id: detachable STRING
			-- ID of the most recent decision node.

	last_yes_label: detachable STRING
			-- Label for Yes branch of last decision.

	last_no_label: detachable STRING
			-- Label for No branch of last decision.

	next_id (a_prefix: STRING): STRING
			-- Generate next unique node ID.
		do
			node_counter := node_counter + 1
			create Result.make (a_prefix.count + 5)
			Result.append_string (a_prefix)
			Result.append_integer (node_counter)
		end

	auto_link (a_to_id: STRING)
			-- Automatically link from last node to `a_to_id` if applicable.
		local
			l_edge: DOT_EDGE
		do
			if attached last_node_id as l then
				-- Don't auto-link from decision nodes (they need explicit yes/no links)
				if attached last_decision_id as d and then l.same_string (d) then
					-- Skip auto-link for decisions
				else
					l_edge := graph.new_edge (l, a_to_id)
				end
			end
		end

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void

end
