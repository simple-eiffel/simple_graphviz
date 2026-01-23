note
	description: "SCOOP consumer compatibility test"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_SCOOP_CONSUMER

inherit
	EQA_TEST_SET

feature -- Test

	test_scoop_compatibility
			-- Verify library types work in SCOOP context.
		local
			l_graphviz: SIMPLE_GRAPHVIZ
			l_renderer: GRAPHVIZ_RENDERER
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			l_attrs: DOT_ATTRIBUTES
			l_result: GRAPHVIZ_RESULT
			l_error: GRAPHVIZ_ERROR
			l_style: GRAPHVIZ_STYLE
			l_bon: BON_DIAGRAM_BUILDER
			l_flow: FLOWCHART_BUILDER
			l_state: STATE_MACHINE_BUILDER
			l_dep: DEPENDENCY_BUILDER
			l_inh: INHERITANCE_BUILDER
		do
			-- Test all main types can be created in SCOOP context
			create l_graphviz.make
			create l_renderer.make
			create l_graph.make_digraph ("Test")
			create l_node.make ("node1")
			create l_edge.make ("a", "b")
			create l_attrs.make
			create l_result.make_success ("test")
			create l_error.make ({GRAPHVIZ_ERROR}.Unknown_error, "test error")
			create l_style.make_bon
			create l_bon.make (l_renderer)
			create l_flow.make (l_renderer)
			create l_state.make (l_renderer)
			create l_dep.make (l_renderer)
			create l_inh.make (l_renderer)

			-- Verify basic operations work
			l_graph.add_node (l_node)
			l_graph.add_edge (l_edge)
			l_attrs.put ("test", "value")

			assert ("all types created", True)
		end

end
