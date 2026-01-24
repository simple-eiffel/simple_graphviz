# 7S-01: SCOPE - simple_graphviz

**Document**: 7S-01-SCOPE.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Problem Domain

simple_graphviz provides GraphViz diagram generation capabilities for Eiffel applications:

1. **DOT Graph Building** - Fluent API for constructing DOT graphs
2. **Diagram Builders** - Specialized builders for common diagram types
3. **Rendering** - Direct rendering via GraphViz C library
4. **Multiple Outputs** - SVG, PDF, PNG generation

## Target Users

- **Documentation Authors**: Creating class diagrams, flowcharts
- **Visualization Tools**: Generating dependency graphs
- **Eiffel Ecosystem Tools**: BON diagrams, inheritance trees
- **Report Generators**: Embedding diagrams in reports

## Boundaries

### In Scope
- DOT graph construction (nodes, edges, subgraphs)
- Attribute management (colors, shapes, labels)
- Layout engines (dot, neato, fdp, circo, twopi)
- Output formats (SVG, PDF, PNG)
- Specialized builders (flowcharts, state machines, BON)
- Physics post-processing for layout constraints

### Out of Scope
- Graph algorithms (traversal, shortest path)
- Interactive editing
- Animation
- Real-time updates

## Dependencies

- GraphViz C library (gvc.h, cgraph.h)
- EiffelStudio inline C externals

## Integration Points

- SIMPLE_GRAPHVIZ facade for easy access
- GRAPHVIZ_RENDERER for rendering
- DOT_GRAPH for programmatic construction
- Various builders for specific diagram types
