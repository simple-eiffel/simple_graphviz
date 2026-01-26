note
	description: "[
		Renderer that uses GraphViz C library directly via inline C externals.

		No subprocess spawning - direct library calls for:
		- Parsing DOT strings
		- Applying layout algorithms
		- Rendering to SVG/PDF/PNG (memory or file)
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	GRAPHVIZ_RENDERER

inherit
	ANY
		redefine
			default_create
		end

create
	make, default_create

feature {NONE} -- Initialization

	default_create
			-- Create renderer with default settings.
		do
			make
		end

	make
			-- Create renderer with default 30s timeout and "neato" engine (fallback: fdp, dot).
		local
			l_bin_path_c: C_STRING
			l_var_c: C_STRING
		do
			timeout_ms := 30_000
			engine := "neato"

			-- Configure GraphViz to find plugins in bin folder
			-- Must set environment variables at C level BEFORE GraphViz context is created
			create l_bin_path_c.make ("D:\prod\simple_graphviz\bin")

			-- Set GVPLUGINDIR environment variable at C level
			create l_var_c.make ("GVPLUGINDIR")
			c_set_env_var (l_var_c.item, l_bin_path_c.item).do_nothing

			-- Set GVBINDIR environment variable at C level
			create l_var_c.make ("GVBINDIR")
			c_set_env_var (l_var_c.item, l_bin_path_c.item).do_nothing

			-- Initialize GraphViz context (now that plugin paths are configured)
			gvc_context := c_gv_context
		ensure
			default_timeout: timeout_ms = 30_000
			default_engine: engine.same_string ("neato")
			context_created: gvc_context /= default_pointer
		end

feature -- Access

	timeout_ms: INTEGER
			-- Maximum render time in milliseconds (kept for API compatibility).

	engine: STRING
			-- Layout engine (dot, neato, fdp, circo, twopi, osage, sfdp).

	post_processor: detachable PHYSICS_POST_PROCESSOR
			-- Optional physics post-processor for boundary-constrained layouts.

feature -- Configuration

	set_timeout (a_ms: INTEGER): like Current
			-- Set timeout to `a_ms` milliseconds.
		require
			positive: a_ms > 0
		do
			timeout_ms := a_ms
			Result := Current
		ensure
			timeout_set: timeout_ms = a_ms
			result_is_current: Result = Current
		end

	set_engine (a_engine: STRING): like Current
			-- Set layout engine.
		require
			engine_not_void: a_engine /= Void
			engine_valid: is_valid_engine (a_engine)
		do
			engine := a_engine
			Result := Current
		ensure
			engine_set: engine.same_string (a_engine)
			result_is_current: Result = Current
		end

	set_post_processor (a_processor: detachable PHYSICS_POST_PROCESSOR): like Current
			-- Set optional physics post-processor for boundary-constrained layouts.
			-- Pass Void to disable post-processing.
		do
			post_processor := a_processor
			Result := Current
		ensure
			processor_set: post_processor = a_processor
			result_is_current: Result = Current
		end

	enable_boundary_constraints (a_width, a_height: REAL_64): like Current
			-- Enable physics post-processing with given page size in points.
		require
			positive_width: a_width > 0
			positive_height: a_height > 0
		local
			l_processor: PHYSICS_POST_PROCESSOR
		do
			create l_processor.make
			l_processor.set_target_size (a_width, a_height).do_nothing
			post_processor := l_processor
			Result := Current
		ensure
			processor_enabled: post_processor /= Void
			result_is_current: Result = Current
		end

	disable_boundary_constraints: like Current
			-- Disable physics post-processing.
		do
			post_processor := Void
			Result := Current
		ensure
			processor_disabled: post_processor = Void
			result_is_current: Result = Current
		end

