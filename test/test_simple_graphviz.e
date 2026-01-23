note
	description: "Tests for SIMPLE_GRAPHVIZ facade"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_SIMPLE_GRAPHVIZ

inherit
	EQA_TEST_SET

feature -- Test: Facade

	test_creation
			-- Test facade creation.
		local
			l_gv: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			assert ("renderer exists", l_gv.renderer /= Void)
		end

	test_builder_access
			-- Test accessing builders.
		local
			l_gv: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			assert ("bon_diagram", l_gv.bon_diagram /= Void)
			assert ("flowchart", l_gv.flowchart /= Void)
			assert ("state_machine", l_gv.state_machine /= Void)
			assert ("dependency_graph", l_gv.dependency_graph /= Void)
			assert ("inheritance_tree", l_gv.inheritance_tree /= Void)
		end

	test_graph_access
			-- Test accessing raw graph.
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_graph: DOT_GRAPH
		do
			create l_gv.make
			l_graph := l_gv.graph
			assert ("graph exists", l_graph /= Void)
			assert ("is directed", l_graph.is_directed)
		end

	test_undirected_graph
			-- Test undirected graph access.
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_graph: DOT_GRAPH
		do
			create l_gv.make
			l_graph := l_gv.undirected_graph
			assert ("graph exists", l_graph /= Void)
			assert ("not directed", not l_graph.is_directed)
		end

	test_engine_setting
			-- Test engine configuration.
		local
			l_gv, l_result: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			l_result := l_gv.set_engine ("neato")
			assert ("engine set", l_gv.renderer.engine.same_string ("neato"))
			assert ("result is current", l_result = l_gv)
		end

	test_timeout_setting
			-- Test timeout configuration.
		local
			l_gv, l_result: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			l_result := l_gv.set_timeout (60_000)
			assert ("timeout set", l_gv.renderer.timeout_ms = 60_000)
			assert ("result is current", l_result = l_gv)
		end

feature -- Test: Integration

	test_full_bon_diagram_workflow
			-- Test complete BON diagram workflow (DOT generation only).
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_builder: BON_DIAGRAM_BUILDER
			l_dot: STRING
		do
			create l_gv.make
			l_builder := l_gv.bon_diagram
			l_builder.add_class ("ANIMAL", True, False)
			l_builder.add_class ("DOG", False, False)
			l_builder.add_inheritance ("DOG", "ANIMAL")
			l_dot := l_builder.to_dot
			assert ("has digraph", l_dot.has_substring ("digraph"))
			assert ("has animal", l_dot.has_substring ("ANIMAL"))
			assert ("has dog", l_dot.has_substring ("DOG"))
		end

	test_full_state_machine_workflow
			-- Test complete state machine workflow (DOT generation only).
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_builder: STATE_MACHINE_BUILDER
			l_dot: STRING
		do
			create l_gv.make
			l_builder := l_gv.state_machine
			l_builder := l_builder.initial ("Idle")
				.state ("Running")
				.state ("Paused")
				.transition ("Idle", "Running", "start")
				.transition ("Running", "Paused", "pause")
				.transition ("Paused", "Running", "resume")
				.transition ("Running", "Idle", "stop")
			l_dot := l_builder.to_dot
			assert ("has states", l_dot.has_substring ("Idle") and l_dot.has_substring ("Running"))
			assert ("has transitions", l_dot.has_substring ("start") and l_dot.has_substring ("stop"))
		end

	test_full_flowchart_workflow
			-- Test complete flowchart workflow (DOT generation only).
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
		do
			create l_gv.make
			l_builder := l_gv.flowchart
			l_builder := l_builder.start ("Begin")
				.process ("Process Data")
				.decision ("Valid?", "Yes", "No")
			l_dot := l_builder.to_dot
			assert ("has begin", l_dot.has_substring ("Begin"))
			assert ("has process", l_dot.has_substring ("Process"))
			assert ("has decision", l_dot.has_substring ("Valid"))
		end

end
