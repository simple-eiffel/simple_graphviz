# simple_graphviz Demo Suite

20 real-world demonstration inputs showing various diagram types rendered to SVG, PNG, and PDF.

## Quick Start

```bash
# Render all demos to SVG
./render_all.sh svg

# Render all demos to PNG
./render_all.sh png

# Render all demos to PDF
./render_all.sh pdf

# Render a specific demo
simple_graphviz render inputs/01_simple_inheritance.dot -o outputs/01_simple_inheritance.svg
```

## Demo Catalog

| # | Name | Description | Engine | CLI Command |
|---|------|-------------|--------|-------------|
| 01 | Simple Inheritance | Class hierarchy (Animal/Dog/Cat) | dot | `simple_graphviz render inputs/01_simple_inheritance.dot -o outputs/01_simple_inheritance.svg` |
| 02 | Eiffel Class Hierarchy | ANY class inheritance tree | dot | `simple_graphviz render inputs/02_eiffel_class_hierarchy.dot -o outputs/02_eiffel_class_hierarchy.svg` |
| 03 | Microservices Architecture | Service clusters with data layer | dot | `simple_graphviz render inputs/03_microservices_architecture.dot -o outputs/03_microservices_architecture.svg` |
| 04 | Database Schema | Entity-relationship diagram | dot | `simple_graphviz render inputs/04_database_schema.dot -o outputs/04_database_schema.svg` |
| 05 | Traffic Light FSM | Simple state machine | dot | `simple_graphviz render inputs/05_traffic_light_fsm.dot -o outputs/05_traffic_light_fsm.svg` |
| 06 | Order Processing FSM | E-commerce order lifecycle | dot | `simple_graphviz render inputs/06_order_processing_fsm.dot -o outputs/06_order_processing_fsm.svg` |
| 07 | Login Flowchart | User authentication flow | dot | `simple_graphviz render inputs/07_login_flowchart.dot -o outputs/07_login_flowchart.svg` |
| 08 | CI/CD Pipeline | Continuous integration flow | dot | `simple_graphviz render inputs/08_cicd_pipeline.dot -o outputs/08_cicd_pipeline.svg` |
| 09 | Network Topology | LAN with servers and workstations | neato | `simple_graphviz render inputs/09_network_topology.dot -o outputs/09_network_topology.svg -e neato` |
| 10 | Library Dependencies | Simple Eiffel ecosystem deps | dot | `simple_graphviz render inputs/10_library_dependencies.dot -o outputs/10_library_dependencies.svg` |
| 11 | Organization Chart | Company hierarchy | dot | `simple_graphviz render inputs/11_org_chart.dot -o outputs/11_org_chart.svg` |
| 12 | Decision Tree | Bug triage priority flow | dot | `simple_graphviz render inputs/12_decision_tree.dot -o outputs/12_decision_tree.svg` |
| 13 | Git Branching | GitFlow strategy visualization | dot | `simple_graphviz render inputs/13_git_branching.dot -o outputs/13_git_branching.svg` |
| 14 | API Request Flow | REST API sequence | dot | `simple_graphviz render inputs/14_api_sequence.dot -o outputs/14_api_sequence.svg` |
| 15 | Data Pipeline | ETL processing workflow | dot | `simple_graphviz render inputs/15_data_pipeline.dot -o outputs/15_data_pipeline.svg` |
| 16 | Sorting Algorithm | QuickSort flowchart | dot | `simple_graphviz render inputs/16_sorting_algorithm.dot -o outputs/16_sorting_algorithm.svg` |
| 17 | Regex Automaton | DFA for pattern a(b|c)*d | dot | `simple_graphviz render inputs/17_regex_automaton.dot -o outputs/17_regex_automaton.svg` |
| 18 | Mind Map | Project planning radial | twopi | `simple_graphviz render inputs/18_mind_map.dot -o outputs/18_mind_map.svg -e twopi` |
| 19 | Component Diagram | Software architecture layers | dot | `simple_graphviz render inputs/19_component_diagram.dot -o outputs/19_component_diagram.svg` |
| 20 | BON Design Pattern | Observer pattern in Eiffel BON | dot | `simple_graphviz render inputs/20_bon_eiffel_design.dot -o outputs/20_bon_eiffel_design.svg` |

## Output Formats

### SVG (Scalable Vector Graphics)
- Best for web and interactive display
- Infinite zoom without quality loss
- Searchable text
- Can be edited in vector tools

```bash
simple_graphviz render input.dot -o output.svg -f svg
```

### PNG (Portable Network Graphics)
- Best for documents and presentations
- Fixed resolution
- Universal compatibility
- Smaller file size for simple diagrams

```bash
simple_graphviz render input.dot -o output.png -f png
```

### PDF (Portable Document Format)
- Best for print and archival
- Vector quality preserved
- Multi-page support (for large diagrams)
- Professional distribution

```bash
simple_graphviz render input.dot -o output.pdf -f pdf
```

## Layout Engines

| Engine | Best For | Example |
|--------|----------|---------|
| `dot` | Hierarchical (default) - class diagrams, org charts, flowcharts | `-e dot` |
| `neato` | Spring model - network topologies, undirected graphs | `-e neato` |
| `fdp` | Force-directed - large undirected graphs | `-e fdp` |
| `circo` | Circular layouts - cyclic structures | `-e circo` |
| `twopi` | Radial layouts - mind maps, hierarchies from center | `-e twopi` |
| `osage` | Clustered graphs - grouped components | `-e osage` |
| `sfdp` | Scalable force-directed - very large graphs | `-e sfdp` |

## Diagram Types Demonstrated

### Class Diagrams (01, 02, 20)
UML-style class boxes with attributes and methods, inheritance arrows.

### State Machines (05, 06)
States as nodes, transitions as labeled edges, start/end markers.

### Flowcharts (07, 08, 16)
Process boxes, decision diamonds, flow arrows.

### Architecture Diagrams (03, 09, 19)
Components, services, connections with clusters for grouping.

### Data Models (04)
Entity boxes with fields, relationship lines with cardinality.

### Dependency Graphs (10)
Libraries as boxes, dependencies as directed edges.

### Organizational (11)
Hierarchy tree with role labels.

### Decision Trees (12)
Question diamonds, outcome leaves.

### Workflow (14, 15)
Sequential processing steps with branches.

### Automata (17)
States as circles, transitions with input labels.

### Mind Maps (18)
Central topic with radial branches.

## File Validation

After rendering, the test suite verifies:

| Format | Validation |
|--------|------------|
| SVG | Contains `<svg` or `<?xml` header |
| PNG | Starts with PNG magic bytes (‰PNG) |
| PDF | Starts with `%PDF-` header |

## Running Tests

```bash
# Compile test suite
cd /d/prod/simple_graphviz
/d/prod/ec.sh -batch -config simple_graphviz.ecf -target simple_graphviz_tests -c_compile

# Run rendering demo tests
./EIFGENs/simple_graphviz_tests/W_code/simple_graphviz.exe
```

The test suite includes:
- `test_render_all_svg` - Renders all 20 demos to SVG
- `test_render_all_png` - Renders all 20 demos to PNG
- `test_render_all_pdf` - Renders all 20 demos to PDF
- 20 individual tests (one per demo with specific engine)
