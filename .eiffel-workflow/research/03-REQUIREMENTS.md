# REQUIREMENTS: simple_graphviz

## Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-001 | Generate DOT language from class data | MUST | Valid DOT accepted by `dot` command |
| FR-002 | Represent classes as BON ellipses | MUST | shape=ellipse with class name |
| FR-003 | Represent inheritance arrows | MUST | Directed edge from child to parent |
| FR-004 | Represent client-supplier arrows | SHOULD | Directed edge with different style |
| FR-005 | Render DOT to SVG | MUST | `dot -Tsvg` produces valid SVG |
| FR-006 | Parse Eiffel files for class structure | MUST | Extract class name, parents, features |
| FR-007 | Support deferred class notation | SHOULD | Different fill/border for deferred |
| FR-008 | Support expanded class notation | SHOULD | Different fill/border for expanded |
| FR-009 | Display class features | SHOULD | Attributes and routines in node label |
| FR-010 | Support cluster grouping | SHOULD | GraphViz subgraph for packages |
| FR-011 | Export to PDF | SHOULD | Via simple_pdf HTML/SVG embedding |
| FR-012 | Configurable diagram styles | SHOULD | Colors, fonts, shapes |
| FR-013 | Generate from directory tree | COULD | Process all .e files in folder |
| FR-014 | Filter classes by pattern | COULD | Include/exclude by name pattern |
| FR-015 | Aggregation arrow notation | COULD | Double-line arrow per BON spec |

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-------------|----------|---------|--------|
| NFR-001 | SCOOP-compatible | COMPATIBILITY | Compile with scoop | Yes |
| NFR-002 | Subprocess execution safe | RELIABILITY | No hangs/crashes | 99.9% |
| NFR-003 | Process large codebases | PERFORMANCE | 100+ classes | < 30 seconds |
| NFR-004 | Clean API surface | USABILITY | Public features | < 20 |
| NFR-005 | Full DBC contracts | QUALITY | Preconditions/postconditions | 100% |
| NFR-006 | Cross-platform rendering | PORTABILITY | Windows + GraphViz | Required |
| NFR-007 | Minimal dependencies | MAINTAINABILITY | simple_* libs | 4-5 max |

## Constraints

| ID | Constraint | Type | Immutable? |
|----|------------|------|------------|
| C-001 | Must be SCOOP-compatible | TECHNICAL | YES |
| C-002 | Must prefer simple_* over ISE | ECOSYSTEM | YES |
| C-003 | GraphViz external dependency | TECHNICAL | YES |
| C-004 | Use simple_eiffel_parser for parsing | ECOSYSTEM | YES |
| C-005 | Use simple_process for subprocess | ECOSYSTEM | YES |
| C-006 | Windows primary platform | PLATFORM | NO |

## Data Model Requirements

### Input Data
```
CLASS_INFO:
  - name: STRING
  - is_deferred: BOOLEAN
  - is_expanded: BOOLEAN
  - is_frozen: BOOLEAN
  - parents: LIST [STRING]
  - features: LIST [FEATURE_INFO]
  - clients: LIST [STRING]  (optional - derived from feature types)

FEATURE_INFO:
  - name: STRING
  - is_attribute: BOOLEAN
  - return_type: STRING (optional)
  - arguments: LIST [TUPLE [name, type]]
```

### Output Data
```
DOT_GRAPH:
  - graph_type: digraph
  - name: STRING
  - global_attributes: MAP [STRING, STRING]
  - nodes: LIST [DOT_NODE]
  - edges: LIST [DOT_EDGE]
  - subgraphs: LIST [DOT_SUBGRAPH]

DOT_NODE:
  - id: STRING
  - label: STRING
  - attributes: MAP [STRING, STRING]

DOT_EDGE:
  - from_id: STRING
  - to_id: STRING
  - attributes: MAP [STRING, STRING]
```

## API Requirements

### Fluent Builder Pattern
```eiffel
-- Desired API style
create graphviz.make
diagram := graphviz
    .title ("My System")
    .style_bon  -- Use BON notation defaults
    .from_files (["class_a.e", "class_b.e"])
    .to_svg

-- Or from parsed AST
diagram := graphviz
    .from_ast (parser.ast)
    .include_features
    .to_dot
```

### Direct DOT Generation
```eiffel
-- Low-level DOT building
create dot.make_digraph ("MyDiagram")
dot.add_node ("CLASS_A", [["shape", "ellipse"]])
dot.add_node ("CLASS_B", [["shape", "ellipse"]])
dot.add_edge ("CLASS_B", "CLASS_A")  -- B inherits from A
svg := dot.render_svg
```

## BON Notation Requirements

### Class Shapes
| Class Type | DOT Shape | Fill | Border |
|------------|-----------|------|--------|
| Regular | ellipse | white | black solid |
| Deferred | ellipse | white | black dashed |
| Expanded | ellipse | light gray | black solid |
| Frozen | ellipse | white | black double |

### Arrow Types
| Relationship | DOT Style | Description |
|--------------|-----------|-------------|
| Inheritance | arrowhead=empty | Child -> Parent |
| Client-Supplier | arrowhead=vee | Client -> Supplier |
| Aggregation | arrowhead=diamond | Whole -> Part |

### Label Format
```
<<class_name>>
--------------------
+ attribute: TYPE
--------------------
+ routine (args): TYPE
```

(Simplified for BON - full UML compartments optional)
