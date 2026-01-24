# S02: CLASS CATALOG - simple_graphviz

**Document**: S02-CLASS-CATALOG.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Core Classes

| Class | Type | Description |
|-------|------|-------------|
| SIMPLE_GRAPHVIZ | Effective | Main facade for diagram generation |
| DOT_GRAPH | Effective | Complete DOT graph structure |
| DOT_NODE | Effective | Graph node with attributes |
| DOT_EDGE | Effective | Graph edge with attributes |
| DOT_SUBGRAPH | Effective | Subgraph/cluster support |
| DOT_ATTRIBUTES | Effective | Attribute collection and escaping |
| GRAPHVIZ_RENDERER | Effective | C library interface |
| GRAPHVIZ_RESULT | Effective | Operation result |
| GRAPHVIZ_ERROR | Effective | Error with code and message |
| GRAPHVIZ_STYLE | Effective | Style presets |

## Builder Classes

| Class | Type | Description |
|-------|------|-------------|
| FLOWCHART_BUILDER | Effective | Flowchart diagrams |
| STATE_MACHINE_BUILDER | Effective | State machine diagrams |
| DEPENDENCY_BUILDER | Effective | Dependency graphs |
| INHERITANCE_BUILDER | Effective | Inheritance trees |
| BON_DIAGRAM_BUILDER | Effective | BON-style class diagrams |
| CONTRACT_COVERAGE_BUILDER | Effective | Contract visualization |

## Utility Classes

| Class | Type | Description |
|-------|------|-------------|
| GRAPHVIZ_CLI | Effective | Command-line support |
| GRAPHVIZ_PAGE_SIZER | Effective | Page size calculations |
| ECF_PARSER | Effective | ECF file parsing |
| EIFFEL_GRAPH_GENERATOR | Effective | Eiffel-specific graphs |
| PHYSICS_POST_PROCESSOR | Effective | Layout constraints |
| GRAPH_GEN_CLI | Effective | Graph generation CLI |

## Inheritance Hierarchy

```
SIMPLE_GRAPHVIZ
    uses GRAPHVIZ_RENDERER
    creates DOT_GRAPH
    creates *_BUILDER classes

DOT_GRAPH
    contains DOT_NODE
    contains DOT_EDGE
    contains DOT_SUBGRAPH
    uses DOT_ATTRIBUTES

*_BUILDER
    uses DOT_GRAPH
    uses GRAPHVIZ_RENDERER
```
