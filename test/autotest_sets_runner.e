note
	description: "[
		Runs the tests in simple_graphviz's AutoTest test sets that TEST_APP did not call
		(port-coordination #17: 86 of them ran in no gate). Each goes through AutoTest's own
		EQA_TEST_EVALUATOR: a fresh test set (on_prepare), the test, then clean (on_clean),
		as AutoTest runs it. A failing test prints "FAIL:" with its tag and is counted.
	]"

class
	AUTOTEST_SETS_RUNNER

feature -- Counts

	passed, failed: INTEGER
			-- Tests run here.

feature -- Running

	run_all
			-- Every test below, 86 in all.
		do
			run_test_adversarial
			run_test_builders
			run_test_dot_graph
			run_test_rendering_demos
			run_test_scoop_consumer
			run_test_simple_graphviz
		end

feature {NONE} -- Test sets

	run_test_adversarial
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_ADVERSARIAL]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_special_chars_in_label), "TEST_ADVERSARIAL.test_special_chars_in_label")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_quotes_in_label), "TEST_ADVERSARIAL.test_quotes_in_label")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_backslash_in_label), "TEST_ADVERSARIAL.test_backslash_in_label")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_unicode_in_label), "TEST_ADVERSARIAL.test_unicode_in_label")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_very_long_node_id), "TEST_ADVERSARIAL.test_very_long_node_id")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_very_long_label), "TEST_ADVERSARIAL.test_very_long_label")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_empty_attributes), "TEST_ADVERSARIAL.test_empty_attributes")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_empty_graph_to_dot), "TEST_ADVERSARIAL.test_empty_graph_to_dot")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_stress_many_nodes), "TEST_ADVERSARIAL.test_stress_many_nodes")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_stress_many_edges), "TEST_ADVERSARIAL.test_stress_many_edges")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_stress_many_attributes), "TEST_ADVERSARIAL.test_stress_many_attributes")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_stress_deep_subgraphs), "TEST_ADVERSARIAL.test_stress_deep_subgraphs")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_attribute_overwrite), "TEST_ADVERSARIAL.test_attribute_overwrite")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_attribute_remove_and_readd), "TEST_ADVERSARIAL.test_attribute_remove_and_readd")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_renderer_not_found_handling), "TEST_ADVERSARIAL.test_renderer_not_found_handling")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_result_invariant_success), "TEST_ADVERSARIAL.test_result_invariant_success")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_result_invariant_failure), "TEST_ADVERSARIAL.test_result_invariant_failure")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_bon_builder_reuse), "TEST_ADVERSARIAL.test_bon_builder_reuse")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_state_machine_implicit_state_creation), "TEST_ADVERSARIAL.test_state_machine_implicit_state_creation")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_flowchart_auto_link_chain), "TEST_ADVERSARIAL.test_flowchart_auto_link_chain")
			report (l_evaluator.execute (agent {TEST_ADVERSARIAL}.test_all_error_codes), "TEST_ADVERSARIAL.test_all_error_codes")
		end

	run_test_builders
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_BUILDERS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_bon_builder_creation), "TEST_BUILDERS.test_bon_builder_creation")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_bon_add_class), "TEST_BUILDERS.test_bon_add_class")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_bon_add_deferred_class), "TEST_BUILDERS.test_bon_add_deferred_class")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_bon_add_inheritance), "TEST_BUILDERS.test_bon_add_inheritance")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_bon_to_dot), "TEST_BUILDERS.test_bon_to_dot")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_flowchart_creation), "TEST_BUILDERS.test_flowchart_creation")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_flowchart_basic_flow), "TEST_BUILDERS.test_flowchart_basic_flow")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_flowchart_decision), "TEST_BUILDERS.test_flowchart_decision")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_state_machine_creation), "TEST_BUILDERS.test_state_machine_creation")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_state_machine_states), "TEST_BUILDERS.test_state_machine_states")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_state_machine_transitions), "TEST_BUILDERS.test_state_machine_transitions")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_dependency_creation), "TEST_BUILDERS.test_dependency_creation")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_dependency_add_libraries), "TEST_BUILDERS.test_dependency_add_libraries")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_inheritance_creation), "TEST_BUILDERS.test_inheritance_creation")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_inheritance_add_classes), "TEST_BUILDERS.test_inheritance_add_classes")
			report (l_evaluator.execute (agent {TEST_BUILDERS}.test_inheritance_root_filter), "TEST_BUILDERS.test_inheritance_root_filter")
		end

	run_test_dot_graph
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_DOT_GRAPH]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_attributes_empty), "TEST_DOT_GRAPH.test_attributes_empty")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_attributes_put_and_get), "TEST_DOT_GRAPH.test_attributes_put_and_get")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_attributes_to_dot), "TEST_DOT_GRAPH.test_attributes_to_dot")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_attributes_escape_value), "TEST_DOT_GRAPH.test_attributes_escape_value")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_node_creation), "TEST_DOT_GRAPH.test_node_creation")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_node_fluent_api), "TEST_DOT_GRAPH.test_node_fluent_api")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_node_to_dot), "TEST_DOT_GRAPH.test_node_to_dot")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_edge_creation), "TEST_DOT_GRAPH.test_edge_creation")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_edge_to_dot_directed), "TEST_DOT_GRAPH.test_edge_to_dot_directed")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_edge_to_dot_undirected), "TEST_DOT_GRAPH.test_edge_to_dot_undirected")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_graph_digraph), "TEST_DOT_GRAPH.test_graph_digraph")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_graph_add_nodes), "TEST_DOT_GRAPH.test_graph_add_nodes")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_graph_new_node), "TEST_DOT_GRAPH.test_graph_new_node")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_graph_to_dot), "TEST_DOT_GRAPH.test_graph_to_dot")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_graph_undirected), "TEST_DOT_GRAPH.test_graph_undirected")
			report (l_evaluator.execute (agent {TEST_DOT_GRAPH}.test_subgraph_cluster), "TEST_DOT_GRAPH.test_subgraph_cluster")
		end

	run_test_rendering_demos
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_RENDERING_DEMOS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_render_all_svg), "TEST_RENDERING_DEMOS.test_render_all_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_render_all_png), "TEST_RENDERING_DEMOS.test_render_all_png")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_render_all_pdf), "TEST_RENDERING_DEMOS.test_render_all_pdf")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_01_simple_inheritance_svg), "TEST_RENDERING_DEMOS.test_01_simple_inheritance_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_02_eiffel_hierarchy_svg), "TEST_RENDERING_DEMOS.test_02_eiffel_hierarchy_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_03_microservices_svg), "TEST_RENDERING_DEMOS.test_03_microservices_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_04_database_schema_svg), "TEST_RENDERING_DEMOS.test_04_database_schema_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_05_traffic_light_svg), "TEST_RENDERING_DEMOS.test_05_traffic_light_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_06_order_processing_svg), "TEST_RENDERING_DEMOS.test_06_order_processing_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_07_login_flowchart_svg), "TEST_RENDERING_DEMOS.test_07_login_flowchart_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_08_cicd_pipeline_svg), "TEST_RENDERING_DEMOS.test_08_cicd_pipeline_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_09_network_topology_neato), "TEST_RENDERING_DEMOS.test_09_network_topology_neato")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_10_library_deps_svg), "TEST_RENDERING_DEMOS.test_10_library_deps_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_11_org_chart_svg), "TEST_RENDERING_DEMOS.test_11_org_chart_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_12_decision_tree_svg), "TEST_RENDERING_DEMOS.test_12_decision_tree_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_13_git_branching_svg), "TEST_RENDERING_DEMOS.test_13_git_branching_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_14_api_sequence_svg), "TEST_RENDERING_DEMOS.test_14_api_sequence_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_15_data_pipeline_svg), "TEST_RENDERING_DEMOS.test_15_data_pipeline_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_16_sorting_algorithm_svg), "TEST_RENDERING_DEMOS.test_16_sorting_algorithm_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_17_regex_automaton_svg), "TEST_RENDERING_DEMOS.test_17_regex_automaton_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_18_mind_map_twopi), "TEST_RENDERING_DEMOS.test_18_mind_map_twopi")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_19_component_diagram_svg), "TEST_RENDERING_DEMOS.test_19_component_diagram_svg")
			report (l_evaluator.execute (agent {TEST_RENDERING_DEMOS}.test_20_bon_observer_svg), "TEST_RENDERING_DEMOS.test_20_bon_observer_svg")
		end

	run_test_scoop_consumer
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_SCOOP_CONSUMER]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_SCOOP_CONSUMER}.test_scoop_compatibility), "TEST_SCOOP_CONSUMER.test_scoop_compatibility")
		end

	run_test_simple_graphviz
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_SIMPLE_GRAPHVIZ]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_creation), "TEST_SIMPLE_GRAPHVIZ.test_creation")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_builder_access), "TEST_SIMPLE_GRAPHVIZ.test_builder_access")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_graph_access), "TEST_SIMPLE_GRAPHVIZ.test_graph_access")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_undirected_graph), "TEST_SIMPLE_GRAPHVIZ.test_undirected_graph")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_engine_setting), "TEST_SIMPLE_GRAPHVIZ.test_engine_setting")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_timeout_setting), "TEST_SIMPLE_GRAPHVIZ.test_timeout_setting")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_full_bon_diagram_workflow), "TEST_SIMPLE_GRAPHVIZ.test_full_bon_diagram_workflow")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_full_state_machine_workflow), "TEST_SIMPLE_GRAPHVIZ.test_full_state_machine_workflow")
			report (l_evaluator.execute (agent {TEST_SIMPLE_GRAPHVIZ}.test_full_flowchart_workflow), "TEST_SIMPLE_GRAPHVIZ.test_full_flowchart_workflow")
		end

feature {NONE} -- Implementation

	report (a_result: EQA_PARTIAL_RESULT; a_name: STRING)
			-- Count and print `a_result' of test `a_name'.
		do
			if a_result.is_pass then
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			else
				print ("  FAIL: " + a_name + " [" + {UTF_CONVERTER}.string_32_to_utf_8_string_8 (a_result.tag) + "]%N")
				failed := failed + 1
			end
		end

end
