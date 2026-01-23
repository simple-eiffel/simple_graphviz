note
	description: "[
		Comprehensive rendering tests using 20 real-world demonstration inputs.

		Tests actual GraphViz C library rendering to SVG, PNG, and PDF formats.
		Verifies output files are created with valid content headers.

		Each demo includes the CLI command to reproduce:
		  simple_graphviz render <input.dot> -o <output> -f <format> [-e <engine>]
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_RENDERING_DEMOS

inherit
	EQA_TEST_SET

feature -- Constants

	Demo_dir: STRING = "demo/inputs/"
			-- Directory containing demo DOT files.

	Output_dir: STRING = "demo/outputs/"
			-- Directory for rendered outputs.

feature -- Demo Catalog

	demo_files: ARRAYED_LIST [TUPLE [name: STRING; engine: STRING; description: STRING]]
			-- List of demo files with recommended engine and description.
		once
			create Result.make (20)
			Result.extend (["01_simple_inheritance", "dot", "Simple class inheritance (Animal/Dog/Cat)"])
			Result.extend (["02_eiffel_class_hierarchy", "dot", "Eiffel ANY class hierarchy"])
			Result.extend (["03_microservices_architecture", "dot", "Microservices with clusters"])
			Result.extend (["04_database_schema", "dot", "Database ER diagram"])
			Result.extend (["05_traffic_light_fsm", "dot", "Traffic light state machine"])
			Result.extend (["06_order_processing_fsm", "dot", "E-commerce order FSM"])
			Result.extend (["07_login_flowchart", "dot", "User login flowchart"])
			Result.extend (["08_cicd_pipeline", "dot", "CI/CD pipeline"])
			Result.extend (["09_network_topology", "neato", "Network topology (spring layout)"])
			Result.extend (["10_library_dependencies", "dot", "Simple Eiffel library deps"])
			Result.extend (["11_org_chart", "dot", "Organization chart"])
			Result.extend (["12_decision_tree", "dot", "Bug triage decision tree"])
			Result.extend (["13_git_branching", "dot", "GitFlow branching strategy"])
			Result.extend (["14_api_sequence", "dot", "REST API request flow"])
			Result.extend (["15_data_pipeline", "dot", "Data processing pipeline"])
			Result.extend (["16_sorting_algorithm", "dot", "QuickSort algorithm flowchart"])
			Result.extend (["17_regex_automaton", "dot", "Regex DFA for a(b|c)*d"])
			Result.extend (["18_mind_map", "twopi", "Mind map (radial layout)"])
			Result.extend (["19_component_diagram", "dot", "Software component diagram"])
			Result.extend (["20_bon_eiffel_design", "dot", "BON Observer pattern"])
		end

feature -- Test: SVG Rendering

	test_render_all_svg
			-- Render all 20 demos to SVG format.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
			l_dot, l_svg: STRING
			l_demo: TUPLE [name: STRING; engine: STRING; description: STRING]
			l_input_path, l_output_path: STRING
			l_passed, l_total: INTEGER
		do
			create l_renderer.make
			if not l_renderer.is_graphviz_available then
				assert ("graphviz_required", False)
			else
				across demo_files as ic loop
					l_demo := ic
					l_input_path := Demo_dir + l_demo.name + ".dot"
					l_output_path := Output_dir + l_demo.name + ".svg"

					l_dot := read_file (l_input_path)
					if not l_dot.is_empty then
						l_renderer := l_renderer.set_engine (l_demo.engine)
						l_result := l_renderer.render_to_file (l_dot, "svg", l_output_path)
						l_total := l_total + 1
						if l_result.is_success and then file_exists (l_output_path) then
							l_svg := read_file (l_output_path)
							if l_svg.has_substring ("<?xml") or l_svg.has_substring ("<svg") then
								l_passed := l_passed + 1
							end
						end
					end
				end
				assert ("all_svg_rendered", l_passed = l_total)
			end
		end