feature -- Status Report

	is_graphviz_available: BOOLEAN
			-- Is GraphViz library loaded and functional?
		do
			Result := gvc_context /= default_pointer
		end

	graphviz_version: detachable STRING
			-- GraphViz version string.
		local
			l_ptr: POINTER
			l_c_str: C_STRING
		do
			if gvc_context /= default_pointer then
				l_ptr := c_gvc_version (gvc_context)
				if l_ptr /= default_pointer then
					create l_c_str.make_by_pointer (l_ptr)
					Result := l_c_str.string
				end
			end
		end

	is_valid_engine (a_engine: STRING): BOOLEAN
			-- Is `a_engine` a recognized layout engine?
		require
			engine_not_void: a_engine /= Void
		do
			Result := a_engine.same_string ("dot") or
			          a_engine.same_string ("neato") or
			          a_engine.same_string ("fdp") or
			          a_engine.same_string ("circo") or
			          a_engine.same_string ("twopi") or
			          a_engine.same_string ("osage") or
			          a_engine.same_string ("sfdp")
		end

	is_version_sufficient: BOOLEAN
			-- Is GraphViz version >= 2.40?
		local
			l_version: detachable STRING
			l_dot_pos, l_second_dot: INTEGER
			l_major, l_minor: INTEGER
			l_minor_str: STRING
		do
			l_version := graphviz_version
			if attached l_version as v then
				l_dot_pos := v.index_of ('.', 1)
				if l_dot_pos > 1 then
					l_major := v.substring (1, l_dot_pos - 1).to_integer
					l_minor := 0
					if l_dot_pos < v.count then
						-- Find second dot or end of string for minor version
						l_second_dot := v.index_of ('.', l_dot_pos + 1)
						if l_second_dot > 0 then
							l_minor_str := v.substring (l_dot_pos + 1, l_second_dot - 1)
						else
							l_minor_str := v.substring (l_dot_pos + 1, v.count)
						end
						if l_minor_str.is_integer then
							l_minor := l_minor_str.to_integer
						end
					end
					Result := is_version_sufficient_check (l_major, l_minor, 2, 40)
				end
			end
		end

	is_version_sufficient_check (a_major, a_minor, a_req_major, a_req_minor: INTEGER): BOOLEAN
			-- Is version `a_major`.`a_minor` >= `a_req_major`.`a_req_minor`?
			-- Exposed for testing.
		do
			Result := a_major > a_req_major or else (a_major = a_req_major and then a_minor >= a_req_minor)
		end

