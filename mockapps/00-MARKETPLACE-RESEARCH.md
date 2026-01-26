# Marketplace Research: simple_graphviz

**Generated:** 2026-01-24
**Library:** simple_graphviz
**Status:** Complete

---

## Library Profile

### Core Capabilities

| Capability | Description | Business Value |
|------------|-------------|----------------|
| DOT Graph Building | Programmatic construction of DOT language graphs | Automate diagram generation in build pipelines |
| Multiple Diagram Types | BON, flowcharts, state machines, dependencies, inheritance | Cover diverse documentation needs with one library |
| GraphViz Rendering | Direct rendering to SVG, PDF, PNG via C library | No subprocess overhead, enterprise-grade output |
| Fluent API | Builder pattern with method chaining | Developer productivity, readable code |
| ECF Parsing | Extract Eiffel project structure from .ecf files | Auto-generate documentation from source |
| Eiffel Source Analysis | Parse .e files for class/feature/contract info | Visualize codebase architecture automatically |
| Contract Coverage | Visualize DBC coverage across classes | Quality metrics for Eiffel projects |

### API Surface

| Feature | Type | Use Case |
|---------|------|----------|
| `bon_diagram` | Builder | Create BON-style class diagrams |
| `flowchart` | Builder | Create process flowcharts |
| `state_machine` | Builder | Create FSM diagrams |
| `dependency_graph` | Builder | Create dependency graphs |
| `inheritance_tree` | Builder | Create inheritance hierarchies |
| `render_svg/pdf/png` | Command | Generate output files |
| `to_dot` | Query | Get DOT source code |
| `ECF_PARSER` | Utility | Parse Eiffel configurations |
| `EIFFEL_PARSER` | Utility | Parse Eiffel source files |

### Existing Dependencies

| simple_* Library | Purpose in this library |
|------------------|------------------------|
| simple_mml | MML model queries for contracts |
| simple_process | Subprocess execution (fallback renderer) |
| simple_xml | ECF file parsing |
| simple_logger | Logging infrastructure |
| simple_eiffel_parser | Eiffel source code parsing |

### Integration Points

- **Input formats:** ECF (Eiffel config), .e (Eiffel source), DOT (manual)
- **Output formats:** SVG, PDF, PNG, DOT source
- **Data flow:** Source -> Parser -> Graph Model -> DOT -> Renderer -> Output

---

## Marketplace Analysis

### Industry Applications

| Industry | Application | Pain Point Solved |
|----------|-------------|-------------------|
| Software Development | Architecture documentation | Manual diagram updates become stale |
| DevOps/Platform | CI/CD pipeline visualization | Complex workflows hard to communicate |
| Database Administration | Schema documentation | ER diagrams out of sync with schema |
| Enterprise IT | System dependency mapping | Impact analysis for changes |
| Quality Assurance | Test coverage visualization | Contract/test gaps hard to see |
| Consulting | Client deliverables | Consistent professional diagrams |
| Compliance | Audit documentation | Traceable system architecture |

### Commercial Products (Competitors/Inspirations)

| Product | Price Point | Key Features | Gap We Could Fill |
|---------|-------------|--------------|-------------------|
| Structurizr | $10-25/month | C4 diagrams, DSL | CLI-first, Eiffel-native |
| CodeSee | Enterprise | Auto-map codebases | Eiffel ecosystem integration |
| Lucidchart | $7.95-45/month | Collaborative diagramming | Automation, code-first |
| Enterprise Architect | $229+ perpetual | Full UML suite | Lightweight CLI alternative |
| dbdiagram.io | Free-$14/month | Database ERDs | Multi-format output |
| DrawSQL | Free-$19/month | Team collaboration | CLI automation |
| PlantUML | Free | Text-to-UML | Better Eiffel integration |
| Mermaid | Free | GitHub-native | Enterprise output formats |

### Workflow Integration Points

| Workflow | Where This Library Fits | Value Added |
|----------|-------------------------|-------------|
| CI/CD Pipeline | Post-build documentation step | Auto-update architecture docs |
| Code Review | PR visualization | Show impact of changes |
| Onboarding | Codebase overview generation | Accelerate new dev ramp-up |
| Sprint Planning | Dependency analysis | Better estimation |
| Release Management | System overview | Stakeholder communication |
| Audit Preparation | Generate compliance diagrams | Consistent documentation |

### Target User Personas