feature -- Test: PNG Rendering

	test_render_all_png
			-- Render all 20 demos to PNG format.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
			l_dot: STRING
			l_demo: TUPLE [name: STRING; engine: STRING; description: STRING]
			l_input_path, l_output_path: STRING
			l_passed, l_total: INTEGER
			l_file: RAW_FILE
			l_header: STRING
		do
			create l_renderer.make
			if not l_renderer.is_graphviz_available then
				assert ("graphviz_required", False)
			else
				across demo_files as ic loop
					l_demo := ic
					l_input_path := Demo_dir + l_demo.name + ".dot"
					l_output_path := Output_dir + l_demo.name + ".png"

					l_dot := read_file (l_input_path)
					if not l_dot.is_empty then
						l_renderer := l_renderer.set_engine (l_demo.engine)
						l_result := l_renderer.render_to_file (l_dot, "png", l_output_path)
						l_total := l_total + 1
						if l_result.is_success and then file_exists (l_output_path) then
							-- Check PNG magic header: 89 50 4E 47 (‰PNG)
							create l_file.make_open_read (l_output_path)
							create l_header.make (8)
							l_file.read_stream (8)
							l_header := l_file.last_string
							l_file.close
							if l_header.count >= 4 and then l_header.item (2) = 'P' and then l_header.item (3) = 'N' and then l_header.item (4) = 'G' then
								l_passed := l_passed + 1
							end
						end
					end
				end
				assert ("all_png_rendered", l_passed = l_total)
			end
		end

feature -- Test: PDF Rendering

	test_render_all_pdf
			-- Render all 20 demos to PDF format.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
			l_dot: STRING
			l_demo: TUPLE [name: STRING; engine: STRING; description: STRING]
			l_input_path, l_output_path: STRING
			l_passed, l_total: INTEGER
			l_file: RAW_FILE
			l_header: STRING
		do
			create l_renderer.make
			if not l_renderer.is_graphviz_available then
				assert ("graphviz_required", False)
			else
				across demo_files as ic loop
					l_demo := ic
					l_input_path := Demo_dir + l_demo.name + ".dot"
					l_output_path := Output_dir + l_demo.name + ".pdf"

					l_dot := read_file (l_input_path)
					if not l_dot.is_empty then
						l_renderer := l_renderer.set_engine (l_demo.engine)
						l_result := l_renderer.render_to_file (l_dot, "pdf", l_output_path)
						l_total := l_total + 1
						if l_result.is_success and then file_exists (l_output_path) then
							-- Check PDF magic header: %PDF-
							create l_file.make_open_read (l_output_path)
							create l_header.make (8)
							l_file.read_stream (5)
							l_header := l_file.last_string
							l_file.close
							if l_header.same_string ("%%PDF-") then
								l_passed := l_passed + 1
							end
						end
					end
				end
				assert ("all_pdf_rendered", l_passed = l_total)
			end
		end

