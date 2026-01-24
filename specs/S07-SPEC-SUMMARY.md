# S07: SPEC SUMMARY - simple_graphviz

**Document**: S07-SPEC-SUMMARY.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Executive Summary

simple_graphviz provides GraphViz diagram generation for Eiffel applications, with fluent API for graph construction and specialized builders for common diagram types.

## Key Components

| Component | Purpose | Status |
|-----------|---------|--------|
| SIMPLE_GRAPHVIZ | Main facade | Complete |
| DOT_GRAPH | Graph structure | Complete |
| GRAPHVIZ_RENDERER | C library interface | Complete |
| Builders | Specialized diagrams | Complete |

## Core Capabilities

- Construct DOT graphs programmatically
- Fluent API for easy construction
- Multiple layout engines
- SVG, PDF, PNG output
- Specialized builders for:
  - Flowcharts
  - State machines
  - Dependency graphs
  - Inheritance trees
  - BON diagrams

## API Highlights

```eiffel
-- Simple diagram
local
    gv: SIMPLE_GRAPHVIZ
    graph: DOT_GRAPH
do
    create gv.make
    graph := gv.graph
    graph.new_node ("A").attributes.put ("label", "Start")
    graph.new_node ("B").attributes.put ("label", "End")
    graph.new_edge ("A", "B")

    if attached gv.render_svg (graph.to_dot) as r and then r.is_success then
        -- r.content has SVG
    end
end

-- Flowchart builder
local
    fc: FLOWCHART_BUILDER
do
    create gv.make
    fc := gv.flowchart
    fc.start ("Begin")
       .process ("Work")
       .end_node ("Done")
       .to_svg_file ("flow.svg")
end
```

## Quality Attributes

- **Design by Contract**: Full preconditions/postconditions
- **MML Verification**: Model-based contracts
- **Fluent API**: Easy method chaining
- **Error Handling**: GRAPHVIZ_RESULT pattern

## Dependencies

- GraphViz C library (required)
- MML (for model verification)
