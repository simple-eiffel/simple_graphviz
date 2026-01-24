# 7S-02: STANDARDS - simple_graphviz

**Document**: 7S-02-STANDARDS.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Applicable Standards

### DOT Language

1. **DOT Language Specification**
   - Reference: https://graphviz.org/doc/info/lang.html
   - Graph, digraph, subgraph syntax
   - Node and edge declarations
   - Attribute syntax

2. **GraphViz Attributes**
   - Reference: https://graphviz.org/doc/info/attrs.html
   - Node attributes (shape, color, label)
   - Edge attributes (style, arrowhead)
   - Graph attributes (rankdir, splines)

### Output Formats

1. **SVG (Scalable Vector Graphics)**
   - Reference: W3C SVG 1.1
   - Vector output for web/documentation

2. **PDF (Portable Document Format)**
   - Reference: ISO 32000
   - Print-quality output

3. **PNG (Portable Network Graphics)**
   - Reference: ISO/IEC 15948
   - Raster output for presentations

### Layout Algorithms

| Engine | Algorithm | Use Case |
|--------|-----------|----------|
| dot | Hierarchical | Directed graphs, flowcharts |
| neato | Spring model | Undirected graphs |
| fdp | Force-directed | Large undirected graphs |
| circo | Circular | Cyclic structures |
| twopi | Radial | Hierarchical radial |

## Implementation Compliance

| Standard | Compliance Level | Notes |
|----------|------------------|-------|
| DOT Language | Full | Complete syntax support |
| GraphViz Attrs | Partial | Common attributes |
| SVG Output | Full | Via GraphViz |
| PDF Output | Full | Via GraphViz |
| PNG Output | Full | Via GraphViz |