feature -- Rendering

	render_svg (a_dot: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to SVG format.
		require
			dot_not_void: a_dot /= Void
		do
			Result := render (a_dot, "svg")
		ensure
			result_not_void: Result /= Void
		end

	render_pdf (a_dot: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to PDF format.
		require
			dot_not_void: a_dot /= Void
		do
			Result := render (a_dot, "pdf")
		ensure
			result_not_void: Result /= Void
		end

	render_png (a_dot: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to PNG format.
		require
			dot_not_void: a_dot /= Void
		do
			Result := render (a_dot, "png")
		ensure
			result_not_void: Result /= Void
		end

	render (a_dot, a_format: STRING): GRAPHVIZ_RESULT
			-- Render DOT source to specified format in memory.
		require
			dot_not_void: a_dot /= Void
			format_not_void: a_format /= Void
			format_valid: a_format.same_string ("svg") or a_format.same_string ("pdf") or a_format.same_string ("png")
		local
			l_graph: POINTER
			l_result_ptr: POINTER
			l_result_len: INTEGER
			l_dot_c, l_engine_c, l_format_c: C_STRING
			l_error: GRAPHVIZ_ERROR
			l_content: STRING
			l_managed: MANAGED_POINTER
			l_layout_result, l_render_result: INTEGER
		do
			if not is_graphviz_available then
				create l_error.make ({GRAPHVIZ_ERROR}.Graphviz_not_found, "GraphViz library not available")
				create Result.make_failure (l_error)
			else
				-- Parse DOT string
				create l_dot_c.make (a_dot)
				l_graph := c_agmemread (l_dot_c.item)

				if l_graph = default_pointer then
					create l_error.make ({GRAPHVIZ_ERROR}.Invalid_dot, "Failed to parse DOT source")
					create Result.make_failure (l_error)
				else
					-- Try layout but catch errors gracefully
					-- Layout engines may not be available, so attempt but don't fail
					create l_engine_c.make (engine)
					l_layout_result := c_gv_layout (gvc_context, l_graph, l_engine_c.item)

					-- Try fallback silently
					if l_layout_result /= 0 and then engine.same_string ("neato") then
						create l_engine_c.make ("fdp")
						l_layout_result := c_gv_layout (gvc_context, l_graph, l_engine_c.item)
					end

					-- Render (layout optional - may succeed even without layout)
					create l_format_c.make (a_format)
					l_render_result := c_gv_render_data (gvc_context, l_graph, l_format_c.item, $l_result_ptr, $l_result_len)

					-- Cleanup
					if l_layout_result = 0 then
						c_gv_free_layout (gvc_context, l_graph)
					end

					if l_render_result /= 0 or l_result_ptr = default_pointer then
						c_agclose (l_graph)
						create l_error.make ({GRAPHVIZ_ERROR}.Output_error, "Render failed for format: " + a_format)
						create Result.make_failure (l_error)
					else
						-- Render succeeded
						create l_managed.share_from_pointer (l_result_ptr, l_result_len)
						create l_content.make (l_result_len)
						l_content.from_c_substring (l_result_ptr, 1, l_result_len)

						-- Cleanup
						c_gv_free_render_data (l_result_ptr)
						c_agclose (l_graph)

						create Result.make_success (l_content)
					end
				end
			end
		ensure
			result_not_void: Result /= Void
		end

	render_to_file (a_dot, a_format, a_path: STRING): GRAPHVIZ_RESULT
			-- Render DOT source directly to file at `a_path`.
		require
			dot_not_void: a_dot /= Void
			format_not_void: a_format /= Void
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		local
			l_graph: POINTER
			l_dot_c, l_engine_c, l_format_c, l_path_c: C_STRING
			l_error: GRAPHVIZ_ERROR
			l_layout_result, l_render_result: INTEGER
			l_output_file: RAW_FILE
		do
			if not is_graphviz_available then
				create l_error.make ({GRAPHVIZ_ERROR}.Graphviz_not_found, "GraphViz library not available")
				create Result.make_failure (l_error)
			else
				-- Parse DOT string
				create l_dot_c.make (a_dot)
				l_graph := c_agmemread (l_dot_c.item)

				if l_graph = default_pointer then
					create l_error.make ({GRAPHVIZ_ERROR}.Invalid_dot, "Failed to parse DOT source")
					create Result.make_failure (l_error)
				else
					-- Try layout but catch errors gracefully
					create l_engine_c.make (engine)
					l_layout_result := c_gv_layout (gvc_context, l_graph, l_engine_c.item)

					-- Try fallback silently
					if l_layout_result /= 0 and then engine.same_string ("neato") then
						create l_engine_c.make ("fdp")
						l_layout_result := c_gv_layout (gvc_context, l_graph, l_engine_c.item)
					end

					-- Render to file (layout optional)
					create l_format_c.make (a_format)
					create l_path_c.make (a_path)
					l_render_result := c_gv_render_filename (gvc_context, l_graph, l_format_c.item, l_path_c.item)

					-- Cleanup
					if l_layout_result = 0 then
						c_gv_free_layout (gvc_context, l_graph)
					end
					c_agclose (l_graph)

					if l_render_result /= 0 then
						create l_error.make ({GRAPHVIZ_ERROR}.Output_error, "Render to file failed: " + a_path)
						create Result.make_failure (l_error)
					else
						-- Verify output file exists
						create l_output_file.make_with_name (a_path)
						if l_output_file.exists then
							create Result.make_success (a_path)
						else
							create l_error.make ({GRAPHVIZ_ERROR}.Output_error, "Output file not created: " + a_path)
							create Result.make_failure (l_error)
						end
					end
				end
			end
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	gvc_context: POINTER
			-- GraphViz context handle.

feature {NONE} -- C Externals

	c_gv_context: POINTER
			-- Create a new GraphViz context.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return gvContext();"
		end

	c_gvc_version (a_gvc: POINTER): POINTER
			-- Get GraphViz version string.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return gvcVersion((GVC_t*)$a_gvc);"
		end

	c_agmemread (a_dot: POINTER): POINTER
			-- Parse DOT string into graph.
		external
			"C inline use <graphviz/cgraph.h>"
		alias
			"return agmemread((const char*)$a_dot);"
		end

	c_agclose (a_graph: POINTER)
			-- Close and free graph.
		external
			"C inline use <graphviz/cgraph.h>"
		alias
			"agclose((Agraph_t*)$a_graph);"
		end

	c_gv_layout (a_gvc, a_graph, a_engine: POINTER): INTEGER
			-- Apply layout engine to graph.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return gvLayout((GVC_t*)$a_gvc, (Agraph_t*)$a_graph, (const char*)$a_engine);"
		end

	c_gv_free_layout (a_gvc, a_graph: POINTER)
			-- Free layout data.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"gvFreeLayout((GVC_t*)$a_gvc, (Agraph_t*)$a_graph);"
		end

	c_gv_render_data (a_gvc, a_graph, a_format, a_result_ptr, a_result_len: POINTER): INTEGER
			-- Render graph to memory.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"[
				char* result = NULL;
				unsigned int len = 0;
				int ret = gvRenderData((GVC_t*)$a_gvc, (Agraph_t*)$a_graph,
				                        (const char*)$a_format, &result, &len);
				*((char**)$a_result_ptr) = result;
				*((int*)$a_result_len) = (int)len;
				return ret;
			]"
		end

	c_gv_render_filename (a_gvc, a_graph, a_format, a_filename: POINTER): INTEGER
			-- Render graph to file.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return gvRenderFilename((GVC_t*)$a_gvc, (Agraph_t*)$a_graph, (const char*)$a_format, (const char*)$a_filename);"
		end

	c_gv_free_render_data (a_data: POINTER)
			-- Free rendered data.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"gvFreeRenderData((char*)$a_data);"
		end

	c_gv_free_context (a_gvc: POINTER): INTEGER
			-- Free GraphViz context.
		external
			"C inline use <graphviz/gvc.h>"
		alias
			"return gvFreeContext((GVC_t*)$a_gvc);"
		end

	c_set_env_var (a_var, a_value: POINTER): INTEGER
			-- Set environment variable at C level (required before GraphViz loads plugins).
		external
			"C inline use <stdlib.h>"
		alias
			"return _putenv_s((const char*)$a_var, (const char*)$a_value);"
		end

invariant
	timeout_positive: timeout_ms > 0
	engine_not_void: engine /= Void
	engine_valid: is_valid_engine (engine)

end
