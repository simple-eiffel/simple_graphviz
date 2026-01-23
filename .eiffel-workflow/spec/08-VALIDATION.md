# DESIGN VALIDATION: simple_graphviz

## OOSC2 Compliance

| Principle | Status | Evidence |
|-----------|--------|----------|
| Single Responsibility | ✓ | Each class has one job: DOT_NODE holds node data, GRAPHVIZ_RENDERER handles subprocess, BON_DIAGRAM_BUILDER converts AST |
| Open/Closed | ✓ | GRAPHVIZ_STYLE presets allow extension without modifying core; new styles can be added |
| Liskov Substitution | ✓ | No inheritance hierarchy in MVP - all concrete classes |
| Interface Segregation | ✓ | Focused interfaces: DOT classes for structure, renderer for execution, builder for conversion |
| Dependency Inversion | ✓ | Facade depends on abstractions (builder, renderer); low-level classes independent |

## Eiffel Excellence

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Command-Query Separation | ✓ | Queries (to_dot, is_available) don't modify; Commands (add_node) modify; Builder pattern uses like Current for chaining |
| Uniform Access | ✓ | Attributes (name, engine) and queries (is_available, version) interchangeable |
| Design by Contract | ✓ | Full contracts on all features: preconditions for validity, postconditions for effects, invariants for class state |
| Genericity | ✓ | Not needed in MVP - domain-specific types throughout |
| Inheritance | ✓ | No inheritance - all concrete; designed for future extension via GRAPHVIZ_STYLE variants |
| Information Hiding | ✓ | Implementation details (process, builder internals) hidden; public API minimal |

## Practical Quality

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Void-safe | ✓ | detachable used for optional results (to_svg, last_error, version); attached checks required |
| SCOOP-compatible | ✓ | Uses simple_process SCOOP-safe subprocess; no threading |
| simple_* first | ✓ | Dependencies: simple_eiffel_parser, simple_process, simple_file, simple_pdf - all simple_* |
| MML postconditions | ✓ | Frame conditions defined for collections (nodes_model, items_model) |
| Testable | ✓ | Each class independently testable; DOT generation testable without GraphViz; integration tests need GraphViz |

## Requirements Traceability

| Requirement | Addressed By | Status |
|-------------|--------------|--------|
| FR-001: Generate DOT | DOT_GRAPH.to_dot | ✓ |
| FR-002: BON ellipses | GRAPHVIZ_STYLE.make_bon, apply_to_class_node | ✓ |
| FR-003: Inheritance arrows | BON_DIAGRAM_BUILDER.add_inheritance_edges | ✓ |
| FR-004: Client-supplier arrows | GRAPHVIZ_STYLE.apply_to_client_edge (manual in v1) | ✓ |
| FR-005: Render SVG | GRAPHVIZ_RENDERER.render_svg | ✓ |
| FR-006: Parse Eiffel files | SIMPLE_GRAPHVIZ.from_file via simple_eiffel_parser | ✓ |
| FR-007: Deferred notation | GRAPHVIZ_STYLE (dashed border) | ✓ |
| FR-008: Expanded notation | GRAPHVIZ_STYLE (gray fill) | ✓ |
| FR-009: Display features | BON_DIAGRAM_BUILDER.set_include_features | ✓ |
| FR-010: Cluster grouping | DOT_SUBGRAPH | ✓ |
| FR-011: PDF export | GRAPHVIZ_RENDERER.render_pdf, SIMPLE_GRAPHVIZ.to_pdf_file | ✓ |
| FR-012: Configurable styles | GRAPHVIZ_STYLE presets | ✓ |
| FR-015: GraphViz detection | GRAPHVIZ_RENDERER.is_available | ✓ |
| NFR-001: SCOOP-compatible | simple_process SCOOP-safe | ✓ |
| NFR-002: Subprocess safe | Timeout, file-based fallback | ✓ |
| NFR-003: 100+ classes | Tested during implementation | Pending |
| NFR-004: Clean API | <20 public features per class | ✓ |
| NFR-005: Full DBC | All features contracted | ✓ |

## Risk Mitigations Implemented

| Risk | Mitigation in Design |
|------|---------------------|
| RISK-001: GraphViz not installed | `is_graphviz_available` query, `version` query for diagnostics |
| RISK-002: Large SVG buffer | `set_use_file_io` option, file-based rendering path |
| RISK-003: Parser gaps | Verified parser API - all needed info available |
| RISK-004: DOT escaping | `DOT_ATTRIBUTES.escape_value` utility |
| RISK-006: Subprocess hangs | `timeout` configuration, simple_process timeout |
| RISK-007: Path issues | Using simple_file for all file operations |

## Open Issues

1. **stdin piping** - Need to verify simple_process supports stdin piping; fallback is file-based I/O
2. **Large output buffering** - Need to test with 100+ class diagrams; file-based fallback designed
3. **SVG in simple_pdf** - Need to test embedded SVG rendering; direct PDF fallback available

## Verification Checklist

- [x] All requirements traced to design elements
- [x] All risks have mitigations in design
- [x] OOSC2 principles satisfied
- [x] Eiffel excellence criteria met
- [x] 10 classes designed with contracts
- [x] Dependencies confirmed (all simple_* except ISE base)
- [x] File structure defined

## Class Count

| Category | Classes | Description |
|----------|---------|-------------|
| Facade | 1 | SIMPLE_GRAPHVIZ |
| DOT AST | 5 | DOT_GRAPH, DOT_NODE, DOT_EDGE, DOT_SUBGRAPH, DOT_ATTRIBUTES |
| Engine | 2 | GRAPHVIZ_RENDERER, GRAPHVIZ_RESULT |
| Config | 1 | GRAPHVIZ_STYLE |
| Adapter | 1 | BON_DIAGRAM_BUILDER |
| **Total** | **10** | |

## Test Classes (Planned)

| Test Class | Tests | Description |
|------------|-------|-------------|
| TEST_DOT_GRAPH | 8 | Graph structure, serialization |
| TEST_DOT_NODE | 5 | Node attributes, escaping |
| TEST_DOT_EDGE | 4 | Edge serialization |
| TEST_GRAPHVIZ_RENDERER | 6 | Availability, rendering |
| TEST_BON_BUILDER | 5 | AST conversion |
| TEST_SIMPLE_GRAPHVIZ | 7 | Integration, fluent API |
| **Total** | **35** | |

**VERDICT:** READY FOR IMPLEMENTATION

The design is complete, all requirements are traced, risks are mitigated, and the architecture follows OOSC2 principles and Eiffel best practices. Ready to proceed with `/eiffel.intent` to capture detailed intent and contracts.
