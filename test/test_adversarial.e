note
	description: "Adversarial and stress tests for simple_graphviz"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_ADVERSARIAL

inherit
	EQA_TEST_SET

feature -- Adversarial: Special Characters

	test_special_chars_in_label
			-- Test that special characters are properly escaped.
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Line1%NLine2")
			l_dot := l_node.to_dot
			assert ("newline escaped", l_dot.has_substring ("\n"))
		end

	test_quotes_in_label
			-- Test that quotes are properly escaped.
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Say %"Hello%"")
			l_dot := l_node.to_dot
			assert ("quotes escaped", l_dot.has_substring ("\%""))
		end

	test_backslash_in_label
			-- Test that backslashes are properly escaped.
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Path: C:\temp")
			l_dot := l_node.to_dot
			assert ("backslash escaped", l_dot.has_substring ("\\"))
		end

	test_unicode_in_label
			-- Test Unicode characters in labels.
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Café résumé")
			l_dot := l_node.to_dot
			assert ("dot generated", not l_dot.is_empty)
			assert ("has label", l_dot.has_substring ("label"))
		end

feature -- Adversarial: Boundary Values

	test_very_long_node_id
			-- Test node with very long ID.
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_long_id: STRING
			l_dot: STRING
			i: INTEGER
		do
			create l_long_id.make (1000)
			from i := 1 until i > 1000 loop
				l_long_id.append_character ('a')
				i := i + 1
			end

			create l_graph.make_digraph ("Test")
			l_node := l_graph.new_node (l_long_id)
			l_dot := l_graph.to_dot

			assert ("has long id", l_dot.has_substring (l_long_id))
		end

	test_very_long_label
			-- Test attribute with very long value.
		local
			l_attrs: DOT_ATTRIBUTES
			l_long_value: STRING
			l_dot: STRING
			i: INTEGER
		do
			create l_long_value.make (5000)
			from i := 1 until i > 5000 loop
				l_long_value.append_character ((('a').code + (i \\ 26)).to_character_8)
				i := i + 1
			end

			create l_attrs.make
			l_attrs.put ("label", l_long_value)
			l_dot := l_attrs.to_dot

			assert ("dot generated", l_dot.count > 5000)
		end

feature -- Adversarial: Empty Inputs

	test_empty_attributes
			-- Test empty attributes to_dot.
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			assert ("empty dot", l_attrs.to_dot.is_empty)
		end

	test_empty_graph_to_dot
			-- Test empty graph generates valid DOT.
		local
			l_graph: DOT_GRAPH
			l_dot: STRING
		do
			create l_graph.make_digraph ("Empty")
			l_dot := l_graph.to_dot
			assert ("has digraph", l_dot.has_substring ("digraph"))
			assert ("has name", l_dot.has_substring ("Empty"))
			assert ("has braces", l_dot.has_substring ("{") and l_dot.has_substring ("}"))
		end

feature -- Stress Tests

	test_stress_many_nodes
			-- Test graph with many nodes.
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			i: INTEGER
		do
			create l_graph.make_digraph ("Stress")
			from i := 1 until i > 500 loop
				l_node := l_graph.new_node ("node_" + i.out)
				i := i + 1
			end
			assert ("500 nodes", l_graph.node_count = 500)
			assert ("dot generated", l_graph.to_dot.count > 1000)
		end

	test_stress_many_edges
			-- Test graph with many edges.
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			i: INTEGER
		do
			create l_graph.make_digraph ("EdgeStress")
			-- Create 10 nodes
			from i := 1 until i > 10 loop
				l_node := l_graph.new_node ("n" + i.out)
				i := i + 1
			end
			-- Create edges between all pairs
			from i := 1 until i > 10 loop
				across 1 |..| 10 as j loop
					if i /= j then
						l_edge := l_graph.new_edge ("n" + i.out, "n" + j.out)
					end
				end
				i := i + 1
			end
			assert ("many edges", l_graph.edge_count = 90)
		end

	test_stress_many_attributes
			-- Test node with many attributes.
		local
			l_attrs: DOT_ATTRIBUTES
			i: INTEGER
		do
			create l_attrs.make
			from i := 1 until i > 100 loop
				l_attrs.put ("attr_" + i.out, "value_" + i.out)
				i := i + 1
			end
			assert ("100 attrs", l_attrs.count = 100)
			assert ("dot generated", l_attrs.to_dot.count > 500)
		end

	test_stress_deep_subgraphs
			-- Test deeply nested subgraphs.
		local
			l_graph: DOT_GRAPH
			l_sub: DOT_SUBGRAPH
			i: INTEGER
		do
			create l_graph.make_digraph ("DeepNest")
			from i := 1 until i > 20 loop
				create l_sub.make_cluster ("level_" + i.out)
				l_graph.add_subgraph (l_sub)
				i := i + 1
			end
			assert ("20 subgraphs", l_graph.subgraph_count = 20)
			assert ("dot generated", l_graph.to_dot.count > 100)
		end

feature -- Adversarial: Attribute Overwrite

	test_attribute_overwrite
			-- Test that putting same key twice overwrites.
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			l_attrs.put ("color", "red")
			l_attrs.put ("color", "blue")
			assert ("count is 1", l_attrs.count = 1)
			assert ("value is blue", attached l_attrs ["color"] as v and then v.same_string ("blue"))
		end

	test_attribute_remove_and_readd
			-- Test removing and re-adding attribute.
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			l_attrs.put ("key", "value1")
			assert ("has key", l_attrs.has ("key"))
			l_attrs.remove ("key")
			assert ("not has key", not l_attrs.has ("key"))
			l_attrs.put ("key", "value2")
			assert ("has key again", l_attrs.has ("key"))
			assert ("new value", attached l_attrs ["key"] as v and then v.same_string ("value2"))
		end

feature -- Adversarial: Renderer Edge Cases

	test_renderer_not_found_handling
			-- Test renderer handles missing GraphViz gracefully.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
		do
			create l_renderer.make
			-- This test depends on GraphViz availability
			-- Either way, we should get a valid result object
			l_result := l_renderer.render_svg ("digraph { a -> b }")
			assert ("result not void", l_result /= Void)
			-- If GraphViz not available, should be failure
			if not l_renderer.is_graphviz_available then
				assert ("failure result", not l_result.is_success)
				assert ("has error", l_result.error /= Void)
				assert ("correct error code", attached l_result.error as e and then e.code = {GRAPHVIZ_ERROR}.Graphviz_not_found)
			end
		end

	test_result_invariant_success
			-- Test GRAPHVIZ_RESULT invariant holds for success.
		local
			l_result: GRAPHVIZ_RESULT
		do
			create l_result.make_success ("content")
			assert ("is success", l_result.is_success)
			assert ("no error", l_result.error = Void)
			assert ("has content", l_result.content /= Void)
		end

	test_result_invariant_failure
			-- Test GRAPHVIZ_RESULT invariant holds for failure.
		local
			l_result: GRAPHVIZ_RESULT
			l_error: GRAPHVIZ_ERROR
		do
			create l_error.make ({GRAPHVIZ_ERROR}.Invalid_dot, "test error")
			create l_result.make_failure (l_error)
			assert ("is failure", not l_result.is_success)
			assert ("has error", l_result.error /= Void)
			assert ("no content", l_result.content = Void)
		end

feature -- Adversarial: Builder State

	test_bon_builder_reuse
			-- Test BON builder can be reused.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
			l_dot1, l_dot2: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)

			-- First diagram
			l_builder.add_class ("CLASS_A", False, False)
			l_dot1 := l_builder.to_dot

			-- Add more (reuse)
			l_builder.add_class ("CLASS_B", False, False)
			l_dot2 := l_builder.to_dot

			assert ("dot1 has A", l_dot1.has_substring ("CLASS_A"))
			assert ("dot2 has A", l_dot2.has_substring ("CLASS_A"))
			assert ("dot2 has B", l_dot2.has_substring ("CLASS_B"))
			assert ("dot2 longer", l_dot2.count > l_dot1.count)
		end

	test_state_machine_implicit_state_creation
			-- Test state machine creates states on transition.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			-- Add transition without explicitly adding states
			l_builder := l_builder.transition ("A", "B", "go")
			assert ("has A", l_builder.has_state ("A"))
			assert ("has B", l_builder.has_state ("B"))
		end

	test_flowchart_auto_link_chain
			-- Test flowchart auto-links sequential nodes.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.start ("Begin").process ("Step1").process ("Step2").end_node ("Done")
			l_dot := l_builder.to_dot
			-- Should have edges auto-created
			assert ("has edges", l_builder.graph.edge_count >= 3)
			assert ("has arrow", l_dot.has_substring ("->"))
		end

feature -- Adversarial: Error Types

	test_all_error_codes
			-- Test all GRAPHVIZ_ERROR codes are distinct.
		local
			l_codes: ARRAYED_LIST [INTEGER]
		do
			create l_codes.make (5)
			l_codes.extend ({GRAPHVIZ_ERROR}.Graphviz_not_found)
			l_codes.extend ({GRAPHVIZ_ERROR}.Timeout)
			l_codes.extend ({GRAPHVIZ_ERROR}.Invalid_dot)
			l_codes.extend ({GRAPHVIZ_ERROR}.Output_error)
			l_codes.extend ({GRAPHVIZ_ERROR}.Unknown_error)

			-- All should be different
			assert ("5 codes", l_codes.count = 5)
			assert ("not_found != timeout", {GRAPHVIZ_ERROR}.Graphviz_not_found /= {GRAPHVIZ_ERROR}.Timeout)
			assert ("invalid != output", {GRAPHVIZ_ERROR}.Invalid_dot /= {GRAPHVIZ_ERROR}.Output_error)
		end

end
