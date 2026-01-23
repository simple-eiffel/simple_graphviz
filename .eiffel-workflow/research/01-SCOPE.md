# SCOPE: simple_graphviz

## Problem Statement
In one sentence: Eiffel developers lack a native library for programmatically generating BON (Business Object Notation) diagrams from code structure.

What's wrong today:
- EiffelStudio's diagram tool is IDE-bound, not programmatically accessible
- No simple_* library exists for generating GraphViz DOT output
- Creating BON diagrams manually is tedious and error-prone
- Existing Eiffel parser (simple_eiffel_parser) extracts structure but has no visualization output

Who experiences this:
- Eiffel library authors documenting their systems
- Teams needing automated architecture documentation
- CI/CD pipelines requiring diagram generation

Impact of not solving: Manual diagram creation, inconsistent documentation, stale diagrams

## Target Users
| User Type | Needs | Pain Level |
|-----------|-------|------------|
| Library Authors | Generate BON diagrams from source | HIGH |
| Documentation Teams | Automated SVG/PDF diagrams | MEDIUM |
| IDE Tools | Real-time class visualization | MEDIUM |
| CI/CD Systems | Automated documentation artifacts | LOW |

## Success Criteria
| Level | Criterion | Measure |
|-------|-----------|---------|
| MVP | Generate DOT from Eiffel class structure | Parse .e file, produce valid DOT |
| MVP | Render SVG via GraphViz | dot -Tsvg produces valid SVG |
| Full | BON-compliant visual notation | Ellipses, correct arrows, labels |
| Full | PDF export via simple_pdf | SVG-to-PDF rendering works |

## Scope Boundaries

### In Scope (MUST)
- DOT language generation for class diagrams
- Inheritance arrow representation
- Client-supplier relationship arrows
- Calling GraphViz `dot` executable via simple_process
- SVG output format

### In Scope (SHOULD)
- BON ellipse shapes for classes
- Deferred class visual distinction
- Cluster (package) grouping
- PDF rendering via simple_pdf HTML wrapper
- Class feature display (short form)

### Out of Scope
- Full BON dynamic diagrams (message sequences)
- GraphViz native library binding (use subprocess)
- Custom layout algorithms (use GraphViz's dot/neato)
- Interactive/animated diagrams
- Real-time IDE integration (future library concern)

### Deferred to Future
- AI-assisted layout optimization: complexity not justified for MVP
- ECF parsing for multi-library diagrams: use simple_eiffel_parser first
- PlantUML output: focus on GraphViz DOT first

## Constraints
| Type | Constraint |
|------|------------|
| Technical | GraphViz must be installed on system (external dependency) |
| Technical | Must use simple_process for subprocess (SCOOP-compatible) |
| Technical | Must use simple_eiffel_parser for code parsing |
| Ecosystem | Must prefer simple_* over ISE stdlib |
| Platform | Windows-primary (GraphViz available cross-platform) |

## Assumptions to Validate
| ID | Assumption | Risk if False |
|----|------------|---------------|
| A-1 | GraphViz `dot` accepts DOT via stdin | Need temp files instead |
| A-2 | simple_process can capture large SVG output | May need file-based approach |
| A-3 | simple_eiffel_parser extracts inheritance info | Need to add parser features |
| A-4 | HTML + embedded SVG works with simple_pdf | May need different approach |

## Research Questions
- What exact BON notation rules must DOT output follow?
- Can AI meaningfully assist with layout or diagram suggestions?
- How do other tools (EiffelStudio, EBON) handle BON generation?
- What's the performance impact of subprocess calls for large systems?
