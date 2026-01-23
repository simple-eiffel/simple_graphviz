note
	description: "[
		Automatic page size selection for GraphViz output.
		Selects appropriate page size based on content complexity
		to ensure human-readable output.

		Supports standard page sizes from Letter to plotter sizes.
	]"
	author: "Larry Rix"
	date: "2026-01-23"

class
	GRAPHVIZ_PAGE_SIZER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize with default settings.
		do
			margin_inches := 0.5
			min_node_separation := 0.5
			min_rank_separation := 0.75
			target_font_size := 10
			max_label_chars_per_inch := 12
		ensure
			margin_set: margin_inches = 0.5
		end

feature -- Access

	margin_inches: REAL_64
			-- Page margin in inches.

	min_node_separation: REAL_64
			-- Minimum horizontal separation between nodes in inches.

	min_rank_separation: REAL_64
			-- Minimum vertical separation between ranks in inches.

	target_font_size: INTEGER
			-- Target font size in points.

	max_label_chars_per_inch: INTEGER
			-- Maximum characters that fit per inch at target font size.

feature -- Page Sizes (width x height in inches)

	page_sizes: ARRAY [TUPLE [name: STRING; width, height: REAL_64]]
			-- Available page sizes, smallest to largest.
		once
			Result := <<
				["Letter", 8.5, 11.0],
				["Letter-L", 11.0, 8.5],
				["Legal", 8.5, 14.0],
				["Legal-L", 14.0, 8.5],
				["Tabloid", 11.0, 17.0],
				["Tabloid-L", 17.0, 11.0],
				["A3", 11.69, 16.54],
				["A3-L", 16.54, 11.69],
				["A2", 16.54, 23.39],
				["A2-L", 23.39, 16.54],
				["ANSI-C", 17.0, 22.0],
				["ANSI-C-L", 22.0, 17.0],
				["Arch-D", 24.0, 36.0],
				["Arch-D-L", 36.0, 24.0],
				["ANSI-D", 22.0, 34.0],
				["ANSI-D-L", 34.0, 22.0],
				["A1", 23.39, 33.11],
				["A1-L", 33.11, 23.39],
				["Arch-E", 36.0, 48.0],
				["Arch-E-L", 48.0, 36.0],
				["ANSI-E", 34.0, 44.0],
				["ANSI-E-L", 44.0, 34.0],
				["A0", 33.11, 46.81],
				["A0-L", 46.81, 33.11]
			>>
		end

