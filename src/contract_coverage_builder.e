note
	description: "[
		Builder for Design by Contract coverage visualization.

		Shows DBC coverage per feature with color coding:
		- Green: has require AND ensure
		- Yellow: has require OR ensure (but not both)
		- Red: no contracts (non-attributes without any DBC)
		- Gray: attributes (no contracts expected)

		Includes legend and statistics.
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	CONTRACT_COVERAGE_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_renderer: GRAPHVIZ_RENDERER)
			-- Create builder with `a_renderer'.
		require
			renderer_not_void: a_renderer /= Void
		do
			renderer := a_renderer
			create graph.make_digraph ("ContractCoverage")
			graph.attributes.put ("rankdir", "TB")
			graph.attributes.put ("label", "Contract Coverage")
			graph.attributes.put ("fontsize", "16")
			graph.attributes.put ("labelloc", "t")
			graph.attributes.put ("compound", "true")

			-- Statistics
			total_features := 0
			full_contract_count := 0
			partial_contract_count := 0
			no_contract_count := 0
			attribute_count := 0
		ensure
			renderer_set: renderer = a_renderer
			counters_zero: total_features = 0 and full_contract_count = 0
		end

feature -- Access

	renderer: GRAPHVIZ_RENDERER
			-- Renderer for producing output.

	graph: DOT_GRAPH
			-- Graph being built.

feature -- Statistics

	total_features: INTEGER
			-- Total number of features processed.

	full_contract_count: INTEGER
			-- Features with both require and ensure.

	partial_contract_count: INTEGER
			-- Features with require or ensure (but not both).

	no_contract_count: INTEGER
			-- Features without any contracts.

	attribute_count: INTEGER
			-- Attributes (contracts not expected).

feature -- Configuration

	set_title (a_title: STRING): like Current
			-- Set diagram title.
		require
			title_not_void: a_title /= Void
		do
			graph.attributes.put ("label", a_title)
			Result := Current
		ensure
			title_set: graph.attributes.has ("label")
			result_is_current: Result = Current
		end

feature -- Building

	add_class (a_class_name: STRING; a_features: ITERABLE [TUPLE [name: STRING; has_require: BOOLEAN; has_ensure: BOOLEAN; is_attribute: BOOLEAN]])
			-- Add a class with its features to the diagram.
		require
			class_name_not_void: a_class_name /= Void
			class_name_not_empty: not a_class_name.is_empty
			features_not_void: a_features /= Void
		local
			l_subgraph: DOT_SUBGRAPH
			l_node: DOT_NODE
			l_color: STRING
			l_feature_name: STRING
			l_has_require, l_has_ensure, l_is_attribute: BOOLEAN
		do
			-- Create a subgraph (cluster) for the class
			create l_subgraph.make_cluster (a_class_name)
			l_subgraph.attributes.put ("label", a_class_name)
			l_subgraph.attributes.put ("style", "filled")
			l_subgraph.attributes.put ("fillcolor", "white")
			l_subgraph.attributes.put ("fontsize", "14")

			-- Add features as nodes
			across a_features as ic loop
				l_feature_name := ic.name
				l_has_require := ic.has_require
				l_has_ensure := ic.has_ensure
				l_is_attribute := ic.is_attribute

				total_features := total_features + 1

				-- Determine color based on contract status
				if l_is_attribute then
					l_color := Color_attribute
					attribute_count := attribute_count + 1
				elseif l_has_require and l_has_ensure then
					l_color := Color_full_contract
					full_contract_count := full_contract_count + 1
				elseif l_has_require or l_has_ensure then
					l_color := Color_partial_contract
					partial_contract_count := partial_contract_count + 1
				else
					l_color := Color_no_contract
					no_contract_count := no_contract_count + 1
				end

				-- Create feature node with unique ID
				create l_node.make (a_class_name + "_" + l_feature_name)
				l_node.attributes.put ("label", l_feature_name)
				l_node.attributes.put ("shape", "box")
				l_node.attributes.put ("style", "filled")
				l_node.attributes.put ("fillcolor", l_color)
				l_node.attributes.put ("fontsize", "10")

				l_subgraph.add_node (l_node)
			end

			graph.add_subgraph (l_subgraph)
		end

	add_legend
			-- Add a legend explaining colors.
		local
			l_legend: DOT_SUBGRAPH
			l_node: DOT_NODE
			l_stats: STRING
		do
			create l_legend.make_cluster ("legend")
			l_legend.attributes.put ("label", "Legend")
			l_legend.attributes.put ("style", "filled")
			l_legend.attributes.put ("fillcolor", "lightyellow")

			-- Full contract node
			create l_node.make ("legend_full")
			l_node.attributes.put ("label", "Full Contract%N(require + ensure)")
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "filled")
			l_node.attributes.put ("fillcolor", Color_full_contract)
			l_legend.add_node (l_node)

			-- Partial contract node
			create l_node.make ("legend_partial")
			l_node.attributes.put ("label", "Partial Contract%N(require or ensure)")
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "filled")
			l_node.attributes.put ("fillcolor", Color_partial_contract)
			l_legend.add_node (l_node)

			-- No contract node
			create l_node.make ("legend_none")
			l_node.attributes.put ("label", "No Contract")
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "filled")
			l_node.attributes.put ("fillcolor", Color_no_contract)
			l_legend.add_node (l_node)

			-- Attribute node
			create l_node.make ("legend_attr")
			l_node.attributes.put ("label", "Attribute%N(n/a)")
			l_node.attributes.put ("shape", "box")
			l_node.attributes.put ("style", "filled")
			l_node.attributes.put ("fillcolor", Color_attribute)
			l_legend.add_node (l_node)

			-- Statistics node
			create l_stats.make (200)
			l_stats.append ("Statistics%N")
			l_stats.append ("Full: " + full_contract_count.out + "%N")
			l_stats.append ("Partial: " + partial_contract_count.out + "%N")
			l_stats.append ("None: " + no_contract_count.out + "%N")
			l_stats.append ("Attr: " + attribute_count.out + "%N")
			l_stats.append ("Total: " + total_features.out)

			create l_node.make ("legend_stats")
			l_node.attributes.put ("label", l_stats)
			l_node.attributes.put ("shape", "note")
			l_node.attributes.put ("style", "filled")
			l_node.attributes.put ("fillcolor", "white")
			l_legend.add_node (l_node)

			graph.add_subgraph (l_legend)
		end

feature -- Metrics

	coverage_percentage: REAL_64
			-- Percentage of non-attribute features with full contracts.
		local
			l_non_attrs: INTEGER
		do
			l_non_attrs := total_features - attribute_count
			if l_non_attrs > 0 then
				Result := (full_contract_count / l_non_attrs) * 100.0
			end
		end

	partial_coverage_percentage: REAL_64
			-- Percentage of non-attribute features with at least partial contracts.
		local
			l_non_attrs: INTEGER
		do
			l_non_attrs := total_features - attribute_count
			if l_non_attrs > 0 then
				Result := ((full_contract_count + partial_contract_count) / l_non_attrs) * 100.0
			end
		end

feature -- Output

	to_dot: STRING
			-- Generate DOT source.
		do
			Result := graph.to_dot
		ensure
			not_void: Result /= Void
		end

	to_svg: GRAPHVIZ_RESULT
			-- Render to SVG.
		do
			Result := renderer.render_svg (graph.to_dot)
		ensure
			result_not_void: Result /= Void
		end

	to_svg_file (a_path: STRING): GRAPHVIZ_RESULT
			-- Render to SVG file.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			Result := renderer.render_to_file (graph.to_dot, "svg", a_path)
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- Constants

	Color_full_contract: STRING = "palegreen"
			-- Color for features with both require and ensure.

	Color_partial_contract: STRING = "khaki"
			-- Color for features with require or ensure.

	Color_no_contract: STRING = "lightcoral"
			-- Color for features without contracts.

	Color_attribute: STRING = "lightgray"
			-- Color for attributes.

invariant
	renderer_not_void: renderer /= Void
	graph_not_void: graph /= Void
	non_negative_stats: total_features >= 0 and full_contract_count >= 0 and
	                    partial_contract_count >= 0 and no_contract_count >= 0

end
