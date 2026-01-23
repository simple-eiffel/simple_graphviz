# Changelog

All notable changes to simple_graphviz will be documented in this file.

## [1.0.0] - 2026-01-22

### Added

- **Core DOT Classes**
  - `DOT_GRAPH`: Directed and undirected graph structures
  - `DOT_NODE`: Node elements with fluent attribute setters
  - `DOT_EDGE`: Edge elements with directed/undirected serialization
  - `DOT_SUBGRAPH`: Subgraph and cluster support
  - `DOT_ATTRIBUTES`: Key-value attributes with DOT escaping

- **Diagram Builders**
  - `BON_DIAGRAM_BUILDER`: BON class diagrams with styles
  - `FLOWCHART_BUILDER`: Flowcharts with auto-linking
  - `STATE_MACHINE_BUILDER`: State machines with transitions
  - `DEPENDENCY_BUILDER`: Dependency graphs with clusters
  - `INHERITANCE_BUILDER`: Inheritance tree diagrams

- **Rendering**
  - `GRAPHVIZ_RENDERER`: GraphViz subprocess execution
  - `GRAPHVIZ_RESULT`: Success/failure result with XOR invariant
  - `GRAPHVIZ_ERROR`: Error codes (not_found, timeout, invalid_dot, output_error)
  - Support for SVG, PDF, PNG output formats
  - Configurable timeout and layout engine

- **Facade**
  - `SIMPLE_GRAPHVIZ`: Main entry point with fluent API
  - Builder access methods
  - Direct render methods

- **Contracts**
  - MML model queries for all collections
  - Frame conditions using `|=|` operator
  - Full precondition/postcondition coverage

- **Tests**
  - 71 tests covering all functionality
  - Adversarial tests for edge cases
  - Stress tests for capacity limits
  - SCOOP compatibility test

### Notes

- Source parsing features (`from_file`, `from_directory`, `from_ecf`) are stub implementations pending simple_eiffel_parser integration
- GraphViz installation required for rendering (DOT generation works without it)
