# PARSED REQUIREMENTS: simple_graphviz

## Problem Summary
Eiffel developers lack a native library for programmatically generating BON (Business Object Notation) diagrams from code structure. EiffelStudio's diagram tool is IDE-bound, creating BON diagrams manually is tedious, and simple_eiffel_parser extracts structure but has no visualization output.

## Scope

### In Scope
- DOT language generation for class diagrams
- Inheritance arrow representation (child -> parent)
- Client-supplier relationship arrows
- Calling GraphViz `dot` executable via simple_process
- SVG output format
- BON ellipse shapes for classes
- Deferred/expanded class visual distinction
- Cluster (package) grouping
- PDF rendering via simple_pdf HTML wrapper
- Class feature display (short form)
- Configurable diagram styles

### Out of Scope
- Full BON dynamic diagrams (message sequences)
- GraphViz native library binding (subprocess only)
- Custom layout algorithms (use GraphViz's dot/neato)
- Interactive/animated diagrams
- Real-time IDE integration
- AI-assisted layout optimization (deferred)
- PlantUML output

## Functional Requirements

| ID | Requirement | Priority | Source | Acceptance |
|----|-------------|----------|--------|------------|
| FR-001 | Generate DOT language from class data | MUST | research/03 | Valid DOT accepted by `dot` command |
| FR-002 | Represent classes as BON ellipses | MUST | research/03 | shape=ellipse with class name |
| FR-003 | Represent inheritance arrows | MUST | research/03 | Directed edge from child to parent |
| FR-004 | Represent client-supplier arrows | SHOULD | research/03 | Directed edge with different style |
| FR-005 | Render DOT to SVG | MUST | research/03 | `dot -Tsvg` produces valid SVG |
| FR-006 | Parse Eiffel files for class structure | MUST | research/03 | Extract class name, parents, features |
| FR-007 | Support deferred class notation | SHOULD | research/03 | Dashed border for deferred |
| FR-008 | Support expanded class notation | SHOULD | research/03 | Gray fill for expanded |
| FR-009 | Display class features | SHOULD | research/03 | Attributes and routines in label |
| FR-010 | Support cluster grouping | SHOULD | research/03 | GraphViz subgraph |
| FR-011 | Export to PDF | SHOULD | research/03 | Via simple_pdf or dot -Tpdf |
| FR-012 | Configurable diagram styles | SHOULD | research/03 | Colors, fonts, shapes |
| FR-013 | Generate from directory tree | COULD | research/03 | Process all .e files |
| FR-014 | Filter classes by pattern | COULD | research/03 | Include/exclude by name |
| FR-015 | Detect GraphViz availability | MUST | research/06 | is_graphviz_available query |

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-------------|----------|---------|--------|
| NFR-001 | SCOOP-compatible | COMPATIBILITY | Compile with scoop | Yes |
| NFR-002 | Subprocess execution safe | RELIABILITY | No hangs/crashes | 99.9% |
| NFR-003 | Process large codebases | PERFORMANCE | 100+ classes | < 30 seconds |
| NFR-004 | Clean API surface | USABILITY | Public features | < 20 per class |
| NFR-005 | Full DBC contracts | QUALITY | Pre/postconditions | 100% coverage |
| NFR-006 | Cross-platform rendering | PORTABILITY | Windows + GraphViz | Required |
| NFR-007 | Minimal dependencies | MAINTAINABILITY | simple_* libs | 4-5 max |

## Constraints (simple_* First)

| ID | Constraint | Type |
|----|------------|------|
| C-001 | Must use simple_* over ISE/Gobo where available | ECOSYSTEM |
| C-002 | Must be SCOOP-compatible | TECHNICAL |
| C-003 | Must be void-safe | TECHNICAL |
| C-004 | Use simple_eiffel_parser for parsing | ECOSYSTEM |
| C-005 | Use simple_process for subprocess | ECOSYSTEM |
| C-006 | GraphViz external dependency | TECHNICAL |

## Decisions Already Made

| ID | Decision | Rationale | From |
|----|----------|-----------|------|
| D-001 | Subprocess via simple_process | Proven pattern, GraphViz handles layout | research/04 |
| D-002 | Parse source via simple_eiffel_parser | Design-time notation, no compilation needed | research/04 |
| D-003 | Structured DOT builder (AST) | Type-safe, composable, testable | research/04 |
| D-004 | BON-inspired with flexibility | BON defaults, user can customize | research/04 |
| D-005 | Both PDF export paths | dot -Tpdf for simple, simple_pdf for complex | research/04 |
| D-006 | Defer AI integration | GraphViz layout excellent, no clear value | research/04 |
| D-007 | Layered architecture with facade | Separation of concerns, matches simple_pdf | research/04 |

## Innovations to Implement

| ID | Innovation | Design Impact |
|----|------------|---------------|
| I-001 | First Native Eiffel GraphViz Library | Establishes patterns for visualization |
| I-002 | BON Notation as First-Class | Style presets system |
| I-003 | simple_eiffel_parser Integration | Direct AST-to-diagram pipeline |
| I-004 | SCOOP-Safe Subprocess Pattern | Uses simple_process Win32 wrapper |
| I-005 | Dual PDF Export Paths | Two render paths, user choice |

## Risks to Address in Design

| ID | Risk | Mitigation Strategy |
|----|------|---------------------|
| RISK-001 | GraphViz not installed | `is_graphviz_available` query, clear docs |
| RISK-002 | Large SVG buffer overflow | File-based output fallback |
| RISK-003 | Parser capability gaps | Verified: parser has all needed info |
| RISK-004 | DOT escaping bugs | Robust escape_dot_string function, tests |
| RISK-006 | Subprocess hangs | Timeout parameter (default 30s) |
| RISK-007 | Cross-platform paths | Use simple_file for all paths |

## Use Cases

### UC-001: Generate BON Diagram from Single File
**Actor:** Eiffel Developer
**Precondition:** .e file exists, GraphViz installed
**Main Flow:**
1. Developer creates SIMPLE_GRAPHVIZ
2. Developer calls `from_file ("my_class.e")`
3. Developer calls `to_svg` to get SVG string
4. Developer saves SVG to file
**Postcondition:** Valid SVG diagram exists

### UC-002: Generate Inheritance Diagram from Directory
**Actor:** Documentation Team
**Precondition:** Directory with .e files exists
**Main Flow:**
1. Developer creates SIMPLE_GRAPHVIZ
2. Developer calls `from_directory ("src/")`
3. Developer calls `style_bon` for BON notation
4. Developer calls `to_pdf_file ("diagram.pdf")`
**Postcondition:** PDF with class hierarchy exists

### UC-003: Low-Level DOT Building
**Actor:** Advanced User
**Precondition:** User knows DOT language
**Main Flow:**
1. User creates DOT_GRAPH with `make_digraph ("MyDiagram")`
2. User calls `add_node` for each class
3. User calls `add_edge` for relationships
4. User calls `render_svg` via GRAPHVIZ_RENDERER
**Postcondition:** Custom DOT diagram rendered

### UC-004: Check GraphViz Availability
**Actor:** Application
**Precondition:** None
**Main Flow:**
1. Create GRAPHVIZ_RENDERER
2. Query `is_available`
3. If false, show installation instructions
**Postcondition:** User informed of GraphViz status
