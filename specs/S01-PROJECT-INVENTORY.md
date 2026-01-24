# S01: PROJECT INVENTORY - simple_graphviz

**Document**: S01-PROJECT-INVENTORY.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Project Structure

```
simple_graphviz/
├── src/
│   ├── simple_graphviz.e       -- Main facade
│   ├── dot_graph.e             -- Graph structure
│   ├── dot_node.e              -- Node representation
│   ├── dot_edge.e              -- Edge representation
│   ├── dot_subgraph.e          -- Subgraph support
│   ├── dot_attributes.e        -- Attribute handling
│   ├── graphviz_renderer.e     -- C library interface
│   ├── graphviz_result.e       -- Operation results
│   ├── graphviz_error.e        -- Error types
│   ├── graphviz_style.e        -- Style presets
│   ├── graphviz_cli.e          -- CLI support
│   ├── graphviz_page_sizer.e   -- Page sizing
│   ├── flowchart_builder.e     -- Flowchart builder
│   ├── state_machine_builder.e -- State machine builder
│   ├── dependency_builder.e    -- Dependency builder
│   ├── inheritance_builder.e   -- Inheritance builder
│   ├── bon_diagram_builder.e   -- BON diagram builder
│   ├── contract_coverage_builder.e -- Contract coverage
│   ├── ecf_parser.e            -- ECF file parsing
│   ├── eiffel_graph_generator.e -- Eiffel graph gen
│   ├── physics_post_processor.e -- Layout constraints
│   └── graph_gen_cli.e         -- Graph generation CLI
├── test/
│   ├── test_app.e              -- Test runner
│   ├── test_dot_graph.e        -- Graph tests
│   ├── test_builders.e         -- Builder tests
│   ├── test_simple_graphviz.e  -- Facade tests
│   ├── test_adversarial.e      -- Edge case tests
│   ├── test_rendering_demos.e  -- Rendering demos
│   └── test_scoop_consumer.e   -- SCOOP tests
├── testing/
│   ├── test_app.e              -- Alt test runner
│   └── lib_tests.e             -- Library tests
├── research/                   -- 7S documents
├── specs/                      -- Specifications
└── simple_graphviz.ecf         -- ECF configuration
```

## Source Files Summary

### Core Classes (~1,500 lines)
- DOT graph structure and manipulation
- Attribute handling and escaping
- Result/error types

### Renderer (~500 lines)
- GraphViz C library integration
- Inline C externals
- Format conversion

### Builders (~1,000 lines)
- Specialized diagram builders
- Fluent API implementations

### Utilities (~200 lines)
- CLI support
- ECF parsing
- Post-processing
