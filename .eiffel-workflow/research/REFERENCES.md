# REFERENCES: simple_graphviz

## Documentation Consulted

### GraphViz Official Documentation
- https://graphviz.org/doc/info/lang.html - DOT language syntax (graph types, nodes, edges, attributes, subgraphs)
- https://graphviz.org/doc/info/shapes.html - Node shapes including ellipse, box, record, HTML-like labels
- https://graphviz.org/download/ - Installation instructions for Windows, Linux, macOS
- https://graphviz.org/doc/info/command.html - Command line usage, stdin/stdout piping

### BON (Business Object Notation)
- https://en.wikipedia.org/wiki/Business_Object_Notation - BON history and overview (developed 1989-1993 by Nerson and Walden)
- http://www.bon-method.com/handbook_bon.pdf - Official BON handbook (PDF reference)
- http://www.cs.yorku.ca/~paige/Bon/bon.html - Introduction to BON notation (ellipses, arrows, relationships)

### EiffelStudio Tools
- https://www.eiffel.org/doc/eiffelstudio/Diagram_tool - EiffelStudio's BON diagram tool capabilities
- https://www.eiffel.org/doc/eiffel/ET-_Inheritance - Eiffel inheritance concepts

### Extended BON Tool Suite
- https://ebon.sourceforge.net/ - Java-based BON scanner, parser, documentation generator

## Library Documentation Consulted

### Python graphviz
- https://graphviz.readthedocs.io/en/stable/manual.html - User guide with pipe() method for subprocess rendering
- https://graphviz.readthedocs.io/en/stable/api.html - API reference for Graph/Digraph classes
- https://pypi.org/project/graphviz/ - Package overview

### TypeScript ts-graphviz
- https://ts-graphviz.github.io/docs/ts-graphviz/introduction/ - Type-safe DOT generation patterns

### Other Language Bindings
- https://hackage.haskell.org/package/graphviz - Haskell bindings (pattern reference)
- https://github.com/JuliaGraphs/GraphViz.jl - Julia bindings (pattern reference)
- https://github.com/pydot/pydot - Python pydot library

## AI and Diagram Tools
- https://diagrammingai.com - AI diagram generation with Graphviz support
- https://www.eraser.io/diagramgpt - AI-assisted diagram creation
- https://graphvizonline.net/ - Online GraphViz editor with AI suggestions

## Installation References
- https://winget.run/pkg/Graphviz/Graphviz - Windows Package Manager installation
- https://iotespresso.com/how-to-install-graphviz-on-windows/ - Step-by-step Windows installation

## simple_* Ecosystem (Local Documentation)
- /d/prod/simple_process/README.md - SCOOP-safe process execution, subprocess patterns
- /d/prod/simple_pdf/README.md - PDF generation via subprocess, bundled binaries pattern
- /d/prod/simple_eiffel_parser/README.md - Eiffel source parsing, AST structure
- /d/prod/simple_reflection/README.md - Runtime reflection capabilities
- /d/prod/simple_graph/README.md - Graph data structures (not DOT related)

## Search Queries Executed
1. "GraphViz DOT language library binding 2025" - Found bindings for multiple languages
2. "BON Business Object Notation Eiffel diagram tool" - Found EiffelStudio, EBON tools
3. "GraphViz SVG generation programmatic API" - Found subprocess piping patterns
4. "Eiffel language reflection class hierarchy extraction" - Found INTERNAL/REFLECTOR info
5. "GraphViz dot subprocess pipe stdin stdout SVG output" - Found pipe() patterns
6. "GraphViz Windows download install 2025" - Found installation methods
7. "BON Business Object Notation class diagram ellipse inheritance arrow syntax" - Found notation details
8. "AI assisted diagram layout optimization graph visualization" - Found AI tool landscape
9. "Eiffel class hierarchy visualization tool automatic" - Found EiffelStudio capabilities

## Key Insights from Research

### From GraphViz Documentation
- DOT language is stable and well-documented
- Subprocess piping is the recommended integration pattern
- HTML-like labels recommended over record shapes for complex nodes
- Multiple layout engines available (dot best for hierarchies)

### From BON Research
- Classes represented as ellipses (ovals), not rectangles like UML
- Inheritance arrows point from child to parent
- Three client-supplier relationship types: association, shared, aggregation
- Deferred classes have dashed borders
- BON is simpler than UML, designed specifically for Eiffel

### From simple_* Ecosystem
- simple_process handles subprocess safely for SCOOP
- simple_pdf bundles Windows binaries for zero-install experience
- simple_eiffel_parser extracts class structure, inheritance, features
- Fluent builder pattern used throughout ecosystem

### From AI Tools Research
- AI can assist with layout suggestions and error correction
- GraphViz's built-in layout algorithms are already sophisticated
- AI integration adds complexity without guaranteed benefit
- Deferred to future based on user demand
