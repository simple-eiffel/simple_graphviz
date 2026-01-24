# S06: BOUNDARIES - simple_graphviz

**Document**: S06-BOUNDARIES.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## System Boundaries

```
+---------------------------------------------+
|              Application Layer              |
|    (Diagram generation code)                |
+---------------------------------------------+
                     |
                     v
+---------------------------------------------+
|             simple_graphviz                 |
|  +---------------+  +-------------------+   |
|  | SIMPLE_GRAPHVIZ| | DOT_GRAPH         |   |
|  | (facade)      | | DOT_NODE/EDGE     |   |
|  +---------------+  +-------------------+   |
|  +---------------+  +-------------------+   |
|  | *_BUILDER     | | GRAPHVIZ_RENDERER |   |
|  | (specialized)| | (C interface)     |   |
|  +---------------+  +-------------------+   |
+---------------------------------------------+
                     |
                     v (Inline C)
+---------------------------------------------+
|           GraphViz C Library                |
|    (gvc.h, cgraph.h)                        |
+---------------------------------------------+
                     |
                     v
+---------------------------------------------+
|           Output Files                      |
|    (SVG, PDF, PNG)                          |
+---------------------------------------------+
```

## Interface Boundaries

### Public API (Exported to ANY)

- SIMPLE_GRAPHVIZ: Main facade
- DOT_GRAPH, DOT_NODE, DOT_EDGE: Graph construction
- DOT_ATTRIBUTES: Attribute management
- All *_BUILDER classes: Specialized builders
- GRAPHVIZ_RESULT, GRAPHVIZ_ERROR: Results

### Internal Implementation

- GRAPHVIZ_RENDERER C externals
- Internal node/edge lists
- Post-processor internals

## Data Boundaries

### Input
- Graph structure (nodes, edges, attributes)
- DOT source strings
- Configuration parameters

### Output
- SVG content (STRING)
- PDF content (binary)
- PNG content (binary)
- GRAPHVIZ_RESULT with success/error

## Trust Boundaries

- Application constructs valid graphs
- simple_graphviz generates valid DOT
- GraphViz C library parses and renders
- Output files written by GraphViz
