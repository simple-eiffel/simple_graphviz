note
	description: "A node in a DOT graph with attributes"
	author: "Larry Rix"
	date: "2026-01-22"

class
	DOT_NODE

create
	make

feature {NONE} -- Initialization

	make (a_id: STRING)
			-- Create node with `a_id`.
		require
			id_not_void: a_id /= Void
			id_not_empty: not a_id.is_empty
		do
			id := a_id
			create attributes.make
		ensure
			id_set: id.same_string (a_id)
			no_attributes: attributes.is_empty
		end

feature -- Access

	id: STRING
			-- Unique identifier for this node.

	attributes: DOT_ATTRIBUTES
			-- Visual and structural attributes.

	label: detachable STRING
			-- Display label (uses id if not set).
		do
			Result := attributes ["label"]
		end

	shape: detachable STRING
			-- Node shape (box, ellipse, diamond, etc.).
		do
			Result := attributes ["shape"]
		end

feature -- Common Attribute Setters

	set_label (a_label: STRING): like Current
			-- Set display label.
		require
			label_not_void: a_label /= Void
		do
			attributes.put ("label", a_label)
			Result := Current
		ensure
			label_set: attached label as l implies l.same_string (a_label)
			result_is_current: Result = Current
		end

	set_shape (a_shape: STRING): like Current
			-- Set node shape.
		require
			shape_not_void: a_shape /= Void
		do
			attributes.put ("shape", a_shape)
			Result := Current
		ensure
			shape_set: attached shape as s implies s.same_string (a_shape)
			result_is_current: Result = Current
		end

	set_color (a_color: STRING): like Current
			-- Set border color.
		require
			color_not_void: a_color /= Void
		do
			attributes.put ("color", a_color)
			Result := Current
		ensure
			color_set: attributes.has ("color")
			result_is_current: Result = Current
		end

	set_fillcolor (a_color: STRING): like Current
			-- Set fill color (requires style=filled).
		require
			color_not_void: a_color /= Void
		do
			attributes.put ("fillcolor", a_color)
			Result := Current
		ensure
			fillcolor_set: attributes.has ("fillcolor")
			result_is_current: Result = Current
		end

	set_style (a_style: STRING): like Current
			-- Set style (solid, dashed, filled, etc.).
		require
			style_not_void: a_style /= Void
		do
			attributes.put ("style", a_style)
			Result := Current
		ensure
			style_set: attributes.has ("style")
			result_is_current: Result = Current
		end

	set_fontname (a_font: STRING): like Current
			-- Set font name.
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
			-- Set font size in points.
		require
			size_positive: a_size > 0
		do
			attributes.put ("fontsize", a_size.out)
			Result := Current
		ensure
			fontsize_set: attributes.has ("fontsize")
			result_is_current: Result = Current
		end

	set_width (a_width: REAL): like Current
			-- Set minimum width in inches.
		require
			width_positive: a_width > 0
		do
			attributes.put ("width", a_width.out)
			Result := Current
		ensure
			width_set: attributes.has ("width")
			result_is_current: Result = Current
		end

	set_height (a_height: REAL): like Current
			-- Set minimum height in inches.
		require
			height_positive: a_height > 0
		do
			attributes.put ("height", a_height.out)
			Result := Current
		ensure
			height_set: attributes.has ("height")
			result_is_current: Result = Current
		end

	set_penwidth (a_width: REAL): like Current
			-- Set border width in points.
		require
			width_positive: a_width > 0
		do
			attributes.put ("penwidth", a_width.out)
			Result := Current
		ensure
			penwidth_set: attributes.has ("penwidth")
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

	to_dot: STRING
			-- DOT format string for this node.
		do
			create Result.make (50)
			Result.append_string (attributes.escape_value (id))
			if not attributes.is_empty then
				Result.append_character (' ')
				Result.append_string (attributes.to_dot)
			end
		ensure
			not_void: Result /= Void
			contains_id: Result.has_substring (id) or Result.has_substring (attributes.escape_value (id))
		end

invariant
	id_not_void: id /= Void
	id_not_empty: not id.is_empty
	attributes_not_void: attributes /= Void

end
