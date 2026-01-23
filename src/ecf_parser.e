note
	description: "[
		Parser for EiffelStudio .ecf configuration files.
		Extracts library name, source clusters, and library dependencies.
		Resolves relative paths and environment variables ($SIMPLE_EIFFEL, $ISE_LIBRARY).
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	ECF_PARSER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize parser.
		do
			create library_name.make_empty
			create source_clusters.make (5)
			create internal_dependencies.make (10)
			create external_dependencies.make (10)
			ecf_directory := ""
		ensure
			library_name_empty: library_name.is_empty
			no_clusters: source_clusters.is_empty
			no_internal: internal_dependencies.is_empty
			no_external: external_dependencies.is_empty
		end

feature -- Access

	library_name: STRING
			-- Name of the library from ECF.

	source_clusters: ARRAYED_LIST [TUPLE [name: STRING; location: STRING]]
			-- Source clusters (name and resolved location).

	internal_dependencies: ARRAYED_LIST [TUPLE [name: STRING; location: STRING]]
			-- Internal dependencies (simple_* libraries).

	external_dependencies: ARRAYED_LIST [TUPLE [name: STRING; location: STRING]]
			-- External dependencies (ISE_LIBRARY, GOBO, etc.).

	ecf_directory: STRING
			-- Directory containing the parsed ECF file.

feature -- Status

	has_error: BOOLEAN
			-- Did parsing fail?

	error_message: detachable STRING
			-- Error description if parsing failed.

feature -- Parsing

	parse_file (a_path: STRING)
			-- Parse ECF file at `a_path'.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
			l_file: RAW_FILE
		do
			-- Reset state
			library_name.wipe_out
			source_clusters.wipe_out
			internal_dependencies.wipe_out
			external_dependencies.wipe_out
			has_error := False
			error_message := Void

			-- Extract directory from path
			ecf_directory := directory_from_path (a_path)

			-- Check file exists
			create l_file.make_with_name (a_path)
			if not l_file.exists then
				has_error := True
				error_message := "ECF file not found: " + a_path
			else
				-- Parse XML
				create l_xml.make
				l_doc := l_xml.parse_file (a_path)

				if l_doc.has_error then
					has_error := True
					error_message := "XML parse error: " + l_doc.error_message
				else
					parse_document (l_doc)
				end
			end
		ensure
			error_implies_message: has_error implies error_message /= Void
		end

feature {NONE} -- Implementation

	parse_document (a_doc: SIMPLE_XML_DOCUMENT)
			-- Parse ECF document structure.
		require
			doc_valid: a_doc.is_valid
		local
			l_system_name: detachable STRING
		do
			-- Get system name from root element
			if attached a_doc.root as l_root then
				l_system_name := l_root.attr ("name")
				if attached l_system_name as sn then
					library_name := sn.twin
				end

				-- Parse first target (main library target)
				parse_targets (l_root)
			else
				has_error := True
				error_message := "ECF has no root element"
			end
		end

	parse_targets (a_root: SIMPLE_XML_ELEMENT)
			-- Parse all target elements.
		local
			l_targets: ARRAYED_LIST [SIMPLE_XML_ELEMENT]
		do
			l_targets := a_root.elements ("target")
			across l_targets as ic loop
				parse_target (ic)
			end
		end

	parse_target (a_target: SIMPLE_XML_ELEMENT)
			-- Parse a single target element.
		local
			l_clusters: ARRAYED_LIST [SIMPLE_XML_ELEMENT]
			l_libraries: ARRAYED_LIST [SIMPLE_XML_ELEMENT]
		do
			-- Parse clusters
			l_clusters := a_target.elements ("cluster")
			across l_clusters as ic loop
				parse_cluster (ic)
			end

			-- Parse library dependencies
			l_libraries := a_target.elements ("library")
			across l_libraries as ic loop
				parse_library (ic)
			end
		end

	parse_cluster (a_cluster: SIMPLE_XML_ELEMENT)
			-- Parse a cluster element.
		local
			l_name, l_location: detachable STRING
			l_resolved: STRING
		do
			l_name := a_cluster.attr ("name")
			l_location := a_cluster.attr ("location")

			if attached l_name as n and attached l_location as loc then
				l_resolved := resolve_path (loc)
				source_clusters.extend ([n.twin, l_resolved])
			end
		end

	parse_library (a_library: SIMPLE_XML_ELEMENT)
			-- Parse a library dependency element.
		local
			l_name, l_location: detachable STRING
			l_resolved: STRING
		do
			l_name := a_library.attr ("name")
			l_location := a_library.attr ("location")

			if attached l_name as n and attached l_location as loc then
				l_resolved := resolve_path (loc)
				if is_internal_dependency (loc) then
					internal_dependencies.extend ([n.twin, l_resolved])
				else
					external_dependencies.extend ([n.twin, l_resolved])
				end
			end
		end

	is_internal_dependency (a_location: STRING): BOOLEAN
			-- Is `a_location' an internal simple_* dependency?
		do
			Result := a_location.has_substring ("$SIMPLE_EIFFEL") or
			          a_location.has_substring ("simple_")
		end

	resolve_path (a_path: STRING): STRING
			-- Resolve environment variables and relative paths.
		local
			l_env_value: detachable READABLE_STRING_32
			l_exec_env: EXECUTION_ENVIRONMENT
		do
			create l_exec_env
			Result := a_path.twin

			-- Replace $SIMPLE_EIFFEL
			if Result.has_substring ("$SIMPLE_EIFFEL") then
				l_env_value := l_exec_env.item ("SIMPLE_EIFFEL")
				if attached l_env_value as ev then
					Result.replace_substring_all ("$SIMPLE_EIFFEL", ev.to_string_8)
				else
					-- Default to /d/prod if not set
					Result.replace_substring_all ("$SIMPLE_EIFFEL", "/d/prod")
				end
			end

			-- Replace $ISE_LIBRARY
			if Result.has_substring ("$ISE_LIBRARY") then
				l_env_value := l_exec_env.item ("ISE_LIBRARY")
				if attached l_env_value as ev then
					Result.replace_substring_all ("$ISE_LIBRARY", ev.to_string_8)
				end
			end

			-- Replace $GOBO_LIBRARY
			if Result.has_substring ("$GOBO_LIBRARY") then
				l_env_value := l_exec_env.item ("GOBO_LIBRARY")
				if attached l_env_value as ev then
					Result.replace_substring_all ("$GOBO_LIBRARY", ev.to_string_8)
				end
			end

			-- Handle relative paths starting with .\ or ./
			if Result.starts_with (".\") or Result.starts_with ("./") then
				Result := ecf_directory + "/" + Result.substring (3, Result.count)
			end

			-- Normalize path separators
			Result.replace_substring_all ("\", "/")
		end

	directory_from_path (a_path: STRING): STRING
			-- Extract directory from file path.
		local
			l_pos: INTEGER
		do
			Result := a_path.twin
			Result.replace_substring_all ("\", "/")
			l_pos := Result.last_index_of ('/', Result.count)
			if l_pos > 0 then
				Result := Result.substring (1, l_pos - 1)
			else
				Result := "."
			end
		end

invariant
	library_name_not_void: library_name /= Void
	source_clusters_not_void: source_clusters /= Void
	internal_dependencies_not_void: internal_dependencies /= Void
	external_dependencies_not_void: external_dependencies /= Void

end
