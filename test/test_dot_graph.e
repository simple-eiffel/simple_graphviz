note
	description: "Tests for DOT graph structure classes"
	author: "Larry Rix"
	date: "2026-01-22"

class
	TEST_DOT_GRAPH

inherit
	EQA_TEST_SET

feature -- Test: DOT_ATTRIBUTES

	test_attributes_empty
			-- Test empty attributes.
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			assert ("is empty", l_attrs.is_empty)
			assert ("count zero", l_attrs.count = 0)
			assert ("to_dot empty", l_attrs.to_dot.is_empty)
		end

	test_attributes_put_and_get
			-- Test adding and retrieving attributes.
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			l_attrs.put ("color", "red")
			assert ("has color", l_attrs.has ("color"))
			assert ("color value", attached l_attrs ["color"] as v and then v.same_string ("red"))
			assert ("count one", l_attrs.count = 1)
		end

	test_attributes_to_dot
			-- Test DOT serialization of attributes.
		local
			l_attrs: DOT_ATTRIBUTES
			l_dot: STRING
		do
			create l_attrs.make
			l_attrs.put ("color", "blue")
			l_attrs.put ("shape", "box")
			l_dot := l_attrs.to_dot
			assert ("has brackets", l_dot.starts_with ("[") and l_dot.ends_with ("]"))
			assert ("has color", l_dot.has_substring ("color"))
			assert ("has shape", l_dot.has_substring ("shape"))
		end

	test_attributes_escape_value
			-- Test value escaping.
		local
			l_attrs: DOT_ATTRIBUTES
		do
			create l_attrs.make
			assert ("simple unchanged", l_attrs.escape_value ("hello").same_string ("hello"))
			assert ("spaces quoted", l_attrs.escape_value ("hello world").has_substring ("%""))
			assert ("quotes escaped", l_attrs.escape_value ("say %"hi%"").has_substring ("\%""))
		end

feature -- Test: DOT_NODE

	test_node_creation
			-- Test node creation.
		local
			l_node: DOT_NODE
		do
			create l_node.make ("my_node")
			assert ("id set", l_node.id.same_string ("my_node"))
			assert ("no attributes", l_node.attributes.is_empty)
		end

	test_node_fluent_api
			-- Test fluent attribute setting.
		local
			l_node, l_result: DOT_NODE
		do
			create l_node.make ("n1")
			l_result := l_node.set_label ("Node 1").set_shape ("ellipse").set_color ("blue")
			assert ("has label", l_node.attributes.has ("label"))
			assert ("has shape", l_node.attributes.has ("shape"))
			assert ("has color", l_node.attributes.has ("color"))
			assert ("result is current", l_result = l_node)
		end

	test_node_to_dot
			-- Test DOT serialization.
		local
			l_node, l_tmp: DOT_NODE
		do
			create l_node.make ("test")
			l_tmp := l_node.set_label ("Test Node")
			assert ("has id", l_node.to_dot.has_substring ("test"))
		end

feature -- Test: DOT_EDGE

	test_edge_creation
			-- Test edge creation.
		local
			l_edge: DOT_EDGE
		do
			create l_edge.make ("a", "b")
			assert ("from set", l_edge.from_id.same_string ("a"))
			assert ("to set", l_edge.to_id.same_string ("b"))
		end

	test_edge_to_dot_directed
			-- Test directed edge serialization.
		local
			l_edge: DOT_EDGE
		do
			create l_edge.make ("x", "y")
			assert ("has arrow", l_edge.to_dot (True).has_substring ("->"))
		end

	test_edge_to_dot_undirected
			-- Test undirected edge serialization.
		local
			l_edge: DOT_EDGE
		do
			create l_edge.make ("x", "y")
			assert ("has dash", l_edge.to_dot (False).has_substring ("--"))
		end

feature -- Test: DOT_GRAPH

	test_graph_digraph
			-- Test directed graph creation.
		local
			l_graph: DOT_GRAPH
		do
			create l_graph.make_digraph ("TestGraph")
			assert ("name set", l_graph.name.same_string ("TestGraph"))
			assert ("is directed", l_graph.is_directed)
			assert ("is empty", l_graph.is_empty)
		end

	test_graph_add_nodes
			-- Test adding nodes.
		local
			l_graph: DOT_GRAPH
		do
			create l_graph.make_digraph ("G")
			l_graph.add_node (create {DOT_NODE}.make ("a"))
			l_graph.add_node (create {DOT_NODE}.make ("b"))
			assert ("has a", l_graph.has_node ("a"))
			assert ("has b", l_graph.has_node ("b"))
			assert ("count 2", l_graph.node_count = 2)
		end

	test_graph_new_node
			-- Test new_node helper.
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
		do
			create l_graph.make_digraph ("G")
			l_node := l_graph.new_node ("n1")
			assert ("node returned", l_node /= Void)
			assert ("has node", l_graph.has_node ("n1"))
		end

	test_graph_to_dot
			-- Test DOT serialization.
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			l_dot: STRING
		do
			create l_graph.make_digraph ("Test")
			l_node := l_graph.new_node ("a")
			l_node := l_graph.new_node ("b")
			l_edge := l_graph.new_edge ("a", "b")
			l_dot := l_graph.to_dot
			assert ("has digraph", l_dot.has_substring ("digraph"))
			assert ("has name", l_dot.has_substring ("Test"))
			assert ("has arrow", l_dot.has_substring ("->"))
		end

	test_graph_undirected
			-- Test undirected graph.
		local
			l_graph: DOT_GRAPH
			l_node: DOT_NODE
			l_edge: DOT_EDGE
			l_dot: STRING
		do
			create l_graph.make_graph ("Undirected")
			l_node := l_graph.new_node ("x")
			l_node := l_graph.new_node ("y")
			l_edge := l_graph.new_edge ("x", "y")
			l_dot := l_graph.to_dot
			assert ("has graph keyword", l_dot.has_substring ("graph"))
			assert ("not digraph", not l_dot.has_substring ("digraph"))
			assert ("has dash connector", l_dot.has_substring ("--"))
		end

feature -- Test: DOT_SUBGRAPH

	test_subgraph_cluster
			-- Test cluster subgraph.
		local
			l_sub: DOT_SUBGRAPH
			l_dot: STRING
		do
			create l_sub.make_cluster ("group1")
			assert ("is cluster", l_sub.is_cluster)
			l_dot := l_sub.to_dot (True, "")
			assert ("has cluster prefix", l_dot.has_substring ("cluster_"))
		end

end
