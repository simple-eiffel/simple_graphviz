note
	description: "Result of a GraphViz rendering operation"
	author: "Larry Rix"
	date: "2026-01-22"

class
	GRAPHVIZ_RESULT

create
	make_success, make_failure

feature {NONE} -- Initialization

	make_success (a_content: STRING)
			-- Create successful result with `a_content`.
		require
			content_not_void: a_content /= Void
		do
			is_success := True
			content := a_content
			error := Void
		ensure
			is_success: is_success
			content_set: attached content as c implies c.same_string (a_content)
			no_error: error = Void
		end

	make_failure (a_error: GRAPHVIZ_ERROR)
			-- Create failed result with `a_error`.
		require
			error_not_void: a_error /= Void
		do
			is_success := False
			content := Void
			error := a_error
		ensure
			is_failure: not is_success
			no_content: content = Void
			error_set: error = a_error
		end

feature -- Access

	is_success: BOOLEAN
			-- Did the operation succeed?

	content: detachable STRING
			-- Rendered content (SVG, etc.) if successful.

	error: detachable GRAPHVIZ_ERROR
			-- Error information if failed.

feature -- Status Report

	is_failure: BOOLEAN
			-- Did the operation fail?
		do
			Result := not is_success
		ensure
			definition: Result = not is_success
		end

feature -- Operations

	save_to_file (a_path: STRING): BOOLEAN
			-- Save content to file at `a_path`.
			-- Returns True on success, False on failure.
		require
			is_success: is_success
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
		do
			if attached content as c then
				create l_file.make_open_write (a_path)
				if l_file.is_open_write then
					l_file.put_string (c)
					l_file.close
					Result := True
				end
			end
		ensure
			-- Cannot express file existence in contract without side effects
		end

invariant
	success_xor_error: is_success xor (error /= Void)
	success_has_content: is_success implies content /= Void

end
