# Mock Apps Summary: simple_graphviz

## Generated: 2026-01-24

## Library Analyzed

- **Library:** simple_graphviz
- **Core capability:** GraphViz diagram generation via DOT language with fluent API
- **Ecosystem position:** Visualization foundation for documentation, architecture, and analysis tools

## Mock Apps Designed

### 1. ArchViz - Architecture Visualizer

- **Purpose:** Automatically generate multi-layer architecture diagrams from project configuration files
- **Target:** Software architects, tech leads, DevOps engineers
- **Ecosystem:** simple_graphviz, simple_xml, simple_json, simple_yaml, simple_file, simple_cli, simple_config, simple_logger
- **Revenue:** Free core + $29-99/user/month for team/enterprise features
- **Status:** Design complete

### 2. PipeDoc - Pipeline Documenter

- **Purpose:** Generate visual documentation from CI/CD pipeline definitions (GitHub Actions, GitLab CI, Azure Pipelines, Jenkins, CircleCI)
- **Target:** DevOps engineers, platform engineers, release managers
- **Ecosystem:** simple_graphviz, simple_yaml, simple_json, simple_file, simple_cli, simple_config, simple_logger, simple_watcher
- **Revenue:** Free core + $49-99/user/month for team/enterprise features
- **Status:** Design complete

### 3. SchemaMap - Database Schema Mapper

- **Purpose:** Generate ER diagrams and data flow visualizations from database connections or DDL files
- **Target:** DBAs, data engineers, backend developers
- **Ecosystem:** simple_graphviz, simple_sql, simple_json, simple_file, simple_cli, simple_config, simple_logger, simple_csv
- **Revenue:** Free core + $19-99/user/month for pro/enterprise features
- **Status:** Design complete

## Ecosystem Coverage

| simple_* Library | Used In |
|------------------|---------|
| simple_graphviz | ArchViz, PipeDoc, SchemaMap |
| simple_json | ArchViz, PipeDoc, SchemaMap |
| simple_file | ArchViz, PipeDoc, SchemaMap |
| simple_cli | ArchViz, PipeDoc, SchemaMap |
| simple_config | ArchViz, PipeDoc, SchemaMap |
| simple_logger | ArchViz, PipeDoc, SchemaMap |
| simple_yaml | ArchViz, PipeDoc |
| simple_xml | ArchViz |
| simple_sql | SchemaMap |
| simple_csv | SchemaMap |
| simple_watcher | ArchViz (opt), PipeDoc (opt), SchemaMap (opt) |
| simple_template | ArchViz (opt), PipeDoc (opt), SchemaMap (opt) |
| simple_diff | ArchViz (opt), PipeDoc (opt), SchemaMap (opt) |
| simple_cache | ArchViz (opt), PipeDoc (opt), SchemaMap (opt) |
| simple_toml | ArchViz (opt), PipeDoc (opt) |
| simple_eiffel_parser | ArchViz (opt) |
| simple_validation | SchemaMap (opt) |
| simple_encryption | SchemaMap (opt) |

**Total unique simple_* libraries leveraged: 18**

## Common Patterns

All three Mock Apps share these design patterns:

1. **CLI-First Architecture:** Full functionality via command-line, enabling CI/CD integration
2. **Configuration Files:** YAML-based configuration for project-specific settings
3. **Multi-Format Output:** SVG, PDF, PNG, and HTML output options
4. **Watch Mode:** Optional file monitoring for live documentation updates
5. **Phased Build Plan:** MVP -> Multi-format -> Advanced -> Polish

## Technical Highlights

| Feature | ArchViz | PipeDoc | SchemaMap |
|---------|---------|---------|-----------|
| Primary Input | ECF, package.json, pom.xml | YAML workflows | Database, DDL |
| simple_graphviz Builder | DEPENDENCY_BUILDER, INHERITANCE_BUILDER | FLOWCHART_BUILDER, STATE_MACHINE_BUILDER | Custom DOT (record nodes) |
| Key Integration | simple_xml, simple_eiffel_parser | simple_yaml | simple_sql |
| Unique Value | Auto-detect project type | Multi-platform CI/CD | Live database connection |

## Next Steps

1. **Select Mock App for implementation** - Choose based on:
   - Immediate need within simple_* ecosystem
   - Market validation priority
   - Available development time

2. **Add app target to simple_graphviz.ecf** - If building as part of simple_graphviz

3. **Create standalone library** - If building as separate simple_* library:
   ```bash
   mkdir /d/prod/simple_{archviz|pipedoc|schemamap}
   ```

4. **Implement Phase 1 (MVP)** - Follow BUILD-PLAN.md for chosen app

5. **Run /eiffel.verify** - Contract validation after implementation

## Implementation Recommendation

**Recommended first implementation: ArchViz**

Rationale:
- Directly builds on simple_graphviz existing capabilities (ECF_PARSER, EIFFEL_GRAPH_GENERATOR)
- Validates simple_* ecosystem as both producer and consumer
- Creates useful tool for simple_* development itself
- Lower risk - most code already exists in simple_graphviz

**Second recommendation: SchemaMap**

Rationale:
- Leverages simple_sql for differentiation
- Clear market need (database documentation)
- Simpler parsing requirements than PipeDoc

## Files Generated

```
mockapps/
  00-MARKETPLACE-RESEARCH.md      # Market analysis and candidate selection
  01-arch-visualizer/
    CONCEPT.md                    # Executive summary, problem statement, value prop
    DESIGN.md                     # Architecture, class design, command structure
    ECOSYSTEM-MAP.md              # simple_* dependencies and integration patterns
    BUILD-PLAN.md                 # Phased implementation with tasks and tests
  02-pipeline-documenter/
    CONCEPT.md
    DESIGN.md
    ECOSYSTEM-MAP.md
    BUILD-PLAN.md
  03-schema-mapper/
    CONCEPT.md
    DESIGN.md
    ECOSYSTEM-MAP.md
    BUILD-PLAN.md
  SUMMARY.md                      # This file
```

---

**Generated by /eiffel.mockapp**

Mock Apps: 3
simple_* Libraries Leveraged: 18
Total Documentation Files: 14
