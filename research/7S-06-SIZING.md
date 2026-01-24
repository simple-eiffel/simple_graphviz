# 7S-06: SIZING - simple_graphviz

**Document**: 7S-06-SIZING.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Implementation Size

### Source Metrics

| File | Lines | Purpose |
|------|-------|---------|
| simple_graphviz.e | 190 | Main facade |
| dot_graph.e | 390 | Graph structure |
| dot_node.e | 100 | Node representation |
| dot_edge.e | 80 | Edge representation |
| dot_subgraph.e | 120 | Subgraph support |
| dot_attributes.e | 150 | Attribute handling |
| graphviz_renderer.e | 470 | C library interface |
| graphviz_result.e | 80 | Operation results |
| graphviz_error.e | 60 | Error types |
| graphviz_style.e | 100 | Style presets |
| flowchart_builder.e | 290 | Flowchart builder |
| state_machine_builder.e | 200 | State machine builder |
| dependency_builder.e | 150 | Dependency builder |
| inheritance_builder.e | 150 | Inheritance builder |
| bon_diagram_builder.e | 200 | BON diagram builder |
| graphviz_cli.e | 100 | CLI support |
| ecf_parser.e | 150 | ECF parsing for graphs |
| physics_post_processor.e | 200 | Layout constraints |
| **Total** | ~3,200 | Core library |

### Complexity Assessment

| Component | Complexity | Rationale |
|-----------|------------|-----------|
| DOT_GRAPH | Medium | Graph data structure |
| GRAPHVIZ_RENDERER | High | Inline C, error handling |
| Builders | Low | Fluent wrappers |
| Post-processor | Medium | Physics simulation |

### Development Effort

- **Core Implementation**: 40 hours
- **Builders**: 16 hours
- **Testing**: 16 hours
- **Documentation**: 8 hours
- **Total**: ~80 hours

### Binary Impact

| Target | Size Impact |
|--------|-------------|
| Executable | +200 KB |
| GraphViz dependency | ~50 MB installed |
