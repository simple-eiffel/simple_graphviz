note
	description: "[
		Command-line interface for simple_graphviz.

		Usage:
		  simple_graphviz render <input.dot> -o <output> [-f <format>] [-e <engine>]
		  simple_graphviz template <type> -o <output.dot>
		  simple_graphviz version
		  simple_graphviz help

		Commands:
		  render    Render a DOT file to SVG/PDF/PNG
		  template  Generate a DOT template for a diagram type
		  version   Show version information
		  help      Show this help message

		Options:
		  -o, --output <file>   Output file path (required)
		  -f, --format <fmt>    Output format: svg, pdf, png (default: svg)
		  -e, --engine <eng>    Layout engine: dot, neato, fdp, circo, twopi (default: dot)
		  -t, --timeout <ms>    Render timeout in milliseconds (default: 30000)

		Template types:
		  bon          BON class diagram skeleton
		  flowchart    Flowchart skeleton
		  state        State machine skeleton
		  dependency   Dependency graph skeleton
		  inheritance  Inheritance tree skeleton

		Examples:
		  simple_graphviz render diagram.dot -o diagram.svg
		  simple_graphviz render diagram.dot -o diagram.png -f png -e neato
		  simple_graphviz template state -o fsm.dot
	]"
	author: "Larry Rix"
	date: "2026-01-22"

class
	GRAPHVIZ_CLI

create
	make

feature {NONE} -- Initialization

	make
			-- Run CLI application.
		local
			l_args: ARGUMENTS_32
		do
			-- Initialize logger FIRST (debug level, console + file)
			create log.make_with_level ({SIMPLE_LOGGER}.Level_debug)
			log.add_file_output ("simple_graphviz.log")
			log.info ("=== SIMPLE_GRAPHVIZ CLI STARTING ===")
			log.info ("Version: " + Version)
			log.info ("Log level: DEBUG")

			log.enter ("make")

			create l_args
			log.debug_log ("Argument count: " + l_args.argument_count.out)

			if l_args.argument_count < 1 then
				log.info ("No arguments provided, showing help")
				print_help
			else
				log.debug_log ("First argument: " + l_args.argument (1).to_string_8)
				process_command (l_args)
			end

			log.exit ("make")
			log.info ("=== SIMPLE_GRAPHVIZ CLI FINISHED ===")
		end

feature -- Constants

	Version: STRING = "1.0.0"
			-- Application version.

