# S05: CONSTRAINTS - simple_graphviz

**Document**: S05-CONSTRAINTS.md
**Library**: simple_graphviz
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Technical Constraints

### GraphViz Dependency

1. **Installation Required**
   - GraphViz must be installed on system
   - Libraries (gvc, cgraph) must be accessible
   - Minimum version: 2.40 recommended

2. **Library Locations**
   - Windows: Standard installation paths
   - Linux: /usr/lib, /usr/local/lib
   - macOS: Homebrew or standard paths

### DOT Language Constraints

1. **Node IDs**
   - Must not be empty
   - Should be unique within graph
   - Special characters escaped automatically

2. **Edge Constraints**
   - DOT allows edges to non-existent nodes (implicit creation)
   - This is by design per DOT specification

3. **Subgraph Names**
   - Clusters must start with "cluster_" for special rendering
   - Names must be unique

### Layout Constraints

1. **Engine Selection**
   - Valid engines: dot, neato, fdp, circo, twopi, osage, sfdp
   - Default: dot (hierarchical)

2. **Timeout**
   - Must be positive (> 0)
   - Default: 30,000 ms
   - Large graphs may exceed timeout

### Output Constraints

1. **File Paths**
   - Must not be empty
   - Directory must exist (not created automatically)
   - Write permission required

2. **Format Support**
   - SVG: Text output
   - PDF: Binary output
   - PNG: Binary output

### Performance Constraints

- Memory: Large graphs consume significant memory
- CPU: Complex layouts are computationally expensive
- Timeout: Long-running renders may timeout

## Platform Constraints

| Platform | GraphViz Location |
|----------|-------------------|
| Windows | Program Files, PATH |
| Linux | /usr/lib, /usr/local/lib |
| macOS | /usr/local/lib, Homebrew |
