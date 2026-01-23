note
	description: "[
		Post-processor that applies physics-based boundary forces to GraphViz layouts.

		After GraphViz computes initial layout, this class:
		1. Reads node positions via C API
		2. Applies boundary forces to compress into target page
		3. Updates node positions with 'pos' attribute (fixed positions)
		4. Re-renders with constrained layout

		Uses GraphViz C library directly (no CLI).
	]"
	author: "Larry Rix"
	date: "2026-01-23"

class
	PHYSICS_POST_PROCESSOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize with default parameters.
		do
			target_width := 792.0   -- 11 inches at 72 dpi
			target_height := 612.0  -- 8.5 inches at 72 dpi
			margin := 36.0          -- 0.5 inch margin
			boundary_force := 0.1   -- Force strength for boundary repulsion
			repulsion_force := 0.5  -- Force strength for node-to-node repulsion
			iterations := 100       -- Number of physics iterations (increased for spreading)
			damping := 0.85         -- Velocity damping per iteration
		ensure
			reasonable_defaults: target_width > 0 and target_height > 0
		end

feature -- Access

	target_width: REAL_64
			-- Target page width in points.

	target_height: REAL_64
			-- Target page height in points.

	margin: REAL_64
			-- Page margin in points.

	boundary_force: REAL_64
			-- Force multiplier for boundary repulsion (0.0-1.0).

	repulsion_force: REAL_64
			-- Force multiplier for node-to-node repulsion (0.0-1.0).

	iterations: INTEGER
			-- Number of physics simulation iterations.

	damping: REAL_64
			-- Velocity damping factor per iteration (0.0-1.0).

feature -- Configuration

	set_target_size (a_width, a_height: REAL_64): like Current
			-- Set target page size in points.
		require
			positive_width: a_width > 0
			positive_height: a_height > 0
		do
			target_width := a_width
			target_height := a_height
			Result := Current
		ensure
			width_set: target_width = a_width
			height_set: target_height = a_height
		end

	set_target_size_inches (a_width, a_height: REAL_64): like Current
			-- Set target page size in inches.
		require
			positive_width: a_width > 0
			positive_height: a_height > 0
		do
			target_width := a_width * 72.0
			target_height := a_height * 72.0
			Result := Current
		ensure
			width_set: target_width = a_width * 72.0
			height_set: target_height = a_height * 72.0
		end

	set_margin (a_margin: REAL_64): like Current
			-- Set page margin in points.
		require
			non_negative: a_margin >= 0
		do
			margin := a_margin
			Result := Current
		ensure
			margin_set: margin = a_margin
		end

	set_boundary_force (a_force: REAL_64): like Current
			-- Set boundary force multiplier.
		require
			valid_range: a_force >= 0 and a_force <= 1.0
		do
			boundary_force := a_force
			Result := Current
		ensure
			force_set: boundary_force = a_force
		end

	set_iterations (a_count: INTEGER): like Current
			-- Set number of physics iterations.
		require
			positive: a_count > 0
		do
			iterations := a_count
			Result := Current
		ensure
			iterations_set: iterations = a_count
		end

