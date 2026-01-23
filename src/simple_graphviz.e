note
	description: "Main facade for simple_graphviz - fluent API for diagram generation"
	author: "Larry Rix"
	date: "2026-01-22"

class
	SIMPLE_GRAPHVIZ

inherit
	ANY
		redefine
			default_create
		end

create
	make, default_create

feature {NONE} -- Initialization

	default_create
			-- Create with default renderer.
		do
			make
		end

	make
			-- Create with default renderer settings.
		do
			create renderer.make
		ensure
			renderer_exists: renderer /= Void
			graphviz_checked: True -- Availability can be queried
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Underlying renderer.

feature -- Status Report

	is_graphviz_available: BOOLEAN
			-- Is GraphViz installed and accessible?
		do
			Result := renderer.is_graphviz_available
		end

	graphviz_version: detachable STRING
			-- GraphViz version string, or Void if not available.
		do
			Result := renderer.graphviz_version
		end

feature -- Configuration

	set_engine (a_engine: STRING): like Current
			-- Set layout engine (dot, neato, fdp, circo, twopi, osage, sfdp).
		require
			engine_not_void: a_engine /= Void
			engine_valid: renderer.is_valid_engine (a_engine)
		do
			renderer.set_engine (a_engine).do_nothing
			Result := Current
		ensure
			engine_set: renderer.engine.same_string (a_engine)
			result_is_current: Result = Current
		end

	set_timeout (a_ms: INTEGER): like Current
			-- Set render timeout in milliseconds.
		require
			positive: a_ms > 0
		do
			renderer.set_timeout (a_ms).do_nothing
			Result := Current
		ensure
			timeout_set: renderer.timeout_ms = a_ms
			result_is_current: Result = Current
		end

feature -- Builder Access

	bon_diagram: BON_DIAGRAM_BUILDER
			-- Get a BON diagram builder.
		do
			create Result.make (renderer)
		ensure
			result_not_void: Result /= Void
		end

	flowchart: FLOWCHART_BUILDER
			-- Get a flowchart builder.
		do
			create Result.make (renderer)
		ensure
			result_not_void: Result /= Void
		end

	state_machine: STATE_MACHINE_BUILDER
			-- Get a state machine builder.
		do
			create Result.make (renderer)
		ensure
			result_not_void: Result /= Void
		end

	dependency_graph: DEPENDENCY_BUILDER
			-- Get a dependency graph builder.
		do
			create Result.make (renderer)
		ensure
			result_not_void: Result /= Void
		end

	inheritance_tree: INHERITANCE_BUILDER
			-- Get an inheritance tree builder.
		do
			create Result.make (renderer)
		ensure
			result_not_void: Result /= Void
		end

	graph: DOT_GRAPH
			-- Get a new directed graph for custom building.
		do
			create Result.make_digraph ("Graph")
		ensure
			result_not_void: Result /= Void
			is_directed: Result.is_directed
		end

	undirected_graph: DOT_GRAPH
			-- Get a new undirected graph for custom building.
		do
			create Result.make_graph ("Graph")
		ensure
			result_not_void: Result /= Void
			not_directed: not Result.is_directed
		end

feature -- Direct Rendering

	render_svg (a_dot: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to SVG.
		require
			dot_not_void: a_dot /= Void
		do
			Result := renderer.render_svg (a_dot)
		ensure
			result_not_void: Result /= Void
		end

	render_pdf (a_dot: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to PDF.
		require
			dot_not_void: a_dot /= Void
		do
			Result := renderer.render_pdf (a_dot)
		ensure
			result_not_void: Result /= Void
		end

	render_png (a_dot: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to PNG.
		require
			dot_not_void: a_dot /= Void
		do
			Result := renderer.render_png (a_dot)
		ensure
			result_not_void: Result /= Void
		end

	render_to_file (a_dot, a_format, a_path: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to file.
		require
			dot_not_void: a_dot /= Void
			format_not_void: a_format /= Void
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			Result := renderer.render_to_file (a_dot, a_format, a_path)
		ensure
			result_not_void: Result /= Void
		end

invariant
	renderer_not_void: renderer /= Void

end
