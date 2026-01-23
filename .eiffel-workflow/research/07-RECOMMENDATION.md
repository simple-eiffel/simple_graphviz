# RECOMMENDATION: simple_graphviz

## Executive Summary
Build simple_graphviz as a new library for generating BON diagrams from Eiffel source code. The library will generate GraphViz DOT language, invoke the `dot` command for rendering, and produce SVG/PDF output. This fills a significant gap in the simple_* ecosystem with moderate development effort.

## Recommendation
**Action:** BUILD
**Confidence:** HIGH

## Rationale
1. **Clear Need:** No Eiffel library exists for programmatic diagram generation
2. **Ecosystem Fit:** Integrates perfectly with simple_eiffel_parser, simple_process, simple_pdf
3. **Proven Pattern:** Subprocess approach works well (simple_pdf precedent)
4. **External Heavy Lifting:** GraphViz handles complex layout algorithms
5. **Moderate Scope:** ~10 classes, well-defined requirements

## Proposed Approach

### Phase 1 (MVP)
Core DOT generation and SVG rendering:
- DOT_NODE, DOT_EDGE, DOT_GRAPH classes for DOT AST
- GRAPHVIZ_RENDERER for subprocess invocation
- Basic BON style defaults (ellipses, inheritance arrows)
- SVG output from DOT

### Phase 2 (Full)
Eiffel integration and enhanced output:
- BON_DIAGRAM_BUILDER integrating simple_eiffel_parser
- Client-supplier relationships
- Deferred/expanded class notation
- PDF export via simple_pdf
- Cluster/subgraph support

### Phase 3 (Polish)
Usability and documentation:
- SIMPLE_GRAPHVIZ facade with fluent API
- Style presets (BON, UML-like, minimal)
- Directory/project scanning
- Comprehensive test suite

## Key Features
1. **DOT Builder:** Type-safe DOT language generation with full contracts
2. **GraphViz Renderer:** SCOOP-safe subprocess via simple_process
3. **BON Notation:** First-class support for Eiffel's preferred notation
4. **Parser Integration:** One-command diagram from .e files
5. **Dual PDF Export:** Direct GraphViz and simple_pdf routes

## Success Criteria
- Generate valid DOT accepted by `dot` command
- Produce SVG diagrams from Eiffel source files
- BON-compliant class shapes and arrows
- Render 100+ class system in < 30 seconds
- Full Design by Contract coverage
- 20+ unit tests passing

## Dependencies
| Library | Purpose | simple_* Preferred |
|---------|---------|-------------------|
| simple_eiffel_parser | Parse .e files | YES (only option) |
| simple_process | Subprocess for `dot` | YES |
| simple_file | File I/O | YES |
| simple_pdf | PDF export | YES |
| base | Core data structures | ISE (no alternative) |

## Architecture Overview
```
┌─────────────────────────────────────────────────────────┐
│                   SIMPLE_GRAPHVIZ                       │
│                  (Facade - Fluent API)                  │
└─────────────────────────────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
┌─────────────────┐ ┌─────────────┐ ┌─────────────────┐
│ BON_DIAGRAM_    │ │ DOT_GRAPH   │ │ GRAPHVIZ_       │
│ BUILDER         │ │ DOT_NODE    │ │ RENDERER        │
│                 │ │ DOT_EDGE    │ │                 │
│ (Eiffel→DOT)    │ │ (DOT AST)   │ │ (subprocess)    │
└─────────────────┘ └─────────────┘ └─────────────────┘
        │                   │               │
        ▼                   │               ▼
┌─────────────────┐         │        ┌─────────────┐
│ simple_eiffel_  │         │        │ simple_     │
│ parser          │         │        │ process     │
└─────────────────┘         │        └─────────────┘
                            ▼
                   ┌─────────────────┐
                   │ GraphViz (dot)  │
                   │ [External]      │
                   └─────────────────┘
```

## Next Steps
1. Run `/eiffel.spec d:\prod\simple_graphviz` to transform this research into Eiffel specification
2. Then `/eiffel.intent` to capture refined intent with contracts
3. Continue with Eiffel Spec Kit workflow through implementation

## Open Questions
1. Should we bundle GraphViz Windows binaries like simple_pdf bundles wkhtmltopdf?
   - Pros: Zero-install experience
   - Cons: Large binary (~100MB), licensing considerations
   - **Tentative:** No bundling for v1.0; document installation

2. How much of the simple_eiffel_parser AST do we need to expose?
   - Verify parser exports class names, parent lists, feature lists, class modifiers
   - May need to review parser API surface

3. Should aggregation arrows (double-line) be supported in v1.0?
   - Requires analyzing attribute types for containment relationships
   - **Tentative:** Defer to v1.1; inheritance is primary relationship

## AI Integration (Deferred)

The original request mentioned potential AI integration. After research, the conclusion is:

**Defer AI to post-MVP** for these reasons:
1. GraphViz's layout algorithms are already excellent (dot, neato, fdp)
2. No clear value proposition for AI in diagram generation
3. Adds complexity and non-determinism
4. simple_ai_client dependency increases coupling

**Potential future AI uses (if revisited):**
- Suggesting class groupings for clusters
- Generating diagram descriptions/captions
- Recommending layout engine based on graph characteristics
- Auto-detecting important classes to highlight

**Trigger to revisit:** User feedback requesting smarter auto-organization; specific use case emerges.
