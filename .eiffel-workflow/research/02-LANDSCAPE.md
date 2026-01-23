# LANDSCAPE: simple_graphviz

## Existing Solutions

### GraphViz (Native Tool)
| Aspect | Assessment |
|--------|------------|
| Type | TOOL |
| Platform | Cross-platform (Windows, Linux, macOS) |
| URL | https://graphviz.org/ |
| Maturity | MATURE (decades of development) |
| License | Eclipse Public License |

**Strengths:**
- Industry-standard graph visualization
- Multiple layout engines (dot, neato, fdp, circo, twopi)
- SVG, PDF, PNG output formats
- Excellent documentation
- Subprocess-friendly (stdin/stdout piping)

**Weaknesses:**
- External dependency (must be installed)
- DOT language has learning curve
- No native Eiffel binding exists

**Relevance:** 95% - Core rendering engine

### EiffelStudio Diagram Tool
| Aspect | Assessment |
|--------|------------|
| Type | IDE FEATURE |
| Platform | Windows, Linux, macOS |
| URL | https://www.eiffel.org/doc/eiffelstudio/Diagram_tool |
| Maturity | MATURE |
| License | ISE Eiffel License |

**Strengths:**
- Native BON notation support
- Real-time code synchronization
- Forward and reverse engineering
- Integrated with EiffelStudio

**Weaknesses:**
- IDE-bound, not programmatically accessible
- Cannot be used for automated documentation
- No command-line export capability
- Closed source

**Relevance:** 30% - Reference for BON notation only

### Extended BON Tool Suite (EBON)
| Aspect | Assessment |
|--------|------------|
| Type | TOOL SUITE |
| Platform | Cross-platform (Java-based) |
| URL | https://ebon.sourceforge.net/ |
| Maturity | LEGACY (last updated years ago) |
| License | Open Source |

**Strengths:**
- Scanner, parser, doc generator for BON
- Design model checker
- Textual BON support

**Weaknesses:**
- Java dependency
- Not actively maintained
- Complex integration for Eiffel projects

**Relevance:** 20% - Reference implementation only

### Python graphviz Package
| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY |
| Platform | Cross-platform (Python) |
| URL | https://pypi.org/project/graphviz/ |
| Maturity | MATURE |
| License | MIT |

**Strengths:**
- Clean API for DOT generation
- Pipe to subprocess for rendering
- Well-documented

**Weaknesses:**
- Python, not Eiffel
- Different language ecosystem

**Relevance:** 40% - API design reference

### ts-graphviz (TypeScript)
| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY |
| Platform | Node.js/Browser |
| URL | https://ts-graphviz.github.io/docs/ts-graphviz/introduction/ |
| Maturity | GROWING |
| License | MIT |

**Strengths:**
- Type-safe DOT generation
- Modern builder pattern
- Good documentation

**Weaknesses:**
- TypeScript/JavaScript only
- Different paradigm

**Relevance:** 35% - Type-safe API design reference

## Eiffel Ecosystem Check

### ISE Libraries
- **Diagram Tool internals**: Not exposed as library, IDE-only
- **INTERNAL/REFLECTOR**: Runtime reflection, not structural analysis

### simple_* Libraries
| Library | Relevance | Notes |
|---------|-----------|-------|
| simple_eiffel_parser | HIGH | Extracts class structure, inheritance, features |
| simple_process | HIGH | SCOOP-safe subprocess for calling `dot` |
| simple_pdf | MEDIUM | PDF export via HTML/SVG embedding |
| simple_graph | LOW | Data structure, not DOT generation |
| simple_file | HIGH | Reading .e files, writing DOT/SVG |
| simple_reflection | LOW | Runtime objects, not source structure |
| simple_template | MEDIUM | Could template DOT output |

### Gobo Libraries
- No direct GraphViz or diagram libraries found

### Gap Analysis
Not available in Eiffel:
- DOT language generation library
- GraphViz subprocess wrapper
- BON notation generator
- Class diagram automation

## Comparison Matrix
| Feature | GraphViz | EiffelStudio | EBON | Our Need |
|---------|----------|--------------|------|----------|
| DOT Generation | N/A | Internal | Java | MUST |
| SVG Output | Yes | Internal | Yes | MUST |
| BON Notation | Manual | Yes | Yes | MUST |
| Subprocess API | Stdin/out | N/A | N/A | MUST |
| Eiffel Native | No | N/A | No | MUST |
| Programmatic | Yes | No | Yes | MUST |
| SCOOP-safe | N/A | N/A | N/A | MUST |

## Patterns Identified
| Pattern | Seen In | Adopt? |
|---------|---------|--------|
| Builder for DOT nodes/edges | ts-graphviz, Python graphviz | YES |
| Subprocess pipe for rendering | Python graphviz | YES |
| Fluent API for configuration | simple_pdf | YES |
| Facade class for simple API | simple_* ecosystem | YES |
| Deferred class for renderers | simple_pdf (engines) | MAYBE |

## Build vs Buy vs Adapt
| Option | Effort | Risk | Fit |
|--------|--------|------|-----|
| Build | MEDIUM | LOW | 90% |
| Adopt | N/A | N/A | 0% (nothing to adopt) |
| Adapt | HIGH | MEDIUM | 40% (EBON Java, wrong language) |

**Initial Recommendation:** BUILD - No existing Eiffel library; GraphViz handles heavy lifting; simple_* ecosystem provides all needed infrastructure.
