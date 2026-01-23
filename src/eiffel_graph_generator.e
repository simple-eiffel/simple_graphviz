note
	description: "[
		Main orchestrator for generating documentation graphs from Eiffel libraries.

		Workflow:
		1. Parse ECF via ECF_PARSER
		2. Find all .e files in source clusters
		3. Parse sources via EIFFEL_PARSER
		4. Generate 4 graph types:
		   - class_hierarchy.svg (INHERITANCE_BUILDER)
		   - dependencies.svg (DEPENDENCY_BUILDER)
		   - api_surface.svg (BON_DIAGRAM_BUILDER)
		   - contract_coverage.svg (CONTRACT_COVERAGE_BUILDER)
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	EIFFEL_GRAPH_GENERATOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize generator.
		do
			create renderer.make
			create ecf_parser.make
			create eiffel_parser.make
			create parsed_classes.make (50)
			create log.make_with_level ({SIMPLE_LOGGER}.Level_info)
			create page_sizer.make
		ensure
			renderer_not_void: renderer /= Void
			ecf_parser_not_void: ecf_parser /= Void
			page_sizer_not_void: page_sizer /= Void
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- GraphViz renderer.

	ecf_parser: ECF_PARSER
			-- ECF configuration parser.

	eiffel_parser: EIFFEL_PARSER
			-- Eiffel source parser.

	parsed_classes: ARRAYED_LIST [EIFFEL_CLASS_NODE]
			-- All parsed class nodes.

	log: SIMPLE_LOGGER
			-- Logger instance.

	page_sizer: GRAPHVIZ_PAGE_SIZER
			-- Automatic page size calculator.

feature -- Status

	has_error: BOOLEAN
			-- Did generation fail?

	error_message: detachable STRING
			-- Error description if generation failed.

	library_name: STRING
			-- Name of the library being processed.
		do
			Result := ecf_parser.library_name
		end

