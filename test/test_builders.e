note
	description: "Tests for diagram builder classes"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_BUILDERS

inherit
	EQA_TEST_SET

feature -- Test: BON_DIAGRAM_BUILDER

	test_bon_builder_creation
			-- Test BON builder creation.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			assert ("style is bon", l_builder.style.name.same_string ("bon"))
			assert ("not include features", not l_builder.include_features)
		end

	test_bon_add_class
			-- Test adding a class.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("MY_CLASS", False, False)
			assert ("class added", l_builder.graph.has_node ("MY_CLASS"))
		end

	test_bon_add_deferred_class
			-- Test adding a deferred class.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("DEFERRED_CLASS", True, False)
			assert ("class added", l_builder.graph.has_node ("DEFERRED_CLASS"))
		end

	test_bon_add_inheritance
			-- Test adding inheritance relationship.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("PARENT", False, False)
			l_builder.add_class ("CHILD", False, False)
			l_builder.add_inheritance ("CHILD", "PARENT")
			assert ("has edge", l_builder.graph.edge_count = 1)
		end

	test_bon_to_dot
			-- Test DOT generation.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: BON_DIAGRAM_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("TEST", False, False)
			l_dot := l_builder.to_dot
			assert ("has digraph", l_dot.has_substring ("digraph"))
			assert ("has class", l_dot.has_substring ("TEST"))
		end

feature -- Test: FLOWCHART_BUILDER

	test_flowchart_creation
			-- Test flowchart builder creation.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			assert ("graph exists", l_builder.graph /= Void)
		end

	test_flowchart_basic_flow
			-- Test basic flowchart construction.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.start ("Begin").process ("Step 1").end_node ("Done")
			l_dot := l_builder.to_dot
			assert ("has begin", l_dot.has_substring ("Begin"))
			assert ("has step", l_dot.has_substring ("Step 1"))
			assert ("has done", l_dot.has_substring ("Done"))
		end

	test_flowchart_decision
			-- Test decision node.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: FLOWCHART_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.start ("Start").decision ("Is Valid?", "Yes", "No")
			l_dot := l_builder.to_dot
			assert ("has decision", l_dot.has_substring ("Is Valid?"))
			assert ("has diamond", l_dot.has_substring ("diamond"))
		end

feature -- Test: STATE_MACHINE_BUILDER

	test_state_machine_creation
			-- Test state machine builder creation.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			assert ("graph exists", l_builder.graph /= Void)
		end

	test_state_machine_states
			-- Test adding states.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.initial ("Idle").state ("Running").state ("Stopped")
			assert ("has idle", l_builder.has_state ("Idle"))
			assert ("has running", l_builder.has_state ("Running"))
			assert ("has stopped", l_builder.has_state ("Stopped"))
		end

	test_state_machine_transitions
			-- Test adding transitions.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: STATE_MACHINE_BUILDER
			l_dot: STRING
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.initial ("Idle").transition ("Idle", "Running", "start").transition ("Running", "Idle", "stop")
			l_dot := l_builder.to_dot
			assert ("has start label", l_dot.has_substring ("start"))
			assert ("has stop label", l_dot.has_substring ("stop"))
		end

feature -- Test: DEPENDENCY_BUILDER

	test_dependency_creation
			-- Test dependency builder creation.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: DEPENDENCY_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			assert ("show external default", l_builder.show_external)
		end

	test_dependency_add_libraries
			-- Test adding libraries.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: DEPENDENCY_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_library ("my_lib", False)
			l_builder.add_library ("external_lib", True)
			assert ("has my_lib", l_builder.graph.has_node ("my_lib"))
			assert ("has external_lib", l_builder.graph.has_node ("external_lib"))
		end

feature -- Test: INHERITANCE_BUILDER

	test_inheritance_creation
			-- Test inheritance builder creation.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: INHERITANCE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			assert ("no root class", l_builder.root_class_name = Void)
		end

	test_inheritance_add_classes
			-- Test adding classes.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: INHERITANCE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder.add_class ("PARENT")
			l_builder.add_inheritance ("CHILD", "PARENT")
			assert ("has parent", l_builder.graph.has_node ("PARENT"))
			assert ("has child", l_builder.graph.has_node ("CHILD"))
		end

	test_inheritance_root_filter
			-- Test root class setting.
		local
			l_renderer: GRAPHVIZ_RENDERER
			l_builder: INHERITANCE_BUILDER
		do
			create l_renderer.make
			create l_builder.make (l_renderer)
			l_builder := l_builder.root_class ("ANY")
			assert ("root set", attached l_builder.root_class_name as r and then r.same_string ("ANY"))
		end

end