feature {NONE} -- Command Processing

	process_command (a_args: ARGUMENTS_32)
			-- Process command from arguments.
		local
			l_cmd: STRING_32
		do
			log.enter ("process_command")

			l_cmd := a_args.argument (1)

			if l_cmd.same_string ("help") or l_cmd.same_string ("--help") or l_cmd.same_string ("-h") then
				log.info ("Command: help")
				print_help
			elseif l_cmd.same_string ("version") or l_cmd.same_string ("--version") or l_cmd.same_string ("-v") then
				log.info ("Command: version")
				print_version
			elseif l_cmd.same_string ("render") then
				log.info ("Command: render")
				process_render (a_args)
			elseif l_cmd.same_string ("template") then
				log.info ("Command: template")
				process_template (a_args)
			else
				log.error ("Unknown command: " + l_cmd.to_string_8)
				print_error ("Unknown command: " + l_cmd.to_string_8)
				print_help
			end

			log.exit ("process_command")
		end

	process_render (a_args: ARGUMENTS_32)
			-- Process render command.
		local
			l_input, l_output, l_format, l_engine: detachable STRING
			l_timeout: INTEGER
			l_i: INTEGER
			l_arg: STRING_32
			l_renderer: GRAPHVIZ_RENDERER
			l_result: GRAPHVIZ_RESULT
			l_dot: STRING
			l_file: PLAIN_TEXT_FILE
			l_version: STRING
		do
			log.enter ("process_render")

			-- Defaults
			l_format := "svg"
			l_engine := "dot"
			l_timeout := 30_000

			-- Parse arguments
			from l_i := 2 until l_i > a_args.argument_count loop
				l_arg := a_args.argument (l_i)
				log.debug_log ("Parsing arg " + l_i.out + ": " + l_arg.to_string_8)

				if l_arg.same_string ("-o") or l_arg.same_string ("--output") then
					if l_i < a_args.argument_count then
						l_i := l_i + 1
						l_output := a_args.argument (l_i).to_string_8
						if attached l_output as lo then
							log.debug_log ("Output: " + lo)
						end
					end
				elseif l_arg.same_string ("-f") or l_arg.same_string ("--format") then
					if l_i < a_args.argument_count then
						l_i := l_i + 1
						l_format := a_args.argument (l_i).to_string_8
						if attached l_format as lf then
							log.debug_log ("Format: " + lf)
						end
					end
				elseif l_arg.same_string ("-e") or l_arg.same_string ("--engine") then
					if l_i < a_args.argument_count then
						l_i := l_i + 1
						l_engine := a_args.argument (l_i).to_string_8
						if attached l_engine as le then
							log.debug_log ("Engine: " + le)
						end
					end
				elseif l_arg.same_string ("-t") or l_arg.same_string ("--timeout") then
					if l_i < a_args.argument_count then
						l_i := l_i + 1
						l_timeout := a_args.argument (l_i).to_string_8.to_integer
						log.debug_log ("Timeout: " + l_timeout.out)
					end
				elseif l_input = Void then
					l_input := l_arg.to_string_8
					if attached l_input as li then
						log.debug_log ("Input: " + li)
					end
				end
				l_i := l_i + 1
			end

			-- Validate and execute
			if l_input = Void then
				log.error ("No input file specified")
				print_error ("No input file specified")
			elseif l_output = Void then
				log.error ("No output file specified (use -o)")
				print_error ("No output file specified (use -o)")
			elseif attached l_input as inp and attached l_output as outp and attached l_format as fmt and attached l_engine as eng then
				-- Read input file
				log.info ("Reading input file: " + inp)
				create l_file.make_with_name (inp)
				if not l_file.exists then
					log.error ("Input file not found: " + inp)
					print_error ("Input file not found: " + inp)
				else
					l_file.open_read
					create l_dot.make (l_file.count.to_integer_32)
					l_file.read_stream (l_file.count.to_integer_32)
					l_dot := l_file.last_string
					l_file.close
					log.debug_log ("Read " + l_dot.count.out + " bytes from input")

					-- Create renderer
					log.info ("Creating renderer with engine: " + eng + ", timeout: " + l_timeout.out)
					create l_renderer.make
					l_renderer := l_renderer.set_engine (eng)
					l_renderer := l_renderer.set_timeout (l_timeout)

					-- Check GraphViz availability
					if not l_renderer.is_graphviz_available then
						log.error ("GraphViz is not installed or not in PATH")
						print_error ("GraphViz is not installed or not in PATH")
						print ("Install GraphViz from https://graphviz.org/download/%N")
					else
						if attached l_renderer.graphviz_version as v then
							l_version := v
						else
							l_version := "unknown"
						end
						log.info ("GraphViz available, version: " + l_version)

						-- Render
						log.info ("Rendering to: " + outp + " (format: " + fmt + ")")
						l_result := l_renderer.render_to_file (l_dot, fmt, outp)

						if l_result.is_success then
							log.info ("Render successful: " + outp)
							print ("Rendered: " + outp + "%N")
						else
							if attached l_result.error as err then
								log.error ("Render failed: " + err.message)
								print_error (err.message)
							else
								log.error ("Render failed: unknown error")
								print_error ("Render failed")
							end
						end
					end
				end
			end

			log.exit ("process_render")
		end

	process_template (a_args: ARGUMENTS_32)
			-- Process template command.
		local
			l_type, l_output: detachable STRING
			l_i: INTEGER
			l_arg: STRING_32
			l_dot: STRING
			l_file: PLAIN_TEXT_FILE
		do
			log.enter ("process_template")

			-- Parse arguments
			from l_i := 2 until l_i > a_args.argument_count loop
				l_arg := a_args.argument (l_i)
				log.debug_log ("Parsing arg " + l_i.out + ": " + l_arg.to_string_8)

				if l_arg.same_string ("-o") or l_arg.same_string ("--output") then
					if l_i < a_args.argument_count then
						l_i := l_i + 1
						l_output := a_args.argument (l_i).to_string_8
						if attached l_output as lo then
							log.debug_log ("Output: " + lo)
						end
					end
				elseif l_type = Void then
					l_type := l_arg.to_string_8
					if attached l_type as lt then
						log.debug_log ("Type: " + lt)
					end
				end
				l_i := l_i + 1
			end

			-- Validate and execute
			if l_type = Void then
				log.error ("No template type specified")
				print_error ("No template type specified")
				print ("Available types: bon, flowchart, state, dependency, inheritance%N")
			elseif l_output = Void then
				log.error ("No output file specified (use -o)")
				print_error ("No output file specified (use -o)")
			elseif attached l_type as tp and attached l_output as outp then
				-- Generate template
				log.info ("Generating template: " + tp)
				l_dot := generate_template (tp)

				if l_dot.is_empty then
					log.error ("Unknown template type: " + tp)
					print_error ("Unknown template type: " + tp)
					print ("Available types: bon, flowchart, state, dependency, inheritance%N")
				else
					-- Write output
					log.info ("Writing template to: " + outp)
					create l_file.make_open_write (outp)
					l_file.put_string (l_dot)
					l_file.close
					log.info ("Template written successfully")
					print ("Template written: " + outp + "%N")
				end
			end

			log.exit ("process_template")
		end