feature -- Calculation

	calculate_for_graph (a_node_count, a_edge_count: INTEGER; a_max_label_length: INTEGER; a_is_hierarchical: BOOLEAN): TUPLE [page_name: STRING; width, height: REAL_64; rankdir: STRING; nodesep, ranksep: REAL_64; fontsize: INTEGER]
			-- Calculate optimal page configuration for given graph metrics.
			-- `a_is_hierarchical` True for tree/hierarchy layouts (TB/BT), False for network layouts (LR/RL).
		require
			positive_nodes: a_node_count >= 0
			positive_edges: a_edge_count >= 0
			positive_label: a_max_label_length >= 0
		local
			l_estimated_width, l_estimated_height: REAL_64
			l_node_width, l_node_height: REAL_64
			l_cols, l_rows: INTEGER
			l_usable_width, l_usable_height: REAL_64
			l_page: detachable TUPLE [name: STRING; width, height: REAL_64]
			l_found: BOOLEAN
			l_rankdir: STRING
			l_nodesep, l_ranksep: REAL_64
			l_fontsize: INTEGER
			l_sqrt_approx: INTEGER
			l_page_width, l_page_height: REAL_64
			l_page_name: STRING
		do
			-- Estimate node dimensions based on label length
			l_node_width := (a_max_label_length / max_label_chars_per_inch).max (1.5)
			l_node_height := 0.5  -- Approximate height for single-line node

			-- Approximate square root using integer operations
			l_sqrt_approx := integer_sqrt (a_node_count.max (1))

			-- Estimate grid layout based on node count
			if a_is_hierarchical then
				-- For hierarchies, estimate depth and breadth
				l_rows := l_sqrt_approx.max (1)
				l_cols := ((a_node_count + l_rows - 1) // l_rows).max (1)
				l_rankdir := "TB"
			else
				-- For networks, prefer wider layout
				l_cols := ((l_sqrt_approx * 3) // 2).max (1)
				l_rows := ((a_node_count + l_cols - 1) // l_cols).max (1)
				l_rankdir := "LR"
			end

			-- Calculate estimated dimensions needed
			l_estimated_width := l_cols * (l_node_width + min_node_separation)
			l_estimated_height := l_rows * (l_node_height + min_rank_separation)

			-- Add margins
			l_estimated_width := l_estimated_width + (margin_inches * 2)
			l_estimated_height := l_estimated_height + (margin_inches * 2)

			-- Find smallest page that fits
			l_found := False
			l_page_name := "A0-L"  -- Default to largest
			l_page_width := 46.81
			l_page_height := 33.11

			across page_sizes as ic until l_found loop
				l_page := ic
				if attached l_page as lp then
					l_usable_width := lp.width - (margin_inches * 2)
					l_usable_height := lp.height - (margin_inches * 2)

					if l_estimated_width <= l_usable_width and l_estimated_height <= l_usable_height then
						l_found := True
						l_page_name := lp.name
						l_page_width := lp.width
						l_page_height := lp.height
					end
				end
			end

			-- Calculate optimal spacing to fill the page
			l_usable_width := l_page_width - (margin_inches * 2)
			l_usable_height := l_page_height - (margin_inches * 2)

			if l_cols > 1 then
				l_nodesep := ((l_usable_width - (l_cols * l_node_width)) / (l_cols - 1)).max (min_node_separation)
			else
				l_nodesep := min_node_separation
			end

			if l_rows > 1 then
				l_ranksep := ((l_usable_height - (l_rows * l_node_height)) / (l_rows - 1)).max (min_rank_separation)
			else
				l_ranksep := min_rank_separation
			end

			-- Clamp spacing to reasonable values
			l_nodesep := l_nodesep.min (2.0)
			l_ranksep := l_ranksep.min (2.0)

			-- Adjust font size for very large graphs
			if a_node_count > 100 then
				l_fontsize := 8
			elseif a_node_count > 50 then
				l_fontsize := 9
			else
				l_fontsize := target_font_size
			end

			Result := [l_page_name, l_page_width, l_page_height, l_rankdir, l_nodesep, l_ranksep, l_fontsize]
		ensure
			result_not_void: Result /= Void
		end

	integer_sqrt (n: INTEGER): INTEGER
			-- Approximate integer square root.
		require
			non_negative: n >= 0
		local
			l_guess: INTEGER
		do
			if n = 0 then
				Result := 0
			elseif n < 4 then
				Result := 1
			else
				-- Newton's method approximation
				l_guess := n // 2
				from
				until
					l_guess * l_guess <= n and (l_guess + 1) * (l_guess + 1) > n
				loop
					l_guess := (l_guess + n // l_guess) // 2
				end
				Result := l_guess
			end
		ensure
			result_squared_le_n: Result * Result <= n
		end

	apply_to_graph (a_graph: DOT_GRAPH; a_node_count, a_edge_count: INTEGER; a_max_label_length: INTEGER; a_is_hierarchical: BOOLEAN)
			-- Apply optimal page configuration to `a_graph`.
		require
			graph_not_void: a_graph /= Void
		local
			l_config: TUPLE [page_name: STRING; width, height: REAL_64; rankdir: STRING; nodesep, ranksep: REAL_64; fontsize: INTEGER]
			l_size: STRING
			l_page: STRING
		do
			l_config := calculate_for_graph (a_node_count, a_edge_count, a_max_label_length, a_is_hierarchical)

			-- Set page size (for multi-page output)
			create l_page.make (20)
			l_page.append (l_config.width.out)
			l_page.append (",")
			l_page.append (l_config.height.out)
			a_graph.attributes.put ("page", l_page)

			-- Set size constraint (fit within page)
			create l_size.make (20)
			l_size.append ((l_config.width - margin_inches * 2).out)
			l_size.append (",")
			l_size.append ((l_config.height - margin_inches * 2).out)
			a_graph.attributes.put ("size", l_size)

			-- Set margin
			a_graph.attributes.put ("margin", margin_inches.out)

			-- Set layout direction
			a_graph.attributes.put ("rankdir", l_config.rankdir)

			-- Set node and rank separation
			a_graph.attributes.put ("nodesep", l_config.nodesep.out)
			a_graph.attributes.put ("ranksep", l_config.ranksep.out)

			-- Set default font size
			a_graph.attributes.put ("fontsize", l_config.fontsize.out)

			-- Ensure graph fits within size
			a_graph.attributes.put ("ratio", "compress")

			-- Center the graph on the page
			a_graph.attributes.put ("center", "true")

			-- Set DPI for consistent output
			a_graph.attributes.put ("dpi", "96")
		end

feature -- Configuration

	set_margin (a_inches: REAL_64)
			-- Set page margin.
		require
			positive: a_inches >= 0
		do
			margin_inches := a_inches
		ensure
			margin_set: margin_inches = a_inches
		end

	set_target_font_size (a_size: INTEGER)
			-- Set target font size in points.
		require
			positive: a_size > 0
		do
			target_font_size := a_size
		ensure
			font_size_set: target_font_size = a_size
		end

invariant
	positive_margin: margin_inches >= 0
	positive_node_sep: min_node_separation > 0
	positive_rank_sep: min_rank_separation > 0
	positive_font_size: target_font_size > 0

end
