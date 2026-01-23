# DECISIONS: simple_graphviz

## Decision Log

### D-001: GraphViz Integration Approach
**Question:** How should we integrate with GraphViz - native library binding or subprocess?
**Options:**
1. Native C binding via inline C externals
   - Pros: No external dependency, faster execution
   - Cons: Complex, platform-specific, large codebase
2. Subprocess via simple_process
   - Pros: Simple, proven pattern, GraphViz handles all rendering
   - Cons: Requires GraphViz installation, subprocess overhead

**Decision:** Subprocess via simple_process
**Rationale:**
- GraphViz is mature and handles complex layout algorithms
- simple_process is SCOOP-safe and well-tested
- Subprocess pattern used successfully in simple_pdf (wkhtmltopdf, Chrome)
- Development effort is significantly lower
**Implications:** Users must install GraphViz; we document installation
**Reversible:** YES (could add native binding later as optimization)

### D-002: Class Structure Source
**Question:** How do we obtain class structure - parse source or use reflection?
**Options:**
1. Parse Eiffel source files via simple_eiffel_parser
   - Pros: Access to all structural info, works without running code
   - Cons: Depends on parser accuracy
2. Runtime reflection via simple_reflection
   - Pros: Always accurate for running system
   - Cons: Requires compiled/running code, misses some static info

**Decision:** Parse Eiffel source files via simple_eiffel_parser
**Rationale:**
- Diagrams are for documentation, not runtime analysis
- Parser extracts inheritance, features, contracts
- No need to compile target system
- Consistent with BON methodology (design-time notation)
**Implications:** Diagrams reflect source structure, not runtime behavior
**Reversible:** YES (could add reflection mode later)

### D-003: DOT Generation Approach
**Question:** How do we generate DOT language output?
**Options:**
1. String concatenation/templates
   - Pros: Simple, no dependencies
   - Cons: Error-prone, escaping issues
2. Structured DOT builder (AST)
   - Pros: Type-safe, composable, validates structure
   - Cons: More code to write
3. Use simple_template with DOT templates
   - Pros: Reuses existing library
   - Cons: Template syntax overkill for structured output

**Decision:** Structured DOT builder (AST)
**Rationale:**
- Type safety prevents invalid DOT generation
- Builder pattern matches simple_* ecosystem style
- Easier to unit test
- Matches patterns from ts-graphviz and Python graphviz
**Implications:** Need to implement DOT_NODE, DOT_EDGE, DOT_GRAPH classes
**Reversible:** NO (core architectural choice)

### D-004: BON Notation Compliance Level
**Question:** How strictly should we follow BON notation?
**Options:**
1. Strict BON compliance (ellipses, exact arrow styles)
   - Pros: Matches EiffelStudio, recognizable to Eiffel developers
   - Cons: May limit flexibility
2. BON-inspired with flexibility (configurable styles)
   - Pros: Users can customize, modern aesthetics possible
   - Cons: May not match "official" BON

**Decision:** BON-inspired with flexibility, BON defaults
**Rationale:**
- Provide `style_bon` preset for strict BON look
- Allow customization for users with different preferences
- GraphViz has excellent styling capabilities
- Modern documentation may prefer different aesthetics
**Implications:** Need style presets system; BON is default but not required
**Reversible:** YES (can always add stricter mode)

### D-005: PDF Export Strategy
**Question:** How do we generate PDF output?
**Options:**
1. GraphViz direct PDF output (`dot -Tpdf`)
   - Pros: Single tool, no extra dependency
   - Cons: Limited PDF features
2. SVG embedded in HTML, render via simple_pdf
   - Pros: Full PDF control, matches ecosystem pattern
   - Cons: Extra step, dependency on simple_pdf
3. Both options available
   - Pros: User choice
   - Cons: More code to maintain

**Decision:** Both options available
**Rationale:**
- Simple cases use `dot -Tpdf` directly
- Complex cases (multi-page, headers/footers) use simple_pdf route
- Users choose based on needs
**Implications:** Two render paths; document trade-offs
**Reversible:** YES

### D-006: AI Integration
**Question:** Should we integrate AI assistance, and how?
**Options:**
1. No AI integration
   - Pros: Simple, no dependencies
   - Cons: Misses potential value
2. AI for layout suggestions via simple_ai_client
   - Pros: Could suggest better layouts, groupings
   - Cons: Adds complexity, non-deterministic
3. AI for diagram description generation
   - Pros: Generate human-readable descriptions
   - Cons: Tangential to core purpose

**Decision:** Defer AI integration to future phase
**Rationale:**
- Core functionality (DOT generation, rendering) is well-defined
- GraphViz's layout algorithms are already excellent
- AI integration adds complexity without clear value proposition
- Can revisit after MVP proves useful
**Implications:** No simple_ai_client dependency for v1.0
**Reversible:** YES (designed to add later)

### D-007: Library Architecture
**Question:** What's the class structure for the library?
**Options:**
1. Single facade class (SIMPLE_GRAPHVIZ)
   - Pros: Simple API
   - Cons: May become large
2. Layered: DOT builder + Renderer + BON adapter
   - Pros: Separation of concerns, testable
   - Cons: More classes

**Decision:** Layered architecture with facade
**Rationale:**
- DOT_GRAPH, DOT_NODE, DOT_EDGE for low-level DOT building
- GRAPHVIZ_RENDERER for subprocess calls
- BON_DIAGRAM_BUILDER for Eiffel-to-DOT conversion
- SIMPLE_GRAPHVIZ facade for simple use cases
- Matches simple_pdf architecture (engines + facade)
**Implications:** ~8-10 classes in library
**Reversible:** NO (core architecture)
