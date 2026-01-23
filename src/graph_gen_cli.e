note
	description: "[
		Command-line interface for Eiffel Graph Generator.

		Usage:
		  eiffel_graph_gen <path-to-ecf> [-o <output-dir>]
		  eiffel_graph_gen --version
		  eiffel_graph_gen --help

		Output Structure:
		  <output-dir>/graphs/<lib-name>/
		  ├── class_hierarchy.svg    # Inheritance tree
		  ├── dependencies.svg       # Library dependencies from ECF
		  ├── api_surface.svg        # Public classes and features
		  └── contract_coverage.svg  # DBC coverage visualization

		Examples:
		  eiffel_graph_gen simple_graphviz.ecf
		  eiffel_graph_gen simple_graphviz.ecf -o /d/prod/docs
		  eiffel_graph_gen /d/prod/simple_json/simple_json.ecf -o .
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	GRAPH_GEN_CLI

create
	make

feature {NONE} -- Initialization

	make
			-- Run CLI application.
		local
			l_args: ARGUMENTS_32
		do
			-- Initialize logger
			create log.make_with_level ({SIMPLE_LOGGER}.Level_info)
			log.add_file_output ("eiffel_graph_gen.log")
			log.info ("=== EIFFEL_GRAPH_GEN CLI STARTING ===")
			log.info ("Version: " + Version)

			create l_args

			if l_args.argument_count < 1 then
				print_help
			else
				process_arguments (l_args)
			end

			log.info ("=== EIFFEL_GRAPH_GEN CLI FINISHED ===")
		end

feature -- Constants

	Version: STRING = "1.0.0"
			-- Application version.

feature {NONE} -- Command Processing

	process_arguments (a_args: ARGUMENTS_32)
			-- Process command line arguments.
		local
			l_ecf_path: detachable STRING
			l_output_dir: STRING
			l_i: INTEGER
			l_arg: STRING_32
		do
			-- Default output directory is current directory
			l_output_dir := "."

			-- Parse arguments
			from l_i := 1 until l_i > a_args.argument_count loop
				l_arg := a_args.argument (l_i)

				if l_arg.same_string ("--help") or l_arg.same_string ("-h") then
					print_help
					l_i := a_args.argument_count + 1 -- Exit loop
				elseif l_arg.same_string ("--version") or l_arg.same_string ("-v") then
					print_version
					l_i := a_args.argument_count + 1 -- Exit loop
				elseif l_arg.same_string ("-o") or l_arg.same_string ("--output") then
					if l_i < a_args.argument_count then
						l_i := l_i + 1
						l_output_dir := a_args.argument (l_i).to_string_8
					else
						print_error ("Missing value for -o option")
					end
				elseif not l_arg.starts_with ("-") then
					-- Must be the ECF path
					l_ecf_path := l_arg.to_string_8
				else
					print_error ("Unknown option: " + l_arg.to_string_8)
					print_help
					l_i := a_args.argument_count + 1 -- Exit loop
				end

				l_i := l_i + 1
			end

			-- Run generator if we have an ECF path
			if attached l_ecf_path as ecf then
				run_generator (ecf, l_output_dir)
			end
		end

	run_generator (a_ecf_path: STRING; a_output_dir: STRING)
			-- Run the graph generator.
		local
			l_generator: EIFFEL_GRAPH_GENERATOR
			l_file: RAW_FILE
		do
			log.info ("ECF path: " + a_ecf_path)
			log.info ("Output dir: " + a_output_dir)

			-- Check ECF exists
			create l_file.make_with_name (a_ecf_path)
			if not l_file.exists then
				print_error ("ECF file not found: " + a_ecf_path)
			else
				print ("Generating graphs for: " + a_ecf_path + "%N")
				print ("Output directory: " + a_output_dir + "%N")

				create l_generator.make
				l_generator.generate (a_ecf_path, a_output_dir)

				if l_generator.has_error then
					if attached l_generator.error_message as em then
						print_error (em)
					else
						print_error ("Unknown error")
					end
				else
					print ("%NGeneration complete!%N")
					print ("Output: " + a_output_dir + "/graphs/" + l_generator.library_name + "/%N")
					print ("%NGenerated files:%N")
					print ("  - class_hierarchy.svg%N")
					print ("  - dependencies.svg%N")
					print ("  - api_surface.svg%N")
					print ("  - contract_coverage.svg%N")
				end
			end
		end

feature {NONE} -- Output

	print_help
			-- Print help message.
		do
			print ("eiffel_graph_gen " + Version + " - Generate documentation graphs from Eiffel libraries%N")
			print ("%N")
			print ("Usage:%N")
			print ("  eiffel_graph_gen <path-to-ecf> [-o <output-dir>]%N")
			print ("  eiffel_graph_gen --version%N")
			print ("  eiffel_graph_gen --help%N")
			print ("%N")
			print ("Arguments:%N")
			print ("  <path-to-ecf>    Path to the library's .ecf configuration file%N")
			print ("%N")
			print ("Options:%N")
			print ("  -o, --output <dir>   Output directory (default: current directory)%N")
			print ("  -v, --version        Show version information%N")
			print ("  -h, --help           Show this help message%N")
			print ("%N")
			print ("Output Structure:%N")
			print ("  <output-dir>/graphs/<lib-name>/%N")
			print ("  +-- class_hierarchy.svg    Inheritance tree%N")
			print ("  +-- dependencies.svg       Library dependencies from ECF%N")
			print ("  +-- api_surface.svg        Public classes and features%N")
			print ("  +-- contract_coverage.svg  DBC coverage visualization%N")
			print ("%N")
			print ("Examples:%N")
			print ("  eiffel_graph_gen simple_graphviz.ecf%N")
			print ("  eiffel_graph_gen simple_graphviz.ecf -o /d/prod/docs%N")
			print ("  eiffel_graph_gen /d/prod/simple_json/simple_json.ecf -o .%N")
		end

	print_version
			-- Print version information.
		do
			print ("eiffel_graph_gen " + Version + "%N")
			print ("Eiffel Graph Generator CLI%N")
			print ("Part of the Simple Eiffel ecosystem%N")
		end

	print_error (a_message: STRING)
			-- Print error message.
		do
			print ("Error: " + a_message + "%N")
			log.error (a_message)
		end

feature {NONE} -- Implementation

	log: SIMPLE_LOGGER
			-- Application logger.

end