feature {NONE} -- Template Generation

	generate_template (a_type: STRING): STRING
			-- Generate DOT template for `a_type`.
		local
			l_gv: SIMPLE_GRAPHVIZ
			l_bon: BON_DIAGRAM_BUILDER
			l_fc: FLOWCHART_BUILDER
			l_sm: STATE_MACHINE_BUILDER
			l_dep: DEPENDENCY_BUILDER
			l_inh: INHERITANCE_BUILDER
		do
			log.enter ("generate_template")
			log.debug_log ("Template type: " + a_type)

			create l_gv.make

			if a_type.same_string ("bon") then
				l_bon := l_gv.bon_diagram
				l_bon.add_class ("BASE_CLASS", True, False)
				l_bon.add_class ("CONCRETE_CLASS", False, False)
				l_bon.add_inheritance ("CONCRETE_CLASS", "BASE_CLASS")
				Result := l_bon.to_dot

			elseif a_type.same_string ("flowchart") then
				l_fc := l_gv.flowchart
				l_fc := l_fc.start ("Start")
					.process ("Process Step")
					.decision ("Condition?", "Yes", "No")
				Result := l_fc.to_dot

			elseif a_type.same_string ("state") then
				l_sm := l_gv.state_machine
				l_sm := l_sm.initial ("Idle")
					.state ("Active")
					.final ("Done")
					.transition ("Idle", "Active", "start")
					.transition ("Active", "Done", "finish")
				Result := l_sm.to_dot

			elseif a_type.same_string ("dependency") then
				l_dep := l_gv.dependency_graph
				l_dep.add_library ("my_library", False)
				l_dep.add_library ("base", True)
				l_dep.add_library ("external_lib", True)
				l_dep.add_dependency ("my_library", "base")
				l_dep.add_dependency ("my_library", "external_lib")
				Result := l_dep.to_dot

			elseif a_type.same_string ("inheritance") then
				l_inh := l_gv.inheritance_tree
				l_inh.add_class ("ANY")
				l_inh.add_inheritance ("COMPARABLE", "ANY")
				l_inh.add_inheritance ("NUMERIC", "ANY")
				l_inh.add_inheritance ("INTEGER", "COMPARABLE")
				l_inh.add_inheritance ("INTEGER", "NUMERIC")
				Result := l_inh.to_dot

			else
				Result := ""
			end

			log.debug_log ("Generated " + Result.count.out + " bytes")
			log.exit ("generate_template")
		end

feature {NONE} -- Output

	print_help
			-- Print help message.
		do
			log.enter ("print_help")
			print ("simple_graphviz " + Version + " - GraphViz CLI for Eiffel%N")
			print ("%N")
			print ("Usage:%N")
			print ("  simple_graphviz render <input.dot> -o <output> [-f <format>] [-e <engine>]%N")
			print ("  simple_graphviz template <type> -o <output.dot>%N")
			print ("  simple_graphviz version%N")
			print ("  simple_graphviz help%N")
			print ("%N")
			print ("Commands:%N")
			print ("  render    Render a DOT file to SVG/PDF/PNG%N")
			print ("  template  Generate a DOT template for a diagram type%N")
			print ("  version   Show version information%N")
			print ("  help      Show this help message%N")
			print ("%N")
			print ("Options:%N")
			print ("  -o, --output <file>   Output file path (required)%N")
			print ("  -f, --format <fmt>    Output format: svg, pdf, png (default: svg)%N")
			print ("  -e, --engine <eng>    Layout engine: dot, neato, fdp, circo, twopi (default: dot)%N")
			print ("  -t, --timeout <ms>    Render timeout in milliseconds (default: 30000)%N")
			print ("%N")
			print ("Template types:%N")
			print ("  bon          BON class diagram skeleton%N")
			print ("  flowchart    Flowchart skeleton%N")
			print ("  state        State machine skeleton%N")
			print ("  dependency   Dependency graph skeleton%N")
			print ("  inheritance  Inheritance tree skeleton%N")
			print ("%N")
			print ("Examples:%N")
			print ("  simple_graphviz render diagram.dot -o diagram.svg%N")
			print ("  simple_graphviz render diagram.dot -o diagram.png -f png -e neato%N")
			print ("  simple_graphviz template state -o fsm.dot%N")
			log.exit ("print_help")
		end

	print_version
			-- Print version information.
		do
			log.enter ("print_version")
			print ("simple_graphviz " + Version + "%N")
			print ("GraphViz CLI for Eiffel%N")
			print ("Part of the Simple Eiffel ecosystem%N")
			log.exit ("print_version")
		end

	print_error (a_message: STRING)
			-- Print error message.
		do
			print ("Error: " + a_message + "%N")
		end

feature {NONE} -- Implementation

	log: SIMPLE_LOGGER
			-- Application logger.

end
