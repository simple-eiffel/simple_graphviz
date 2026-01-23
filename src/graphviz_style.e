note
	description: "Visual style presets for different diagram types (BON, UML, minimal, etc.)"
	author: "Larry Rix"
	date: "2026-01-22"

class
	GRAPHVIZ_STYLE

create
	make_bon, make_uml, make_minimal, make_default

feature {NONE} -- Initialization

	make_bon
			-- Create BON (Business Object Notation) style per OOSC2.
			-- Classes: ellipse, deferred: dashed, expanded: gray fill.
		do
			name := "bon"
			class_shape := "ellipse"
			class_style := "filled"
			class_fillcolor := "white"
			deferred_style := "dashed"
			expanded_fillcolor := "gray90"
			inheritance_arrowhead := "empty"
			client_arrowhead := "vee"
			fontname := "Helvetica"
			fontsize := 12
		ensure
			name_set: name.same_string ("bon")
			class_shape_ellipse: class_shape.same_string ("ellipse")
		end

	make_uml
			-- Create UML-style class diagram style.
			-- Classes: rectangle with compartments.
		do
			name := "uml"
			class_shape := "record"
			class_style := "filled"
			class_fillcolor := "lightyellow"
			deferred_style := "dashed"
			expanded_fillcolor := "lightgray"
			inheritance_arrowhead := "empty"
			client_arrowhead := "vee"
			fontname := "Courier"
			fontsize := 10
		ensure
			name_set: name.same_string ("uml")
			class_shape_record: class_shape.same_string ("record")
		end

	make_minimal
			-- Create minimal style with basic shapes.
		do
			name := "minimal"
			class_shape := "box"
			class_style := ""
			class_fillcolor := ""
			deferred_style := "dashed"
			expanded_fillcolor := ""
			inheritance_arrowhead := "normal"
			client_arrowhead := "normal"
			fontname := "sans-serif"
			fontsize := 11
		ensure
			name_set: name.same_string ("minimal")
		end

	make_default
			-- Create default style.
		do
			make_minimal
			name := "default"
		ensure
			name_set: name.same_string ("default")
		end

feature -- Access

	name: STRING
			-- Style name.

	class_shape: STRING
			-- Shape for class nodes.

	class_style: STRING
			-- Style for class nodes (filled, etc.).

	class_fillcolor: STRING
			-- Default fill color for classes.

	deferred_style: STRING
			-- Style for deferred (abstract) classes.

	expanded_fillcolor: STRING
			-- Fill color for expanded classes.

	inheritance_arrowhead: STRING
			-- Arrow style for inheritance edges.

	client_arrowhead: STRING
			-- Arrow style for client-supplier edges.

	fontname: STRING
			-- Default font name.

	fontsize: INTEGER
			-- Default font size in points.

feature -- Application

	apply_to_class_node (a_node: DOT_NODE; a_is_deferred, a_is_expanded: BOOLEAN)
			-- Apply style to a class node.
		require
			node_not_void: a_node /= Void
		do
			a_node.set_shape (class_shape).do_nothing
			if not class_style.is_empty then
				a_node.set_style (class_style).do_nothing
			end
			if a_is_deferred then
				a_node.set_style (deferred_style).do_nothing
			elseif a_is_expanded and not expanded_fillcolor.is_empty then
				a_node.set_fillcolor (expanded_fillcolor).do_nothing
				if class_style.is_empty or not class_style.has_substring ("filled") then
					a_node.set_style ("filled").do_nothing
				end
			elseif not class_fillcolor.is_empty then
				a_node.set_fillcolor (class_fillcolor).do_nothing
			end
			a_node.set_fontname (fontname).do_nothing
			a_node.set_fontsize (fontsize).do_nothing
		end

	apply_to_inheritance_edge (a_edge: DOT_EDGE)
			-- Apply style to an inheritance edge (child -> parent).
		require
			edge_not_void: a_edge /= Void
		do
			a_edge.set_arrowhead (inheritance_arrowhead).do_nothing
		end

	apply_to_client_edge (a_edge: DOT_EDGE)
			-- Apply style to a client-supplier edge.
		require
			edge_not_void: a_edge /= Void
		do
			a_edge.set_arrowhead (client_arrowhead).do_nothing
		end

	apply_defaults_to_graph (a_graph: DOT_GRAPH)
			-- Apply default font settings to graph.
		require
			graph_not_void: a_graph /= Void
		do
			a_graph.attributes.put ("fontname", fontname)
			a_graph.attributes.put ("fontsize", fontsize.out)
			-- Node defaults
			a_graph.attributes.put ("node", "[fontname=" + fontname + ", fontsize=" + fontsize.out + "]")
		end

invariant
	name_not_void: name /= Void
	class_shape_not_void: class_shape /= Void
	class_style_not_void: class_style /= Void
	class_fillcolor_not_void: class_fillcolor /= Void
	deferred_style_not_void: deferred_style /= Void
	expanded_fillcolor_not_void: expanded_fillcolor /= Void
	inheritance_arrowhead_not_void: inheritance_arrowhead /= Void
	client_arrowhead_not_void: client_arrowhead /= Void
	fontname_not_void: fontname /= Void
	fontsize_positive: fontsize > 0

end
