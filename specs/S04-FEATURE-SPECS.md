# S04: FEATURE SPECS - simple_graphviz

**Document**: S04-FEATURE-SPECS.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## SIMPLE_GRAPHVIZ Features

### Configuration
| Feature | Signature | Description |
|---------|-----------|-------------|
| set_engine | (STRING): like Current | Set layout engine |
| set_timeout | (INTEGER): like Current | Set render timeout |

### Status Report
| Feature | Signature | Description |
|---------|-----------|-------------|
| is_graphviz_available | BOOLEAN | Is GraphViz installed? |
| graphviz_version | detachable STRING | Version string |

### Builder Access
| Feature | Signature | Description |
|---------|-----------|-------------|
| bon_diagram | BON_DIAGRAM_BUILDER | BON diagram builder |
| flowchart | FLOWCHART_BUILDER | Flowchart builder |
| state_machine | STATE_MACHINE_BUILDER | State machine builder |
| dependency_graph | DEPENDENCY_BUILDER | Dependency builder |
| inheritance_tree | INHERITANCE_BUILDER | Inheritance builder |
| graph | DOT_GRAPH | New directed graph |
| undirected_graph | DOT_GRAPH | New undirected graph |

### Rendering
| Feature | Signature | Description |
|---------|-----------|-------------|
| render_svg | (STRING): GRAPHVIZ_RESULT | Render to SVG |
| render_pdf | (STRING): GRAPHVIZ_RESULT | Render to PDF |
| render_png | (STRING): GRAPHVIZ_RESULT | Render to PNG |
| render_to_file | (STRING, STRING, STRING): GRAPHVIZ_RESULT | To file |

## DOT_GRAPH Features

### Access
| Feature | Signature | Description |
|---------|-----------|-------------|
| name | STRING | Graph name |
| is_directed | BOOLEAN | Is digraph? |
| node_count | INTEGER | Number of nodes |
| edge_count | INTEGER | Number of edges |
| node | (STRING): detachable DOT_NODE | Find node by ID |

### Element Change
| Feature | Signature | Description |
|---------|-----------|-------------|
| add_node | (DOT_NODE) | Add existing node |
| add_edge | (DOT_EDGE) | Add existing edge |
| new_node | (STRING): DOT_NODE | Create and add node |
| new_edge | (STRING, STRING): DOT_EDGE | Create and add edge |

### Attributes (Fluent)
| Feature | Signature | Description |
|---------|-----------|-------------|
| set_rankdir | (STRING): like Current | Layout direction |
| set_bgcolor | (STRING): like Current | Background color |
| set_splines | (STRING): like Current | Edge routing |

### Conversion
| Feature | Signature | Description |
|---------|-----------|-------------|
| to_dot | STRING | Generate DOT source |

## FLOWCHART_BUILDER Features

### Building (Fluent)
| Feature | Signature | Description |
|---------|-----------|-------------|
| start | (STRING): like Current | Add start node |
| end_node | (STRING): like Current | Add end node |
| process | (STRING): like Current | Add process node |
| decision | (STRING, STRING, STRING): like Current | Add decision |
| io_node | (STRING): like Current | Add I/O node |
| link | (STRING, STRING): like Current | Manual link |
| link_yes | (STRING): like Current | Yes branch |
| link_no | (STRING): like Current | No branch |

### Output
| Feature | Signature | Description |
|---------|-----------|-------------|
| to_dot | STRING | Generate DOT |
| to_svg | GRAPHVIZ_RESULT | Render SVG |
| to_svg_file | (STRING): GRAPHVIZ_RESULT | To SVG file |
