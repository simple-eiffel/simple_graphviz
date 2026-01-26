note
	description: "Key-value attribute pairs for DOT elements with proper escaping"
	author: "Larry Rix"
	date: "2026-01-22"

class
	DOT_ATTRIBUTES

inherit
	ANY
		redefine
			default_create
		end

create
	make, default_create

feature {NONE} -- Initialization

	default_create
			-- Create empty attributes.
		do
			make
		ensure then
			is_empty: count = 0
		end

	make
			-- Create empty attributes collection.
		do
			create internal_table.make (10)
		ensure
			is_empty: count = 0
		end

feature -- Model Queries

	attributes_model: MML_MAP [STRING, STRING]
			-- Mathematical model of all attributes.
		do
			create Result.default_create
			across internal_table.current_keys as key loop
				if attached internal_table.item (key) as l_value then
					Result := Result.updated (key, l_value)
				end
			end
		end

feature -- Access

	item alias "[]" (a_key: STRING): detachable STRING
			-- Value for `a_key`, or Void if not present.
		require
			key_not_void: a_key /= Void
		do
			Result := internal_table.item (a_key)
		ensure
			result_if_has: has (a_key) implies Result /= Void
		end

	count: INTEGER
			-- Number of attributes.
		do
			Result := internal_table.count
		ensure
			non_negative: Result >= 0
		end

feature -- Status Report

	is_empty: BOOLEAN
			-- Are there no attributes?
		do
			Result := internal_table.is_empty
		ensure
			definition: Result = (count = 0)
		end

	has (a_key: STRING): BOOLEAN
			-- Is there an attribute with `a_key`?
		require
			key_not_void: a_key /= Void
		do
			Result := internal_table.has (a_key)
		ensure
			definition: Result = attributes_model.domain.has (a_key)
		end

feature -- Element Change

	put (a_key, a_value: STRING)
			-- Add or update attribute `a_key` with `a_value`.
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			internal_table.force (a_value, a_key)
		ensure
			has_key: has (a_key)
			value_set: attached item (a_key) as v implies v.same_string (a_value)
			others_unchanged: attributes_model.removed (a_key).domain |=| old attributes_model.removed (a_key).domain
		end

	remove (a_key: STRING)
			-- Remove attribute with `a_key` if present.
		require
			key_not_void: a_key /= Void
		do
			internal_table.remove (a_key)
		ensure
			not_has: not has (a_key)
			others_unchanged: attributes_model |=| old attributes_model.removed (a_key)
		end

feature -- Conversion

	to_dot: STRING
			-- DOT format string "[key=value, ...]" or empty if no attributes.
		local
			l_first: BOOLEAN
		do
			if is_empty then
				create Result.make_empty
			else
				create Result.make (50)
				Result.append_character ('[')
				l_first := True
				across internal_table.current_keys as key loop
					if attached internal_table.item (key) as l_value then
						if not l_first then
							Result.append_string (", ")
						end
						Result.append_string (key)
						Result.append_character ('=')
						Result.append_string (escape_value (l_value))
						l_first := False
					end
				end
				Result.append_character (']')
			end
		ensure
			not_void: Result /= Void
			empty_if_none: is_empty implies Result.is_empty
			bracketed_if_any: not is_empty implies (Result.starts_with ("[") and Result.ends_with ("]"))
		end

feature -- Utilities

	escape_value (a_value: STRING): STRING
			-- `a_value` with DOT special characters escaped.
			-- Quotes strings containing spaces, quotes, special chars, or record syntax.
		require
			value_not_void: a_value /= Void
		local
			l_needs_quotes: BOOLEAN
			i: INTEGER
			c: CHARACTER
		do
			-- Check if quoting needed
			l_needs_quotes := False
			from i := 1 until i > a_value.count or l_needs_quotes loop
				c := a_value.item (i)
				if c = ' ' or c = '"' or c = '\' or c = '%N' or c = ',' or c = '=' or c = '{' or c = '}' or c = '|' then
					l_needs_quotes := True
				end
				i := i + 1
			end

			if l_needs_quotes then
				create Result.make (a_value.count + 10)
				Result.append_character ('"')
				from i := 1 until i > a_value.count loop
					c := a_value.item (i)
					inspect c
					when '"' then
						Result.append_string ("\%"")
					when '\' then
						Result.append_string ("\\")
					when '%N' then
						Result.append_string ("\n")
					else
						Result.append_character (c)
					end
					i := i + 1
				end
				Result.append_character ('"')
			else
				Result := a_value.twin
			end
		ensure
			not_void: Result /= Void
			not_shorter: Result.count >= a_value.count
		end

feature {DOT_GRAPH, DOT_SUBGRAPH} -- Implementation

	internal_table: HASH_TABLE [STRING, STRING]
			-- Internal storage.

invariant
	internal_table_exists: internal_table /= Void
	count_consistent: count = internal_table.count

end