feature -- Generation

	generate (a_ecf_path: STRING; a_output_dir: STRING)
			-- Generate all graphs for library at `a_ecf_path'.
			-- If `a_output_dir' is empty or ".", use the ECF's parent directory.
			-- Graphs are placed in {library_dir}/graphs/
		require
			ecf_path_not_void: a_ecf_path /= Void
			ecf_path_not_empty: not a_ecf_path.is_empty
			output_dir_not_void: a_output_dir /= Void
		local
			l_graphs_dir: STRING
			l_ecf_dir: STRING
			l_normalized_ecf: STRING
			l_last_slash: INTEGER
		do
			has_error := False
			error_message := Void
			parsed_classes.wipe_out

			log.info ("=== EIFFEL_GRAPH_GENERATOR ===")
			log.info ("ECF: " + a_ecf_path)

			-- Determine output directory: use ECF's parent dir if output is "." or empty
			l_normalized_ecf := a_ecf_path.twin
			l_normalized_ecf.replace_substring_all ("\", "/")
			l_last_slash := l_normalized_ecf.last_index_of ('/', l_normalized_ecf.count)
			if l_last_slash > 0 then
				l_ecf_dir := l_normalized_ecf.substring (1, l_last_slash - 1)
			else
				l_ecf_dir := "."
			end

			if a_output_dir.is_empty or a_output_dir.same_string (".") then
				l_graphs_dir := l_ecf_dir + "/graphs"
			else
				l_graphs_dir := a_output_dir + "/graphs"
			end

			log.info ("Output: " + l_graphs_dir)

			-- Step 1: Parse ECF
			log.info ("Parsing ECF...")
			ecf_parser.parse_file (a_ecf_path)

			if ecf_parser.has_error then
				has_error := True
				error_message := ecf_parser.error_message
				if attached error_message as em then
					log.error ("ECF parse error: " + em)
				end
			else
				log.info ("Library: " + ecf_parser.library_name)
				log.info ("Clusters: " + ecf_parser.source_clusters.count.out)
				log.info ("Internal deps: " + ecf_parser.internal_dependencies.count.out)
				log.info ("External deps: " + ecf_parser.external_dependencies.count.out)

				-- Step 2: Find and parse .e files
				log.info ("Finding and parsing source files...")
				parse_source_clusters

				log.info ("Parsed " + parsed_classes.count.out + " classes")

				-- Step 3: Create output directory
				ensure_directory_exists (l_graphs_dir)

				-- Step 4: Generate all graph types with automatic page sizing
				log.info ("Generating graphs to: " + l_graphs_dir)
				generate_class_hierarchy (l_graphs_dir + "/class_hierarchy.svg")
				generate_dependencies (l_graphs_dir + "/dependencies.svg")
				generate_api_surface (l_graphs_dir + "/api_surface.svg")
				generate_contract_coverage (l_graphs_dir + "/contract_coverage.svg")

				log.info ("=== GENERATION COMPLETE ===")
			end
		ensure
			error_implies_message: has_error implies error_message /= Void
		end

feature {NONE} -- Source Parsing

	parse_source_clusters
			-- Parse all .e files in source clusters.
		local
			l_files: ARRAYED_LIST [STRING]
			l_ast: EIFFEL_AST
		do
			across ecf_parser.source_clusters as ic loop
				log.debug_log ("Scanning cluster: " + ic.name + " at " + ic.location)
				l_files := find_eiffel_files (ic.location)

				across l_files as ic_file loop
					log.debug_log ("  Parsing: " + ic_file)
					l_ast := eiffel_parser.parse_file (ic_file)
					across l_ast.classes as ic_class loop
						parsed_classes.extend (ic_class)
					end
				end
			end
		end

	find_eiffel_files (a_directory: STRING): ARRAYED_LIST [STRING]
			-- Find all .e files in `a_directory' recursively.
		local
			l_dir: DIRECTORY
			l_entries: ARRAYED_LIST [STRING_8]
			l_path: STRING
			l_file: RAW_FILE
			l_subdir_files: ARRAYED_LIST [STRING]
		do
			create Result.make (20)
			create l_dir.make (a_directory)

			if l_dir.exists then
				l_dir.open_read
				l_entries := l_dir.linear_representation

				across l_entries as ic loop
					if not ic.same_string (".") and not ic.same_string ("..") then
						l_path := a_directory + "/" + ic.to_string_8

						create l_file.make_with_name (l_path)
						if l_file.exists then
							if l_file.is_directory then
								-- Recurse into subdirectory (skip EIFGENs)
								if not ic.same_string ("EIFGENs") then
									l_subdir_files := find_eiffel_files (l_path)
									across l_subdir_files as ic_sub loop
										Result.extend (ic_sub)
									end
								end
							elseif l_path.ends_with (".e") then
								Result.extend (l_path)
							end
						end
					end
				end
			end
		end

feature {NONE} -- Graph Generation

	generate_class_hierarchy (a_output_path: STRING)
			-- Generate class hierarchy graph.
		local
			l_builder: INHERITANCE_BUILDER
			l_result: GRAPHVIZ_RESULT
			l_max_label: INTEGER
		do
			log.info ("  Generating class_hierarchy.svg...")
			create l_builder.make (renderer)
			l_builder.set_title (ecf_parser.library_name + " - Inheritance Hierarchy").do_nothing
			-- LR layout: parent on left, children on right (more vertical result)
			l_builder.graph.attributes.put ("rankdir", "LR")
			l_builder.graph.attributes.put ("nodesep", "0.5")
			l_builder.graph.attributes.put ("ranksep", "1.5")
			l_builder.graph.attributes.put ("fontsize", "14")
			l_builder.graph.attributes.put ("splines", "ortho")

			-- Add classes and inheritance relationships
			l_max_label := 0
			across parsed_classes as ic loop
				if not l_builder.graph.has_node (ic.name) then
					l_builder.add_class (ic.name)
					l_max_label := l_max_label.max (ic.name.count)
				end

				-- Add inheritance
				across ic.parents as ic_parent loop
					l_builder.add_inheritance (ic.name, ic_parent.parent_name)
				end
			end

			-- Skip page_sizer - we set layout attributes directly above

			l_result := l_builder.to_svg_file (a_output_path)
			if l_result.is_success then
				log.info ("    Created: " + a_output_path)
			else
				log.error ("    Failed to create: " + a_output_path)
			end
		end

	generate_dependencies (a_output_path: STRING)
			-- Generate library dependencies graph.
		local
			l_builder: DEPENDENCY_BUILDER
			l_result: GRAPHVIZ_RESULT
			l_max_label: INTEGER
		do
			log.info ("  Generating dependencies.svg...")
			create l_builder.make (renderer)
			l_builder.set_title (ecf_parser.library_name + " - Dependencies").do_nothing
			-- LR layout: main lib on left, deps on right (more vertical result)
			l_builder.graph.attributes.put ("rankdir", "LR")
			l_builder.graph.attributes.put ("nodesep", "0.5")
			l_builder.graph.attributes.put ("ranksep", "2.0")
			l_builder.graph.attributes.put ("fontsize", "14")
			l_builder.graph.attributes.put ("splines", "ortho")

			-- Add main library
			l_builder.add_library (ecf_parser.library_name, False)
			l_max_label := ecf_parser.library_name.count

			-- Add internal dependencies (check for duplicates)
			across ecf_parser.internal_dependencies as ic loop
				if not l_builder.graph.has_node (ic.name) then
					l_builder.add_library (ic.name, False)
					l_max_label := l_max_label.max (ic.name.count)
				end
				l_builder.add_dependency (ecf_parser.library_name, ic.name)
			end

			-- Add external dependencies (check for duplicates)
			across ecf_parser.external_dependencies as ic loop
				if not l_builder.graph.has_node (ic.name) then
					l_builder.add_library (ic.name, True)
					l_max_label := l_max_label.max (ic.name.count)
				end
				l_builder.add_dependency (ecf_parser.library_name, ic.name)
			end

			-- Skip page_sizer - we set layout attributes directly above

			l_result := l_builder.to_svg_file (a_output_path)
			if l_result.is_success then
				log.info ("    Created: " + a_output_path)
			else
				log.error ("    Failed to create: " + a_output_path)
			end
		end

	generate_api_surface (a_output_path: STRING)
			-- Generate API surface (public classes/features) graph.
			-- Uses sfdp (scalable force-directed) engine for better layout of dense content.
		local
			l_builder: BON_DIAGRAM_BUILDER
			l_result: GRAPHVIZ_RESULT
			l_features: ARRAYED_LIST [STRING]
			l_max_label: INTEGER
			l_label_len: INTEGER
			l_old_engine: STRING
		do
			log.info ("  Generating api_surface.svg...")
			-- Use fdp for 2D force-directed layout (spreads nodes evenly)
			l_old_engine := renderer.engine.twin
			renderer.set_engine ("fdp").do_nothing
			renderer.disable_boundary_constraints.do_nothing
			create l_builder.make (renderer)
			l_builder.set_title (ecf_parser.library_name + " - API Surface").do_nothing
			l_builder := l_builder.set_include_features (True)
			-- fdp-specific settings for good spreading
			l_builder.graph.attributes.put ("K", "3.0")
			l_builder.graph.attributes.put ("repulsiveforce", "2.0")
			l_builder.graph.attributes.put ("splines", "true")
			l_builder.graph.attributes.put ("overlap", "false")
			l_builder.graph.attributes.put ("fontsize", "10")

			-- Add classes with public features
			l_max_label := 0
			across parsed_classes as ic loop
				-- Collect public features
				create l_features.make (10)
				across ic.features as ic_feat loop
					if ic_feat.export_status.same_string ("ANY") then
						l_features.extend (ic_feat.name)
					end
				end

				-- Calculate label length (class name + features)
				l_label_len := ic.name.count
				across l_features as ic_f loop
					l_label_len := l_label_len.max (ic_f.count)
				end
				l_max_label := l_max_label.max (l_label_len)

				-- Add class to diagram
				if l_features.is_empty then
					l_builder.add_class (ic.name, ic.is_deferred, ic.is_expanded)
				else
					l_builder.add_class_with_features (ic.name, l_features, ic.is_deferred, ic.is_expanded)
				end

				-- Add inheritance
				across ic.parents as ic_parent loop
					-- Only add if parent is in our library
					if has_class (ic_parent.parent_name) then
						l_builder.add_inheritance (ic.name, ic_parent.parent_name)
					end
				end
			end

			-- Apply automatic page sizing (not strictly hierarchical for BON diagrams)
			page_sizer.apply_to_graph (l_builder.graph, l_builder.graph.node_count, l_builder.graph.edge_count, l_max_label, False)

			l_result := l_builder.to_svg_file (a_output_path)
			if l_result.is_success then
				log.info ("    Created: " + a_output_path)
			else
				log.error ("    Failed to create: " + a_output_path)
			end

			-- Restore original engine and disable boundary constraints
			renderer.set_engine (l_old_engine).do_nothing
			renderer.disable_boundary_constraints.do_nothing
		end

	generate_contract_coverage (a_output_path: STRING)
			-- Generate DBC coverage graph.
			-- Uses sfdp (scalable force-directed) engine for better layout of dense content.
		local
			l_builder: CONTRACT_COVERAGE_BUILDER
			l_result: GRAPHVIZ_RESULT
			l_features: ARRAYED_LIST [TUPLE [name: STRING; has_require: BOOLEAN; has_ensure: BOOLEAN; is_attribute: BOOLEAN]]
			l_max_label: INTEGER
			l_old_engine: STRING
		do
			log.info ("  Generating contract_coverage.svg...")
			-- Use fdp for 2D force-directed layout (spreads nodes evenly)
			l_old_engine := renderer.engine.twin
			renderer.set_engine ("fdp").do_nothing
			renderer.disable_boundary_constraints.do_nothing
			create l_builder.make (renderer)
			l_builder.set_title (ecf_parser.library_name + " - Contract Coverage").do_nothing
			-- fdp-specific settings for good spreading
			l_builder.graph.attributes.put ("K", "3.0")
			l_builder.graph.attributes.put ("repulsiveforce", "2.0")
			l_builder.graph.attributes.put ("splines", "true")
			l_builder.graph.attributes.put ("overlap", "false")
			l_builder.graph.attributes.put ("fontsize", "10")

			-- Add classes with feature contract info
			l_max_label := 0
			across parsed_classes as ic loop
				create l_features.make (ic.features.count)
				l_max_label := l_max_label.max (ic.name.count)

				across ic.features as ic_feat loop
					l_features.extend ([
						ic_feat.name,
						not ic_feat.precondition.is_empty,
						not ic_feat.postcondition.is_empty,
						ic_feat.is_attribute
					])
					l_max_label := l_max_label.max (ic_feat.name.count)
				end

				l_builder.add_class (ic.name, l_features)
			end

			-- Add legend
			l_builder.add_legend

			-- Apply automatic page sizing (not hierarchical for coverage diagrams)
			page_sizer.apply_to_graph (l_builder.graph, l_builder.graph.node_count, l_builder.graph.edge_count, l_max_label, False)

			l_result := l_builder.to_svg_file (a_output_path)
			if l_result.is_success then
				log.info ("    Created: " + a_output_path)
				log.info ("    Coverage: " + l_builder.coverage_percentage.out + "%%")
			else
				log.error ("    Failed to create: " + a_output_path)
			end

			-- Restore original engine and disable boundary constraints
			renderer.set_engine (l_old_engine).do_nothing
			renderer.disable_boundary_constraints.do_nothing
		end

feature {NONE} -- Helpers

	has_class (a_name: STRING): BOOLEAN
			-- Is there a parsed class with `a_name'?
		do
			Result := across parsed_classes as ic some ic.name.is_case_insensitive_equal (a_name) end
		end

	ensure_directory_exists (a_path: STRING)
			-- Create directory and all parent directories if they don't exist.
		local
			l_dir: DIRECTORY
			l_normalized: STRING
			l_parts: LIST [STRING]
			l_current: STRING
			l_part: STRING
		do
			-- Normalize path: replace backslashes with forward slashes
			l_normalized := a_path.twin
			l_normalized.replace_substring_all ("\", "/")

			-- Remove trailing slash if present
			if l_normalized.count > 1 and then l_normalized.item (l_normalized.count) = '/' then
				l_normalized.remove_tail (1)
			end

			-- Split path and create each level
			l_parts := l_normalized.split ('/')
			create l_current.make_empty

			across l_parts as ic loop
				l_part := ic.twin
				l_part.left_adjust
				l_part.right_adjust

				if not l_part.is_empty then
					if l_part.same_string (".") then
						-- Relative path marker
						if l_current.is_empty then
							l_current := "."
						end
					elseif l_part.same_string ("..") then
						-- Parent directory - skip for safety
					elseif l_current.is_empty then
						-- First component
						if l_part.count = 1 and then l_part.item (1).is_alpha then
							-- Drive letter on Windows (e.g., "d" from "/d/...")
							l_current := l_part + ":"
						else
							-- Unix absolute or relative path component
							l_current := l_part
						end
					else
						-- Append component
						l_current := l_current + "/" + l_part
					end

					-- Create directory if it doesn't exist and isn't just a drive letter
					if l_current.count > 2 or else not l_current.ends_with (":") then
						create l_dir.make (l_current)
						if not l_dir.exists then
							log.debug_log ("Creating directory: " + l_current)
							l_dir.create_dir
						end
					end
				end
			end
		end

invariant
	renderer_not_void: renderer /= Void
	ecf_parser_not_void: ecf_parser /= Void
	eiffel_parser_not_void: eiffel_parser /= Void
	parsed_classes_not_void: parsed_classes /= Void
	page_sizer_not_void: page_sizer /= Void

end
