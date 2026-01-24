# 7S-04: SIMPLE-STAR - simple_graphviz

**Document**: 7S-04-SIMPLE-STAR.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Ecosystem Integration

### Dependencies (Incoming)

| Library | Usage |
|---------|-------|
| mml | Model verification in contracts |

### Dependents (Outgoing)

| Library | Usage |
|---------|-------|
| simple_oracle | Visualization features |
| Documentation tools | Diagram generation |

### Integration Patterns

1. **Basic Graph Pattern**
```eiffel
local
    gv: SIMPLE_GRAPHVIZ
    graph: DOT_GRAPH
    result: GRAPHVIZ_RESULT
do
    create gv.make
    graph := gv.graph
    graph.new_node ("A").attributes.put ("label", "Start")
    graph.new_node ("B").attributes.put ("label", "End")
    graph.new_edge ("A", "B")
    result := gv.render_svg (graph.to_dot)
end
```

2. **Flowchart Builder Pattern**
```eiffel
local
    gv: SIMPLE_GRAPHVIZ
    fc: FLOWCHART_BUILDER
do
    create gv.make
    fc := gv.flowchart
    fc.start ("Begin")
       .process ("Do Work")
       .decision ("Done?", "Yes", "No")
       .end_node ("Finish")
    -- Render
    fc.to_svg_file ("flowchart.svg")
end
```

3. **BON Diagram Pattern**
```eiffel
local
    gv: SIMPLE_GRAPHVIZ
    bon: BON_DIAGRAM_BUILDER
do
    create gv.make
    bon := gv.bon_diagram
    bon.add_class ("PARENT")
       .add_class ("CHILD")
       .add_inheritance ("CHILD", "PARENT")
end
```

### API Compatibility

- Follows simple_* naming conventions
- Uses MML for model verification
- Returns GRAPHVIZ_RESULT for operations
- Fluent-style builders
