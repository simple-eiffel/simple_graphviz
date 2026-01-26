note
	description: "Test application runner for simple_graphviz"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		do
			print ("Running simple_graphviz tests...%N%N")

			run_dot_graph_tests
			run_builder_tests
			run_facade_tests
			run_scoop_tests
			run_renderer_tests
			run_adversarial_tests

			print ("%N================================%N")
			print ("Tests passed: " + passed.out + "%N")
			print ("Tests failed: " + failed.out + "%N")
			print ("================================%N")
		end

feature {NONE} -- Test Execution

	passed, failed: INTEGER

	report (a_name: STRING; a_success: BOOLEAN)
			-- Report test result.
		do
			if a_success then
				print ("  [PASS] " + a_name + "%N")
				passed := passed + 1
			else
				print ("  [FAIL] " + a_name + "%N")
				failed := failed + 1
			end
		end

feature {NONE} -- DOT Graph Tests

	run_dot_graph_tests
		local
			l_test: TEST_DOT_GRAPH
		do
			print ("== DOT Graph Tests ==%N")
			create l_test
			-- DOT_ATTRIBUTES tests
			test_dot_attributes_empty (l_test)
			test_dot_attributes_put_get (l_test)
			test_dot_attributes_to_dot (l_test)
			test_dot_attributes_escape (l_test)
			-- DOT_NODE tests
			test_dot_node_creation (l_test)
			test_dot_node_fluent (l_test)
			test_dot_node_to_dot (l_test)
			-- DOT_EDGE tests
			test_dot_edge_creation (l_test)
			test_dot_edge_directed (l_test)
			test_dot_edge_undirected (l_test)
			-- DOT_GRAPH tests
			test_dot_graph_digraph (l_test)
			test_dot_graph_add_nodes (l_test)
			test_dot_graph_new_node (l_test)
			test_dot_graph_to_dot (l_test)
			test_dot_graph_undirected (l_test)
			-- DOT_SUBGRAPH tests
			test_dot_subgraph_cluster (l_test)
		end

	test_dot_attributes_empty (t: TEST_DOT_GRAPH)
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			report ("attributes_empty", l_attrs.is_empty and l_attrs.count = 0 and l_attrs.to_dot.is_empty)
		rescue
			report ("attributes_empty", False)
		end

	test_dot_attributes_put_get (t: TEST_DOT_GRAPH)
		local
			l_attrs: DOT_ATTRIBUTES
			l_ok: BOOLEAN
		do
			create l_attrs.make
			l_attrs.put ("color", "red")
			l_ok := l_attrs.has ("color") and l_attrs.count = 1
			if attached l_attrs ["color"] as v then
				l_ok := l_ok and v.same_string ("red")
			end
			report ("attributes_put_get", l_ok)
		rescue
			report ("attributes_put_get", False)
		end

	test_dot_attributes_to_dot (t: TEST_DOT_GRAPH)
		local
			l_attrs: DOT_ATTRIBUTES
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_attrs.make
			l_attrs.put ("color", "blue")
			l_attrs.put ("shape", "box")
			l_dot := l_attrs.to_dot
			l_ok := l_dot.starts_with ("[") and l_dot.ends_with ("]")
			l_ok := l_ok and l_dot.has_substring ("color") and l_dot.has_substring ("shape")
			report ("attributes_to_dot", l_ok)
		rescue
			report ("attributes_to_dot", False)
		end

	test_dot_attributes_escape (t: TEST_DOT_GRAPH)
		local
			l_attrs: DOT_ATTRIBUTES
			l_ok: BOOLEAN
		do
			create l_attrs.make
			l_ok := l_attrs.escape_value ("hello").same_string ("hello")
			l_ok := l_ok and l_attrs.escape_value ("hello world").has_substring ("%"")
			report ("attributes_escape", l_ok)
		rescue
			report ("attributes_escape", False)
		end

	test_dot_node_creation (t: TEST_DOT_GRAPH)
		local
			l_node: DOT_NODE
		do
			create l_node.make ("my_node")
			report ("node_creation", l_node.id.same_string ("my_node") and l_node.attributes.is_empty)
		rescue
			report ("node_creation", False)
		end

	test_dot_node_fluent (t: TEST_DOT_GRAPH)
		local
			l_node, l_result: DOT_NODE
			l_ok: BOOLEAN
		do
			create l_node.make ("n1")
			l_result := l_node.set_label ("Node 1").set_shape ("ellipse").set_color ("blue")
			l_ok := l_node.attributes.has ("label") and l_node.attributes.has ("shape")
			l_ok := l_ok and l_node.attributes.has ("color") and l_result = l_node
			report ("node_fluent", l_ok)
		rescue
			report ("node_fluent", False)
		end

	test_dot_node_to_dot (t: TEST_DOT_GRAPH)
		local
			l_node, l_tmp: DOT_NODE
		do
			create l_node.make ("test")
			l_tmp := l_node.set_label ("Test Node")
			report ("node_to_dot", l_node.to_dot.has_substring ("test"))
		rescue
			report ("node_to_dot", False)
		end

	test_dot_edge_creation (t: TEST_DOT_GRAPH)
		local
			l_edge: DOT_EDGE
		do
			create l_edge.make ("a", "b")
			report ("edge_creation", l_edge.from_id.same_string ("a") and l_edge.to_id.same_string ("b"))
		rescue
			report ("edge_creation", False)
		end

	test_dot_edge_directed (t: TEST_DOT_GRAPH)
		local
			l_edge: DOT_EDGE
		do
			create l_edge.make ("x", "y")
			report ("edge_directed", l_edge.to_dot (True).has_substring ("->"))
		rescue
			report ("edge_directed", False)
		end

	test_dot_edge_undirected (t: TEST_DOT_GRAPH)
		local
			l_edge: DOT_EDGE
		do
			create l_edge.make ("x", "y")
			report ("edge_undirected", l_edge.to_dot (False).has_substring ("--"))
		rescue
			report ("edge_undirected", False)
		end

	test_dot_graph_digraph (t: TEST_DOT_GRAPH)
		local
			l_graph: DOT_GRAPH
			l_ok: BOOLEAN
		do
			create l_graph.make_digraph ("TestGraph")
			l_ok := l_graph.name.same_string ("TestGraph") and l_graph.is_directed and l_graph.is_empty
			report ("graph_digraph", l_ok)
		rescue
			report ("graph_digraph", False)
		end

	test_dot_graph_add_nodes (t: TEST_DOT_GRAPH)
		local
			l_graph: DOT_GRAPH
			l_ok: BOOLEAN
		do
			create l_graph.make_digraph ("G")
			l_graph.add_node (create {DOT_NODE}.make ("a"))
			l_graph.add_node (create {DOT_NODE}.make ("b"))
			l_ok := l_graph.has_node ("a") and l_graph.has_node ("b") and l_graph.node_count = 2
			report ("graph_add_nodes", l_ok)
		rescue
			report ("graph_add_nodes", False)
		end

	test_dot_graph_new_node (t: TEST_DOT_GRAPH)
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
		do
			create l_graph.make_digraph ("G")
			l_node := l_graph.new_node ("n1")
			report ("graph_new_node", l_node /= Void and l_graph.has_node ("n1"))
		rescue
			report ("graph_new_node", False)
		end

	test_dot_graph_to_dot (t: TEST_DOT_GRAPH)
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_graph.make_digraph ("Test")
			l_node := l_graph.new_node ("a")
			l_node := l_graph.new_node ("b")
			l_edge := l_graph.new_edge ("a", "b")
			l_dot := l_graph.to_dot
			l_ok := l_dot.has_substring ("digraph") and l_dot.has_substring ("Test") and l_dot.has_substring ("->")
			report ("graph_to_dot", l_ok)
		rescue
			report ("graph_to_dot", False)
		end

	test_dot_graph_undirected (t: TEST_DOT_GRAPH)
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_graph.make_graph ("Undirected")
			l_node := l_graph.new_node ("x")
			l_node := l_graph.new_node ("y")
			l_edge := l_graph.new_edge ("x", "y")
			l_dot := l_graph.to_dot
			l_ok := l_dot.has_substring ("graph") and not l_dot.has_substring ("digraph") and l_dot.has_substring ("--")
			report ("graph_undirected", l_ok)
		rescue
			report ("graph_undirected", False)
		end

	test_dot_subgraph_cluster (t: TEST_DOT_GRAPH)
		local
			l_sub: DOT_SUBGRAPH
			l_dot: STRING
		do
			create l_sub.make_cluster ("group1")
			l_dot := l_sub.to_dot (True, "")
			report ("subgraph_cluster", l_sub.is_cluster and l_dot.has_substring ("cluster_"))
		rescue
			report ("subgraph_cluster", False)
		end

feature {NONE} -- Builder Tests

	run_builder_tests
		local
			l_test: TEST_BUILDERS
		do
			print ("%N== Builder Tests ==%N")
			create l_test
			-- BON builder tests
			test_bon_creation
			test_bon_add_class
			test_bon_add_deferred
			test_bon_add_inheritance
			test_bon_to_dot
			-- Flowchart tests
			test_flowchart_creation
			test_flowchart_basic
			test_flowchart_decision
			-- State machine tests
			test_state_machine_creation
			test_state_machine_states
			test_state_machine_transitions
			-- Dependency tests
			test_dependency_creation
			test_dependency_add_libraries
			-- Inheritance tests
			test_inheritance_creation
			test_inheritance_add_classes
			test_inheritance_root_filter
		end

	test_bon_creation
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
			l_ok: BOOLEAN
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_ok := l_builder.style.name.same_string ("bon") and not l_builder.include_features
			report ("bon_creation", l_ok)
		rescue
			report ("bon_creation", False)
		end

	test_bon_add_class
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("MY_CLASS", False, False)
			report ("bon_add_class", l_builder.graph.has_node ("MY_CLASS"))
		rescue
			report ("bon_add_class", False)
		end

	test_bon_add_deferred
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("DEFERRED_CLASS", True, False)
			report ("bon_add_deferred", l_builder.graph.has_node ("DEFERRED_CLASS"))
		rescue
			report ("bon_add_deferred", False)
		end

	test_bon_add_inheritance
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("PARENT", False, False)
			l_builder.add_class ("CHILD", False, False)
			l_builder.add_inheritance ("CHILD", "PARENT")
			report ("bon_add_inheritance", l_builder.graph.edge_count = 1)
		rescue
			report ("bon_add_inheritance", False)
		end

	test_bon_to_dot
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("TEST", False, False)
			l_dot := l_builder.to_dot
			report ("bon_to_dot", l_dot.has_substring ("digraph") and l_dot.has_substring ("TEST"))
		rescue
			report ("bon_to_dot", False)
		end

	test_flowchart_creation
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			report ("flowchart_creation", l_builder.graph /= Void)
		rescue
			report ("flowchart_creation", False)
		end

	test_flowchart_basic
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.start ("Begin").process ("Step 1").end_node ("Done")
			l_dot := l_builder.to_dot
			l_ok := l_dot.has_substring ("Begin") and l_dot.has_substring ("Step 1") and l_dot.has_substring ("Done")
			report ("flowchart_basic", l_ok)
		rescue
			report ("flowchart_basic", False)
		end

	test_flowchart_decision
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.start ("Start").decision ("Is Valid?", "Yes", "No")
			l_dot := l_builder.to_dot
			report ("flowchart_decision", l_dot.has_substring ("Is Valid?") and l_dot.has_substring ("diamond"))
		rescue
			report ("flowchart_decision", False)
		end

	test_state_machine_creation
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			report ("state_machine_creation", l_builder.graph /= Void)
		rescue
			report ("state_machine_creation", False)
		end

	test_state_machine_states
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
			l_ok: BOOLEAN
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.initial ("Idle").state ("Running").state ("Stopped")
			l_ok := l_builder.has_state ("Idle") and l_builder.has_state ("Running") and l_builder.has_state ("Stopped")
			report ("state_machine_states", l_ok)
		rescue
			report ("state_machine_states", False)
		end

	test_state_machine_transitions
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.initial ("Idle").transition ("Idle", "Running", "start").transition ("Running", "Idle", "stop")
			l_dot := l_builder.to_dot
			report ("state_machine_transitions", l_dot.has_substring ("start") and l_dot.has_substring ("stop"))
		rescue
			report ("state_machine_transitions", False)
		end

	test_dependency_creation
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: DEPENDENCY_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			report ("dependency_creation", l_builder.show_external)
		rescue
			report ("dependency_creation", False)
		end

	test_dependency_add_libraries
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: DEPENDENCY_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_library ("my_lib", False)
			l_builder.add_library ("external_lib", True)
			report ("dependency_add_libraries", l_builder.graph.has_node ("my_lib") and l_builder.graph.has_node ("external_lib"))
		rescue
			report ("dependency_add_libraries", False)
		end

	test_inheritance_creation
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: INHERITANCE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			report ("inheritance_creation", l_builder.root_class_name = Void)
		rescue
			report ("inheritance_creation", False)
		end

	test_inheritance_add_classes
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: INHERITANCE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("PARENT")
			l_builder.add_inheritance ("CHILD", "PARENT")
			report ("inheritance_add_classes", l_builder.graph.has_node ("PARENT") and l_builder.graph.has_node ("CHILD"))
		rescue
			report ("inheritance_add_classes", False)
		end

	test_inheritance_root_filter
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: INHERITANCE_BUILDER
			l_ok: BOOLEAN
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.root_class ("ANY")
			l_ok := attached l_builder.root_class_name as r and then r.same_string ("ANY")
			report ("inheritance_root_filter", l_ok)
		rescue
			report ("inheritance_root_filter", False)
		end

feature {NONE} -- Facade Tests

	run_facade_tests
		local
			l_test: TEST_SIMPLE_GRAPHVIZ
		do
			print ("%N== Facade Tests ==%N")
			create l_test
			test_facade_creation
			test_facade_builder_access
			test_facade_graph_access
			test_facade_undirected_graph
			test_facade_engine_setting
			test_facade_timeout_setting
			test_facade_bon_workflow
			test_facade_state_machine_workflow
			test_facade_flowchart_workflow
		end

	test_facade_creation
		local
			l_gv: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			report ("facade_creation", l_gv.renderer /= Void)
		rescue
			report ("facade_creation", False)
		end

	test_facade_builder_access
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_ok: BOOLEAN
		do
			create l_gv.make
			l_ok := l_gv.bon_diagram /= Void and l_gv.flowchart /= Void
			l_ok := l_ok and l_gv.state_machine /= Void and l_gv.dependency_graph /= Void
			l_ok := l_ok and l_gv.inheritance_tree /= Void
			report ("facade_builder_access", l_ok)
		rescue
			report ("facade_builder_access", False)
		end

	test_facade_graph_access
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_graph: DOT_GRAPH
		do
			create l_gv.make
			l_graph := l_gv.graph
			report ("facade_graph_access", l_graph /= Void and l_graph.is_directed)
		rescue
			report ("facade_graph_access", False)
		end

	test_facade_undirected_graph
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_graph: DOT_GRAPH
		do
			create l_gv.make
			l_graph := l_gv.undirected_graph
			report ("facade_undirected_graph", l_graph /= Void and not l_graph.is_directed)
		rescue
			report ("facade_undirected_graph", False)
		end

	test_facade_engine_setting
		local
			l_gv, l_result: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			l_result := l_gv.set_engine ("neato")
			report ("facade_engine_setting", l_gv.renderer.engine.same_string ("neato") and l_result = l_gv)
		rescue
			report ("facade_engine_setting", False)
		end

	test_facade_timeout_setting
		local
			l_gv, l_result: SIMPLE_GRAPHVIZ
		do
			create l_gv.make
			l_result := l_gv.set_timeout (60_000)
			report ("facade_timeout_setting", l_gv.renderer.timeout_ms = 60_000 and l_result = l_gv)
		rescue
			report ("facade_timeout_setting", False)
		end

	test_facade_bon_workflow
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_builder: BON_DIAGRAM_BUILDER
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_gv.make
			l_builder := l_gv.bon_diagram
			l_builder.add_class ("ANIMAL", True, False)
			l_builder.add_class ("DOG", False, False)
			l_builder.add_inheritance ("DOG", "ANIMAL")
			l_dot := l_builder.to_dot
			l_ok := l_dot.has_substring ("digraph") and l_dot.has_substring ("ANIMAL") and l_dot.has_substring ("DOG")
			report ("facade_bon_workflow", l_ok)
		rescue
			report ("facade_bon_workflow", False)
		end

	test_facade_state_machine_workflow
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_builder: STATE_MACHINE_BUILDER
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_gv.make
			l_builder := l_gv.state_machine
			l_builder := l_builder.initial ("Idle").state ("Running").transition ("Idle", "Running", "start")
			l_dot := l_builder.to_dot
			l_ok := l_dot.has_substring ("Idle") and l_dot.has_substring ("Running") and l_dot.has_substring ("start")
			report ("facade_state_machine_workflow", l_ok)
		rescue
			report ("facade_state_machine_workflow", False)
		end

	test_facade_flowchart_workflow
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_gv.make
			l_builder := l_gv.flowchart
			l_builder := l_builder.start ("Begin").process ("Process").decision ("Valid?", "Yes", "No")
			l_dot := l_builder.to_dot
			l_ok := l_dot.has_substring ("Begin") and l_dot.has_substring ("Process") and l_dot.has_substring ("Valid")
			report ("facade_flowchart_workflow", l_ok)
		rescue
			report ("facade_flowchart_workflow", False)
		end

feature {NONE} -- SCOOP Tests

	run_scoop_tests
		local
			l_test: TEST_SCOOP_CONSUMER
		do
			print ("%N== SCOOP Tests ==%N")
			create l_test
			test_scoop_compatibility
		end

	test_scoop_compatibility
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

			l_graph.add_node (l_node)
			l_graph.add_edge (l_edge)
			l_attrs.put ("test", "value")

			report ("scoop_compatibility", True)
		rescue
			report ("scoop_compatibility", False)
		end

feature {NONE} -- Renderer Tests

	run_renderer_tests
		do
			print ("%N== Renderer Tests ==%N")
			test_renderer_creation
			test_renderer_engine_setting
			test_renderer_timeout_setting
			test_renderer_version_parsing
			test_renderer_result_success
			test_renderer_result_failure
			test_renderer_error_types
			-- GraphViz-dependent tests (only run if available)
			test_renderer_graphviz_available
		end

	test_renderer_creation
		local
			l_renderer: GRAPHVIZ_RENDERER
		do
			create l_renderer.make
			report ("renderer_creation", l_renderer.engine.same_string ("neato") and l_renderer.timeout_ms = 30_000)
		rescue
			report ("renderer_creation", False)
		end

	test_renderer_engine_setting
		local
			l_renderer, l_result: GRAPHVIZ_RENDERER
		do
			create l_renderer.make
			l_result := l_renderer.set_engine ("neato")
			report ("renderer_engine_setting", l_renderer.engine.same_string ("neato") and l_result = l_renderer)
		rescue
			report ("renderer_engine_setting", False)
		end

	test_renderer_timeout_setting
		local
			l_renderer, l_result: GRAPHVIZ_RENDERER
		do
			create l_renderer.make
			l_result := l_renderer.set_timeout (60_000)
			report ("renderer_timeout_setting", l_renderer.timeout_ms = 60_000 and l_result = l_renderer)
		rescue
			report ("renderer_timeout_setting", False)
		end

	test_renderer_version_parsing
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_ok: BOOLEAN
		do
			create l_renderer.make
			-- Test version comparison
			l_ok := l_renderer.is_version_sufficient_check (3, 0, 2, 40)   -- 3.0 >= 2.40
			l_ok := l_ok and l_renderer.is_version_sufficient_check (2, 40, 2, 40)   -- 2.40 >= 2.40
			l_ok := l_ok and not l_renderer.is_version_sufficient_check (2, 30, 2, 40)   -- 2.30 < 2.40
			l_ok := l_ok and l_renderer.is_version_sufficient_check (2, 50, 2, 40)   -- 2.50 >= 2.40
			report ("renderer_version_parsing", l_ok)
		rescue
			report ("renderer_version_parsing", False)
		end

	test_renderer_result_success
		local
			l_result: GRAPHVIZ_RESULT
			l_ok: BOOLEAN
		do
			create l_result.make_success ("<svg>test</svg>")
			l_ok := l_result.is_success and l_result.error = Void
			l_ok := l_ok and attached l_result.content as c and then c.same_string ("<svg>test</svg>")
			report ("renderer_result_success", l_ok)
		rescue
			report ("renderer_result_success", False)
		end

	test_renderer_result_failure
		local
			l_result: GRAPHVIZ_RESULT
			l_error: GRAPHVIZ_ERROR
			l_ok: BOOLEAN
		do
			create l_error.make ({GRAPHVIZ_ERROR}.Invalid_dot, "Syntax error")
			create l_result.make_failure (l_error)
			l_ok := not l_result.is_success and l_result.content = Void
			l_ok := l_ok and attached l_result.error as e and then e.code = {GRAPHVIZ_ERROR}.Invalid_dot
			report ("renderer_result_failure", l_ok)
		rescue
			report ("renderer_result_failure", False)
		end

	test_renderer_error_types
		local
			l_error: GRAPHVIZ_ERROR
			l_ok: BOOLEAN
		do
			-- Test all error types
			create l_error.make ({GRAPHVIZ_ERROR}.Graphviz_not_found, "not found")
			l_ok := l_error.code = {GRAPHVIZ_ERROR}.Graphviz_not_found

			create l_error.make ({GRAPHVIZ_ERROR}.Timeout, "timeout")
			l_ok := l_ok and l_error.code = {GRAPHVIZ_ERROR}.Timeout

			create l_error.make ({GRAPHVIZ_ERROR}.Invalid_dot, "invalid")
			l_ok := l_ok and l_error.code = {GRAPHVIZ_ERROR}.Invalid_dot

			create l_error.make ({GRAPHVIZ_ERROR}.Output_error, "output")
			l_ok := l_ok and l_error.code = {GRAPHVIZ_ERROR}.Output_error

			report ("renderer_error_types", l_ok)
		rescue
			report ("renderer_error_types", False)
		end

	test_renderer_graphviz_available
		local
			l_renderer: GRAPHVIZ_RENDERER
		do
			create l_renderer.make
			if l_renderer.is_graphviz_available then
				if attached l_renderer.graphviz_version as v then
					print ("    (GraphViz found: " + v + ")%N")
				else
					print ("    (GraphViz found but version unknown)%N")
				end
				report ("renderer_graphviz_available", l_renderer.is_version_sufficient)
			else
				print ("    (GraphViz not installed - skipping render tests)%N")
				report ("renderer_graphviz_available [SKIPPED]", True)
			end
		rescue
			report ("renderer_graphviz_available", False)
		end

feature {NONE} -- Adversarial Tests

	run_adversarial_tests
		local
			l_test: TEST_ADVERSARIAL
		do
			print ("%N== Adversarial Tests ==%N")
			create l_test
			-- Special characters
			test_adv_special_chars_in_label
			test_adv_quotes_in_label
			test_adv_backslash_in_label
			test_adv_unicode_in_label
			-- Boundary values
			test_adv_very_long_node_id
			test_adv_very_long_label
			-- Empty inputs
			test_adv_empty_attributes
			test_adv_empty_graph
			-- Stress tests
			test_adv_stress_many_nodes
			test_adv_stress_many_edges
			test_adv_stress_many_attributes
			test_adv_stress_deep_subgraphs
			-- Attribute operations
			test_adv_attribute_overwrite
			test_adv_attribute_remove_readd
			-- Renderer edge cases
			test_adv_renderer_not_found
			test_adv_result_invariant_success
			test_adv_result_invariant_failure
			-- Builder state
			test_adv_bon_builder_reuse
			test_adv_state_machine_implicit
			test_adv_flowchart_auto_link
			-- Error types
			test_adv_all_error_codes
		end

	test_adv_special_chars_in_label
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Line1%NLine2")
			l_dot := l_node.to_dot
			report ("adv_special_chars_in_label", l_dot.has_substring ("\n"))
		rescue
			report ("adv_special_chars_in_label", False)
		end

	test_adv_quotes_in_label
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Say %"Hello%"")
			l_dot := l_node.to_dot
			report ("adv_quotes_in_label", l_dot.has_substring ("\%""))
		rescue
			report ("adv_quotes_in_label", False)
		end

	test_adv_backslash_in_label
		local
			l_node: DOT_NODE
			l_dot: STRING
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Path: C:\temp")
			l_dot := l_node.to_dot
			report ("adv_backslash_in_label", l_dot.has_substring ("\\"))
		rescue
			report ("adv_backslash_in_label", False)
		end

	test_adv_unicode_in_label
		local
			l_node: DOT_NODE
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_node.make ("test")
			l_node.attributes.put ("label", "Café résumé")
			l_dot := l_node.to_dot
			l_ok := not l_dot.is_empty and l_dot.has_substring ("label")
			report ("adv_unicode_in_label", l_ok)
		rescue
			report ("adv_unicode_in_label", False)
		end

	test_adv_very_long_node_id
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
			report ("adv_very_long_node_id", l_dot.has_substring (l_long_id))
		rescue
			report ("adv_very_long_node_id", False)
		end

	test_adv_very_long_label
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
			report ("adv_very_long_label", l_dot.count > 5000)
		rescue
			report ("adv_very_long_label", False)
		end

	test_adv_empty_attributes
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			report ("adv_empty_attributes", l_attrs.to_dot.is_empty)
		rescue
			report ("adv_empty_attributes", False)
		end

	test_adv_empty_graph
		local
			l_graph: DOT_GRAPH
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_graph.make_digraph ("Empty")
			l_dot := l_graph.to_dot
			l_ok := l_dot.has_substring ("digraph") and l_dot.has_substring ("Empty")
			l_ok := l_ok and l_dot.has_substring ("{") and l_dot.has_substring ("}")
			report ("adv_empty_graph", l_ok)
		rescue
			report ("adv_empty_graph", False)
		end

	test_adv_stress_many_nodes
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
			report ("adv_stress_many_nodes", l_graph.node_count = 500 and l_graph.to_dot.count > 1000)
		rescue
			report ("adv_stress_many_nodes", False)
		end

	test_adv_stress_many_edges
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			i, j: INTEGER
		do
			create l_graph.make_digraph ("EdgeStress")
			from i := 1 until i > 10 loop
				l_node := l_graph.new_node ("n" + i.out)
				i := i + 1
			end
			from i := 1 until i > 10 loop
				from j := 1 until j > 10 loop
					if i /= j then
						l_edge := l_graph.new_edge ("n" + i.out, "n" + j.out)
					end
					j := j + 1
				end
				i := i + 1
			end
			report ("adv_stress_many_edges", l_graph.edge_count = 90)
		rescue
			report ("adv_stress_many_edges", False)
		end

	test_adv_stress_many_attributes
		local
			l_attrs: DOT_ATTRIBUTES
			i: INTEGER
		do
			create l_attrs.make
			from i := 1 until i > 100 loop
				l_attrs.put ("attr_" + i.out, "value_" + i.out)
				i := i + 1
			end
			report ("adv_stress_many_attributes", l_attrs.count = 100 and l_attrs.to_dot.count > 500)
		rescue
			report ("adv_stress_many_attributes", False)
		end

	test_adv_stress_deep_subgraphs
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
			report ("adv_stress_deep_subgraphs", l_graph.subgraph_count = 20 and l_graph.to_dot.count > 100)
		rescue
			report ("adv_stress_deep_subgraphs", False)
		end

	test_adv_attribute_overwrite
		local
			l_attrs: DOT_ATTRIBUTES
			l_ok: BOOLEAN
		do
			create l_attrs.make
			l_attrs.put ("color", "red")
			l_attrs.put ("color", "blue")
			l_ok := l_attrs.count = 1 and attached l_attrs ["color"] as v and then v.same_string ("blue")
			report ("adv_attribute_overwrite", l_ok)
		rescue
			report ("adv_attribute_overwrite", False)
		end

	test_adv_attribute_remove_readd
		local
			l_attrs: DOT_ATTRIBUTES
			l_ok: BOOLEAN
		do
			create l_attrs.make
			l_attrs.put ("key", "value1")
			l_attrs.remove ("key")
			l_attrs.put ("key", "value2")
			l_ok := l_attrs.has ("key") and attached l_attrs ["key"] as v and then v.same_string ("value2")
			report ("adv_attribute_remove_readd", l_ok)
		rescue
			report ("adv_attribute_remove_readd", False)
		end

	test_adv_renderer_not_found
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
			l_ok: BOOLEAN
		do
			create l_renderer.make
			l_result := l_renderer.render_svg ("digraph { a -> b }")
			l_ok := l_result /= Void
			if not l_renderer.is_graphviz_available then
				l_ok := l_ok and not l_result.is_success and l_result.error /= Void
				l_ok := l_ok and attached l_result.error as e and then e.code = {GRAPHVIZ_ERROR}.Graphviz_not_found
			end
			report ("adv_renderer_not_found", l_ok)
		rescue
			report ("adv_renderer_not_found", False)
		end

	test_adv_result_invariant_success
		local
			l_result: GRAPHVIZ_RESULT
			l_ok: BOOLEAN
		do
			create l_result.make_success ("content")
			l_ok := l_result.is_success and l_result.error = Void and l_result.content /= Void
			report ("adv_result_invariant_success", l_ok)
		rescue
			report ("adv_result_invariant_success", False)
		end

	test_adv_result_invariant_failure
		local
			l_result: GRAPHVIZ_RESULT
			l_error: GRAPHVIZ_ERROR
			l_ok: BOOLEAN
		do
			create l_error.make ({GRAPHVIZ_ERROR}.Invalid_dot, "test error")
			create l_result.make_failure (l_error)
			l_ok := not l_result.is_success and l_result.error /= Void and l_result.content = Void
			report ("adv_result_invariant_failure", l_ok)
		rescue
			report ("adv_result_invariant_failure", False)
		end

	test_adv_bon_builder_reuse
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
			l_dot1, l_dot2: STRING
			l_ok: BOOLEAN
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("CLASS_A", False, False)
			l_dot1 := l_builder.to_dot
			l_builder.add_class ("CLASS_B", False, False)
			l_dot2 := l_builder.to_dot
			l_ok := l_dot1.has_substring ("CLASS_A") and l_dot2.has_substring ("CLASS_A")
			l_ok := l_ok and l_dot2.has_substring ("CLASS_B") and l_dot2.count > l_dot1.count
			report ("adv_bon_builder_reuse", l_ok)
		rescue
			report ("adv_bon_builder_reuse", False)
		end

	test_adv_state_machine_implicit
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.transition ("A", "B", "go")
			report ("adv_state_machine_implicit", l_builder.has_state ("A") and l_builder.has_state ("B"))
		rescue
			report ("adv_state_machine_implicit", False)
		end

	test_adv_flowchart_auto_link
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
			l_ok: BOOLEAN
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.start ("Begin").process ("Step1").process ("Step2").end_node ("Done")
			l_dot := l_builder.to_dot
			l_ok := l_builder.graph.edge_count >= 3 and l_dot.has_substring ("->")
			report ("adv_flowchart_auto_link", l_ok)
		rescue
			report ("adv_flowchart_auto_link", False)
		end

	test_adv_all_error_codes
		local
			l_ok: BOOLEAN
		do
			l_ok := {GRAPHVIZ_ERROR}.Graphviz_not_found /= {GRAPHVIZ_ERROR}.Timeout
			l_ok := l_ok and {GRAPHVIZ_ERROR}.Invalid_dot /= {GRAPHVIZ_ERROR}.Output_error
			l_ok := l_ok and {GRAPHVIZ_ERROR}.Unknown_error /= {GRAPHVIZ_ERROR}.Graphviz_not_found
			report ("adv_all_error_codes", l_ok)
		rescue
			report ("adv_all_error_codes", False)
		end

end