feature -- Processing

	process_graph (a_gvc: POINTER; a_graph: POINTER): BOOLEAN
			-- Apply boundary forces to laid-out graph.
			-- Returns True if processing succeeded.
		require
			valid_gvc: a_gvc /= default_pointer
			valid_graph: a_graph /= default_pointer
		local
			l_node: POINTER
			l_node_count: INTEGER
			l_positions: ARRAYED_LIST [TUPLE [node: POINTER; x, y, vx, vy: REAL_64]]
			l_x, l_y: REAL_64
			l_min_x, l_min_y, l_max_x, l_max_y: REAL_64
			l_scale_x, l_scale_y: REAL_64
			l_usable_width, l_usable_height: REAL_64
			l_current_width, l_current_height: REAL_64
			l_pos: TUPLE [node: POINTER; x, y, vx, vy: REAL_64]
			l_fx, l_fy: REAL_64
			l_center_x, l_center_y: REAL_64
			l_dx, l_dy: REAL_64
			l_dist, l_repulsion: REAL_64
			i: INTEGER
		do
			-- Collect node positions
			create l_positions.make (100)
			l_min_x := {REAL_64}.max_value
			l_min_y := {REAL_64}.max_value
			l_max_x := {REAL_64}.min_value
			l_max_y := {REAL_64}.min_value

			from
				l_node := c_agfstnode (a_graph)
			until
				l_node = default_pointer
			loop
				l_x := c_nd_coord_x (l_node)
				l_y := c_nd_coord_y (l_node)
				l_positions.extend ([l_node, l_x, l_y, 0.0, 0.0])

				l_min_x := l_min_x.min (l_x)
				l_min_y := l_min_y.min (l_y)
				l_max_x := l_max_x.max (l_x)
				l_max_y := l_max_y.max (l_y)

				l_node_count := l_node_count + 1
				l_node := c_agnxtnode (a_graph, l_node)
			end

			if l_node_count = 0 then
				Result := True  -- Nothing to process
			else
				-- Calculate current bounds and scaling
				l_current_width := l_max_x - l_min_x
				l_current_height := l_max_y - l_min_y
				l_usable_width := target_width - (margin * 2)
				l_usable_height := target_height - (margin * 2)

				-- Initial scale to fit
				if l_current_width > 0 and l_current_height > 0 then
					l_scale_x := l_usable_width / l_current_width
					l_scale_y := l_usable_height / l_current_height
					-- Use smaller scale to maintain aspect ratio
					l_scale_x := l_scale_x.min (l_scale_y)
					l_scale_y := l_scale_x
				else
					l_scale_x := 1.0
					l_scale_y := 1.0
				end

				-- Center point of target area
				l_center_x := target_width / 2
				l_center_y := target_height / 2

				-- Scale and center positions
				across l_positions as ic loop
					l_pos := ic
					l_pos.x := (l_pos.x - l_min_x - l_current_width / 2) * l_scale_x + l_center_x
					l_pos.y := (l_pos.y - l_min_y - l_current_height / 2) * l_scale_y + l_center_y
				end

				-- Physics iterations: apply repulsion + boundary forces
				from i := 1 until i > iterations loop
					across l_positions as ic loop
						l_pos := ic
						l_fx := 0.0
						l_fy := 0.0

						-- Node-to-node REPULSION (critical for spreading)
						across l_positions as ic_other loop
							if ic_other.node /= l_pos.node then
								l_dx := l_pos.x - ic_other.x
								l_dy := l_pos.y - ic_other.y
								l_dist := l_dx * l_dx + l_dy * l_dy
								if l_dist < 1.0 then
									l_dist := 1.0  -- Avoid division by zero
								end
								-- Strong repulsion that falls off with distance squared
								l_repulsion := repulsion_force * 10000.0 / l_dist
								l_fx := l_fx + l_repulsion * l_dx / l_dist
								l_fy := l_fy + l_repulsion * l_dy / l_dist
							end
						end

						-- Boundary forces (push away from edges)
						if l_pos.x < margin then
							l_fx := l_fx + boundary_force * (margin - l_pos.x)
						end
						if l_pos.x > target_width - margin then
							l_fx := l_fx - boundary_force * (l_pos.x - (target_width - margin))
						end
						if l_pos.y < margin then
							l_fy := l_fy + boundary_force * (margin - l_pos.y)
						end
						if l_pos.y > target_height - margin then
							l_fy := l_fy - boundary_force * (l_pos.y - (target_height - margin))
						end

						-- Gentle centering force
						l_dx := l_center_x - l_pos.x
						l_dy := l_center_y - l_pos.y
						l_fx := l_fx + l_dx * 0.005
						l_fy := l_fy + l_dy * 0.005

						-- Update velocity with damping
						l_pos.vx := (l_pos.vx + l_fx) * damping
						l_pos.vy := (l_pos.vy + l_fy) * damping

						-- Limit max velocity
						if l_pos.vx.abs > 50.0 then
							l_pos.vx := 50.0 * l_pos.vx.sign
						end
						if l_pos.vy.abs > 50.0 then
							l_pos.vy := 50.0 * l_pos.vy.sign
						end

						-- Update position
						l_pos.x := l_pos.x + l_pos.vx
						l_pos.y := l_pos.y + l_pos.vy

						-- Clamp to boundaries
						l_pos.x := l_pos.x.max (margin).min (target_width - margin)
						l_pos.y := l_pos.y.max (margin).min (target_height - margin)
					end
					i := i + 1
				end

				-- Apply final positions back to graph nodes
				across l_positions as ic loop
					l_pos := ic
					c_set_node_pos (l_pos.node, l_pos.x, l_pos.y)
				end

				Result := True
			end
		end

feature {NONE} -- C Externals

	c_agfstnode (a_graph: POINTER): POINTER
			-- First node in graph.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return agfstnode((Agraph_t*)$a_graph);"
		end

	c_agnxtnode (a_graph, a_node: POINTER): POINTER
			-- Next node after `a_node` in graph.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return agnxtnode((Agraph_t*)$a_graph, (Agnode_t*)$a_node);"
		end

	c_nd_coord_x (a_node: POINTER): REAL_64
			-- X coordinate of node.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return ND_coord((Agnode_t*)$a_node).x;"
		end

	c_nd_coord_y (a_node: POINTER): REAL_64
			-- Y coordinate of node.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return ND_coord((Agnode_t*)$a_node).y;"
		end

	c_set_node_pos (a_node: POINTER; a_x, a_y: REAL_64)
			-- Set node position and mark as fixed.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"[
				char pos[100];
				snprintf(pos, sizeof(pos), "%f,%f!", $a_x, $a_y);
				agset((Agnode_t*)$a_node, "pos", pos);
				ND_coord((Agnode_t*)$a_node).x = $a_x;
				ND_coord((Agnode_t*)$a_node).y = $a_y;
			]"
		end

invariant
	positive_target_width: target_width > 0
	positive_target_height: target_height > 0
	non_negative_margin: margin >= 0
	valid_boundary_force: boundary_force >= 0 and boundary_force <= 1.0
	valid_repulsion_force: repulsion_force >= 0 and repulsion_force <= 1.0
	positive_iterations: iterations > 0
	valid_damping: damping >= 0 and damping <= 1.0

end
