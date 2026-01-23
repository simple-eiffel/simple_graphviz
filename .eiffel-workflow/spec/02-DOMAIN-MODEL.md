# DOMAIN MODEL: simple_graphviz

## Domain Concepts

### Concept: Graph
**Definition:** A directed graph representing class relationships
**Attributes:** name, nodes, edges, subgraphs, global attributes
**Behaviors:** Add nodes, add edges, serialize to DOT
**Related to:** Node, Edge, Subgraph
**Will become:** DOT_GRAPH

### Concept: Node
**Definition:** A vertex in the graph representing a class
**Attributes:** id, label, shape, style, color, fill color
**Behaviors:** Serialize to DOT, set attributes
**Related to:** Graph, Edge
**Will become:** DOT_NODE

### Concept: Edge
**Definition:** A connection between two nodes (relationship)
**Attributes:** from_id, to_id, style, arrowhead, label
**Behaviors:** Serialize to DOT, set attributes
**Related to:** Graph, Node
**Will become:** DOT_EDGE

### Concept: Subgraph (Cluster)
**Definition:** A logical grouping of nodes (package/cluster)
**Attributes:** name, label, nodes, style
**Behaviors:** Add nodes, serialize to DOT
**Related to:** Graph, Node
**Will become:** DOT_SUBGRAPH

### Concept: Renderer
**Definition:** Engine that converts DOT to output format
**Attributes:** command path, timeout, output format
**Behaviors:** Check availability, render DOT, capture output
**Related to:** Graph
**Will become:** GRAPHVIZ_RENDERER

### Concept: Style Preset
**Definition:** Collection of visual attributes for consistent notation
**Attributes:** class shape, colors, arrow styles, fonts
**Behaviors:** Apply to node, apply to edge
**Related to:** Node, Edge
**Will become:** GRAPHVIZ_STYLE

### Concept: BON Diagram Builder
**Definition:** Adapter converting Eiffel AST to DOT graph
**Attributes:** parser, style, options (include features, etc.)
**Behaviors:** Build from AST, build from files
**Related to:** Graph, Parser AST
**Will become:** BON_DIAGRAM_BUILDER

### Concept: Diagram Result
**Definition:** Output of rendering operation
**Attributes:** content (bytes/string), format, success flag, error
**Behaviors:** Save to file, get as string, get as base64
**Related to:** Renderer
**Will become:** GRAPHVIZ_RESULT

## Concept Relationships

```
                    ┌─────────────┐
                    │ SIMPLE_     │
                    │ GRAPHVIZ    │
                    │ (Facade)    │
                    └──────┬──────┘
                           │ uses
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ BON_DIAGRAM │ │ DOT_GRAPH   │ │ GRAPHVIZ_   │
    │ _BUILDER    │ │             │ │ RENDERER    │
    └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
           │               │               │
           │ uses          │ contains      │ produces
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ EIFFEL_AST  │ │ DOT_NODE    │ │ GRAPHVIZ_   │
    │ (parser)    │ │ DOT_EDGE    │ │ RESULT      │
    └─────────────┘ │ DOT_SUBGRAPH│ └─────────────┘
                    └─────────────┘
```

## Domain Rules

| Rule | Description | Enforcement |
|------|-------------|-------------|
| DR-001 | Node IDs must be unique within graph | Invariant on DOT_GRAPH |
| DR-002 | Edge endpoints must exist as nodes | Precondition on add_edge |
| DR-003 | Subgraph names must be unique | Precondition on add_subgraph |
| DR-004 | GraphViz must be available for rendering | Precondition on render |
| DR-005 | Inheritance arrows point child -> parent | BON_DIAGRAM_BUILDER logic |
| DR-006 | DOT strings must be properly escaped | DOT_NODE/DOT_EDGE logic |
| DR-007 | Cluster names must start with "cluster" | DOT syntax requirement |

## Glossary

| Term | Definition |
|------|------------|
| DOT | Graph description language used by GraphViz |
| BON | Business Object Notation - Eiffel's preferred class diagram notation |
| Node | A vertex in a graph, represents a class in BON diagrams |
| Edge | A connection between nodes, represents inheritance or client-supplier |
| Cluster | A subgraph with visual boundary, represents package grouping |
| Subgraph | DOT construct for grouping nodes |
| Digraph | Directed graph - edges have direction |
| Renderer | Component that converts DOT to visual output |
| Layout Engine | GraphViz algorithm (dot, neato, fdp, etc.) |
| SVG | Scalable Vector Graphics - XML-based vector image format |
| Ellipse | Oval shape used for classes in BON notation |
| Arrowhead | Visual style of edge endpoint (empty, vee, diamond) |
