note
	description: "Error information from GraphViz rendering operations"
	author: "Larry Rix"
	date: "2026-01-22"

class
	GRAPHVIZ_ERROR

create
	make

feature {NONE} -- Initialization

	make (a_code: INTEGER; a_message: STRING)
			-- Create error with `a_code` and `a_message`.
		require
			valid_code: is_valid_error_code (a_code)
			message_not_void: a_message /= Void
		do
			code := a_code
			message := a_message
		ensure
			code_set: code = a_code
			message_set: message.same_string (a_message)
		end

feature -- Access

	code: INTEGER
			-- Error code (see constants).

	message: STRING
			-- Human-readable error description.

feature -- Error Codes

	Graphviz_not_found: INTEGER = 1
			-- GraphViz is not installed or not in PATH.

	Timeout: INTEGER = 2
			-- Rendering exceeded configured timeout.

	Invalid_dot: INTEGER = 3
			-- DOT syntax error - GraphViz could not parse input.

	Output_error: INTEGER = 4
			-- Failed to write output file.

	Version_mismatch: INTEGER = 5
			-- GraphViz version is too old (< 2.40).

	Unknown_error: INTEGER = 99
			-- Unclassified error.

feature -- Status Report

	is_valid_error_code (a_code: INTEGER): BOOLEAN
			-- Is `a_code` a recognized error code?
		do
			Result := a_code = Graphviz_not_found or
			          a_code = Timeout or
			          a_code = Invalid_dot or
			          a_code = Output_error or
			          a_code = Version_mismatch or
			          a_code = Unknown_error
		end

	is_graphviz_not_found: BOOLEAN
			-- Is this a "GraphViz not installed" error?
		do
			Result := code = Graphviz_not_found
		ensure
			definition: Result = (code = Graphviz_not_found)
		end

	is_timeout: BOOLEAN
			-- Is this a timeout error?
		do
			Result := code = Timeout
		ensure
			definition: Result = (code = Timeout)
		end

	is_invalid_dot: BOOLEAN
			-- Is this a DOT syntax error?
		do
			Result := code = Invalid_dot
		ensure
			definition: Result = (code = Invalid_dot)
		end

	is_output_error: BOOLEAN
			-- Is this an output file error?
		do
			Result := code = Output_error
		ensure
			definition: Result = (code = Output_error)
		end

	is_version_mismatch: BOOLEAN
			-- Is this a version mismatch error?
		do
			Result := code = Version_mismatch
		ensure
			definition: Result = (code = Version_mismatch)
		end

feature -- Conversion

	to_string: STRING
			-- Full error description.
		do
			create Result.make (message.count + 20)
			Result.append_string ("Error ")
			Result.append_integer (code)
			Result.append_string (": ")
			Result.append_string (message)
		ensure
			not_void: Result /= Void
			has_code: Result.has_substring (code.out)
			has_message: Result.has_substring (message)
		end

invariant
	valid_code: is_valid_error_code (code)
	message_not_void: message /= Void

end
