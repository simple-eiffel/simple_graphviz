note
	description: "An edge between two nodes in a DOT graph"
	author: "Larry Rix"
	date: "2026-01-22"

class
	DOT_EDGE

create
	make

feature {NONE} -- Initialization

	make (a_from, a_to: STRING)
			-- Create edge from `a_from` to `a_to`.
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		do
			from_id := a_from
			to_id := a_to
			create attributes.make
		ensure
			from_set: from_id.same_string (a_from)
			to_set: to_id.same_string (a_to)
			no_attributes: attributes.is_empty
		end

feature -- Access

	from_id: STRING
			-- Source node identifier.

	to_id: STRING
			-- Target node identifier.

	attributes: DOT_ATTRIBUTES
			-- Visual and structural attributes.

	label: detachable STRING
			-- Edge label.
		do
			Result := attributes ["label"]
		end

feature -- Common Attribute Setters

	set_label (a_label: STRING): like Current
			-- Set edge label.
		require
			label_not_void: a_label /= Void
		do
			attributes.put ("label", a_label)
			Result := Current
		ensure
			label_set: attached label as l implies l.same_string (a_label)
			result_is_current: Result = Current
		end

	set_color (a_color: STRING): like Current
			-- Set edge color.
		require
			color_not_void: a_color /= Void
		do
			attributes.put ("color", a_color)
			Result := Current
		ensure
			color_set: attributes.has ("color")
			result_is_current: Result = Current
		end

	set_style (a_style: STRING): like Current
			-- Set edge style (solid, dashed, dotted, bold).
		require
			style_not_void: a_style /= Void
		do
			attributes.put ("style", a_style)
			Result := Current
		ensure
			style_set: attributes.has ("style")
			result_is_current: Result = Current
		end

	set_arrowhead (a_arrow: STRING): like Current
			-- Set arrowhead style (normal, vee, diamond, dot, none, etc.).
		require
			arrow_not_void: a_arrow /= Void
		do
			attributes.put ("arrowhead", a_arrow)
			Result := Current
		ensure
			arrowhead_set: attributes.has ("arrowhead")
			result_is_current: Result = Current
		end

	set_arrowtail (a_arrow: STRING): like Current
			-- Set arrowtail style.
		require
			arrow_not_void: a_arrow /= Void
		do
			attributes.put ("arrowtail", a_arrow)
			Result := Current
		ensure
			arrowtail_set: attributes.has ("arrowtail")
			result_is_current: Result = Current
		end

	set_penwidth (a_width: REAL): like Current
			-- Set edge line width in points.
		require
			width_positive: a_width > 0
		do
			attributes.put ("penwidth", a_width.out)
			Result := Current
		ensure
			penwidth_set: attributes.has ("penwidth")
			result_is_current: Result = Current
		end

	set_fontname (a_font: STRING): like Current
			-- Set label font name.
		require
			font_not_void: a_font /= Void
		do
			attributes.put ("fontname", a_font)
			Result := Current
		ensure
			fontname_set: attributes.has ("fontname")
			result_is_current: Result = Current
		end

	set_fontsize (a_size: INTEGER): like Current
			-- Set label font size in points.
		require
			size_positive: a_size > 0
		do
			attributes.put ("fontsize", a_size.out)
			Result := Current
		ensure
			fontsize_set: attributes.has ("fontsize")
			result_is_current: Result = Current
		end

	set_constraint (a_value: BOOLEAN): like Current
			-- Set whether edge affects node ranking.
		do
			attributes.put ("constraint", if a_value then "true" else "false" end)
			Result := Current
		ensure
			constraint_set: attributes.has ("constraint")
			result_is_current: Result = Current
		end

	set_dir (a_direction: STRING): like Current
			-- Set arrow direction (forward, back, both, none).
		require
			direction_not_void: a_direction /= Void
		do
			attributes.put ("dir", a_direction)
			Result := Current
		ensure
			dir_set: attributes.has ("dir")
			result_is_current: Result = Current
		end

feature -- Arbitrary Attributes

	set_attribute (a_key, a_value: STRING): like Current
			-- Set arbitrary attribute.
		require
			key_not_void: a_key /= Void
			key_not_empty: not a_key.is_empty
			value_not_void: a_value /= Void
		do
			attributes.put (a_key, a_value)
			Result := Current
		ensure
			attribute_set: attributes.has (a_key)
			result_is_current: Result = Current
		end

feature -- Conversion

	to_dot (a_directed: BOOLEAN): STRING
			-- DOT format string for this edge.
			-- Uses "->" for directed, "--" for undirected.
		local
			l_connector: STRING
		do
			if a_directed then
				l_connector := " -> "
			else
				l_connector := " -- "
			end
			create Result.make (50)
			Result.append_string (attributes.escape_value (from_id))
			Result.append_string (l_connector)
			Result.append_string (attributes.escape_value (to_id))
			if not attributes.is_empty then
				Result.append_character (' ')
				Result.append_string (attributes.to_dot)
			end
		ensure
			not_void: Result /= Void
			has_connector: a_directed implies Result.has_substring ("->")
			has_undirected_connector: not a_directed implies Result.has_substring ("--")
		end

invariant
	from_id_not_void: from_id /= Void
	from_id_not_empty: not from_id.is_empty
	to_id_not_void: to_id /= Void
	to_id_not_empty: not to_id.is_empty
	attributes_not_void: attributes /= Void

end