| Persona | Role | Need | Willingness to Pay |
|---------|------|------|-------------------|
| DevOps Engineer | Platform team | Automate pipeline documentation | HIGH |
| Technical Architect | Enterprise | System-wide dependency views | HIGH |
| Database Administrator | IT Department | Keep schema docs current | MEDIUM |
| Tech Lead | Development team | Onboarding materials | MEDIUM |
| QA Manager | Testing team | Coverage visualization | MEDIUM |
| Consultant | External | Professional deliverables | HIGH |

---

## Mock App Candidates

### Candidate 1: ArchViz - Architecture Visualizer

**One-liner:** Automatically generate multi-layer architecture diagrams from project configuration files.

**Target market:** Software architects, tech leads, DevOps engineers at mid-to-large enterprises.

**Revenue model:**
- CLI tool: Free open-source
- Enterprise features: $29/month (team dashboards, history, diff views)

**Ecosystem leverage:**
- simple_graphviz (core rendering)
- simple_xml (config parsing)
- simple_json (output formats)
- simple_config (settings management)
- simple_file (file operations)
- simple_cli (argument parsing)
- simple_logger (diagnostics)

**CLI-first value:**
- Integrates into CI/CD pipelines
- Scriptable, automatable
- No GUI dependencies for headless servers

**GUI/TUI potential:**
- Dashboard for diagram history
- Interactive dependency explorer
- Side-by-side diff viewer

**Viability:** HIGH - Addresses clear market need with proven demand

---

### Candidate 2: PipeDoc - Pipeline Documenter

**One-liner:** Generate visual documentation from CI/CD pipeline definitions (YAML, JSON).

**Target market:** DevOps teams, platform engineers, release managers.

**Revenue model:**
- CLI tool: Free open-source
- Enterprise: $49/month (multi-repo, history, notifications)

**Ecosystem leverage:**
- simple_graphviz (diagram rendering)
- simple_yaml (YAML pipeline parsing)
- simple_json (JSON pipeline parsing)
- simple_toml (TOML config parsing)
- simple_file (file operations)
- simple_template (report generation)
- simple_cli (argument parsing)
- simple_watcher (file change detection)

**CLI-first value:**
- Self-documenting pipelines
- Pre-commit hooks for validation
- Pipeline as documentation

**GUI/TUI potential:**
- Real-time pipeline status overlay
- Interactive step inspection
- Historical comparison

**Viability:** HIGH - Growing DevOps market, clear pain point

---

### Candidate 3: SchemaMap - Database Schema Mapper

**One-liner:** Generate ER diagrams and data flow visualizations from database connections or DDL files.

**Target market:** DBAs, data engineers, backend developers, data architects.

**Revenue model:**
- CLI tool: Free open-source
- Pro: $19/month (multiple databases, scheduled refresh)
- Enterprise: $99/month (cross-database relationships, audit trail)

**Ecosystem leverage:**
- simple_graphviz (ER diagram rendering)
- simple_sql (database connectivity)
- simple_csv (data export)
- simple_json (metadata storage)
- simple_config (connection settings)
- simple_cli (argument parsing)
- simple_template (documentation generation)
- simple_validation (schema validation)

**CLI-first value:**
- Integrate into migration scripts
- Document-as-you-deploy
- Database CI/CD integration

**GUI/TUI potential:**
- Interactive schema browser
- Relationship explorer
- Impact analysis visualization

**Viability:** HIGH - Database documentation is evergreen need

---

## Selection Rationale

These three candidates were selected based on:

1. **Market Validation:** Each addresses a documented pain point with existing commercial solutions, proving market demand.

2. **Ecosystem Leverage:** Each uses 6+ simple_* libraries, demonstrating the power of the ecosystem.

3. **CLI-First Fit:** Each naturally suits automation and scripting, fitting the simple_* philosophy.

4. **Revenue Potential:** Each has clear paths to monetization through enterprise features.

5. **Technical Feasibility:** Each builds primarily on capabilities simple_graphviz already provides.

6. **Differentiation:** Each offers something the current market lacks - Eiffel-native, CLI-first, simple_* integration.

---

## Research Sources

- [Graphviz Official](https://www.graphviz.org/)
- [Structurizr](https://structurizr.com/)
- [CodeSee](https://www.codesee.io/)
- [dbdiagram.io](https://dbdiagram.io/home)
- [DrawSQL](https://drawsql.app/)
- [Lucidchart](https://www.lucidchart.com/)
- [Mermaid.js Documentation](https://mermaid.js.org/)
- [Enterprise Architect by Sparx Systems](https://sparxsystems.com/)
- [TechTarget: Software Architecture Visualization Tools](https://www.techtarget.com/searchapparchitecture/tip/A-review-of-top-software-architecture-visualization-tools)
- [Top Code Visualization Tools 2026](https://thectoclub.com/tools/best-code-visualization-tools/)