feature -- Test: Individual Demos with Specific Engines

	test_01_simple_inheritance_svg
			-- CLI: simple_graphviz render demo/inputs/01_simple_inheritance.dot -o demo/outputs/01_simple_inheritance.svg
		do
			render_and_verify ("01_simple_inheritance", "dot", "svg")
		end

	test_02_eiffel_hierarchy_svg
			-- CLI: simple_graphviz render demo/inputs/02_eiffel_class_hierarchy.dot -o demo/outputs/02_eiffel_class_hierarchy.svg
		do
			render_and_verify ("02_eiffel_class_hierarchy", "dot", "svg")
		end

	test_03_microservices_svg
			-- CLI: simple_graphviz render demo/inputs/03_microservices_architecture.dot -o demo/outputs/03_microservices_architecture.svg
		do
			render_and_verify ("03_microservices_architecture", "dot", "svg")
		end

	test_04_database_schema_svg
			-- CLI: simple_graphviz render demo/inputs/04_database_schema.dot -o demo/outputs/04_database_schema.svg
		do
			render_and_verify ("04_database_schema", "dot", "svg")
		end

	test_05_traffic_light_svg
			-- CLI: simple_graphviz render demo/inputs/05_traffic_light_fsm.dot -o demo/outputs/05_traffic_light_fsm.svg
		do
			render_and_verify ("05_traffic_light_fsm", "dot", "svg")
		end

	test_06_order_processing_svg
			-- CLI: simple_graphviz render demo/inputs/06_order_processing_fsm.dot -o demo/outputs/06_order_processing_fsm.svg
		do
			render_and_verify ("06_order_processing_fsm", "dot", "svg")
		end

	test_07_login_flowchart_svg
			-- CLI: simple_graphviz render demo/inputs/07_login_flowchart.dot -o demo/outputs/07_login_flowchart.svg
		do
			render_and_verify ("07_login_flowchart", "dot", "svg")
		end

	test_08_cicd_pipeline_svg
			-- CLI: simple_graphviz render demo/inputs/08_cicd_pipeline.dot -o demo/outputs/08_cicd_pipeline.svg
		do
			render_and_verify ("08_cicd_pipeline", "dot", "svg")
		end

	test_09_network_topology_neato
			-- CLI: simple_graphviz render demo/inputs/09_network_topology.dot -o demo/outputs/09_network_topology.svg -e neato
		do
			render_and_verify ("09_network_topology", "neato", "svg")
		end

	test_10_library_deps_svg
			-- CLI: simple_graphviz render demo/inputs/10_library_dependencies.dot -o demo/outputs/10_library_dependencies.svg
		do
			render_and_verify ("10_library_dependencies", "dot", "svg")
		end

	test_11_org_chart_svg
			-- CLI: simple_graphviz render demo/inputs/11_org_chart.dot -o demo/outputs/11_org_chart.svg
		do
			render_and_verify ("11_org_chart", "dot", "svg")
		end

	test_12_decision_tree_svg
			-- CLI: simple_graphviz render demo/inputs/12_decision_tree.dot -o demo/outputs/12_decision_tree.svg
		do
			render_and_verify ("12_decision_tree", "dot", "svg")
		end

	test_13_git_branching_svg
			-- CLI: simple_graphviz render demo/inputs/13_git_branching.dot -o demo/outputs/13_git_branching.svg
		do
			render_and_verify ("13_git_branching", "dot", "svg")
		end

	test_14_api_sequence_svg
			-- CLI: simple_graphviz render demo/inputs/14_api_sequence.dot -o demo/outputs/14_api_sequence.svg
		do
			render_and_verify ("14_api_sequence", "dot", "svg")
		end

	test_15_data_pipeline_svg
			-- CLI: simple_graphviz render demo/inputs/15_data_pipeline.dot -o demo/outputs/15_data_pipeline.svg
		do
			render_and_verify ("15_data_pipeline", "dot", "svg")
		end

	test_16_sorting_algorithm_svg
			-- CLI: simple_graphviz render demo/inputs/16_sorting_algorithm.dot -o demo/outputs/16_sorting_algorithm.svg
		do
			render_and_verify ("16_sorting_algorithm", "dot", "svg")
		end

	test_17_regex_automaton_svg
			-- CLI: simple_graphviz render demo/inputs/17_regex_automaton.dot -o demo/outputs/17_regex_automaton.svg
		do
			render_and_verify ("17_regex_automaton", "dot", "svg")
		end

	test_18_mind_map_twopi
			-- CLI: simple_graphviz render demo/inputs/18_mind_map.dot -o demo/outputs/18_mind_map.svg -e twopi
		do
			render_and_verify ("18_mind_map", "twopi", "svg")
		end

	test_19_component_diagram_svg
			-- CLI: simple_graphviz render demo/inputs/19_component_diagram.dot -o demo/outputs/19_component_diagram.svg
		do
			render_and_verify ("19_component_diagram", "dot", "svg")
		end

	test_20_bon_observer_svg
			-- CLI: simple_graphviz render demo/inputs/20_bon_eiffel_design.dot -o demo/outputs/20_bon_eiffel_design.svg
		do
			render_and_verify ("20_bon_eiffel_design", "dot", "svg")
		end

feature {NONE} -- Implementation

	render_and_verify (a_name, a_engine, a_format: STRING)
			-- Render demo `a_name` with `a_engine` to `a_format` and verify output.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
			l_dot, l_content: STRING
			l_input_path, l_output_path: STRING
		do
			create l_renderer.make
			if l_renderer.is_graphviz_available then
				l_input_path := Demo_dir + a_name + ".dot"
				l_output_path := Output_dir + a_name + "." + a_format

				l_dot := read_file (l_input_path)
				assert ("input_exists_" + a_name, not l_dot.is_empty)

				l_renderer := l_renderer.set_engine (a_engine)
				l_result := l_renderer.render_to_file (l_dot, a_format, l_output_path)

				assert ("render_success_" + a_name, l_result.is_success)
				assert ("output_exists_" + a_name, file_exists (l_output_path))

				-- Verify content based on format
				if a_format.same_string ("svg") then
					l_content := read_file (l_output_path)
					assert ("valid_svg_" + a_name, l_content.has_substring ("<svg") or l_content.has_substring ("<?xml"))
				end
			else
				-- Skip if GraphViz not available
				assert ("graphviz_not_available_skip", True)
			end
		end

	read_file (a_path: STRING): STRING
			-- Read file content from `a_path`.
		local
			l_file: PLAIN_TEXT_FILE
		do
			create l_file.make_with_name (a_path)
			if l_file.exists and l_file.is_readable then
				l_file.open_read
				create Result.make (l_file.count.to_integer_32)
				l_file.read_stream (l_file.count.to_integer_32)
				Result := l_file.last_string
				l_file.close
			else
				Result := ""
			end
		end

	file_exists (a_path: STRING): BOOLEAN
			-- Does file at `a_path` exist?
		local
			l_file: RAW_FILE
		do
			create l_file.make_with_name (a_path)
			Result := l_file.exists
		end

end
