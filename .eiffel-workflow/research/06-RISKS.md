# RISKS: simple_graphviz

## Risk Register

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|------------|--------|------------|
| RISK-001 | GraphViz not installed on user systems | MEDIUM | HIGH | Document installation; detect and warn |
| RISK-002 | Large diagram SVG exceeds simple_process buffer | LOW | MEDIUM | File-based output fallback |
| RISK-003 | simple_eiffel_parser missing inheritance info | LOW | HIGH | Verify parser capabilities first |
| RISK-004 | DOT escaping bugs cause rendering failures | MEDIUM | MEDIUM | Comprehensive escaping; test suite |
| RISK-005 | BON notation unclear for edge cases | LOW | LOW | Reference EiffelStudio as authority |
| RISK-006 | GraphViz subprocess hangs | LOW | MEDIUM | Timeout in simple_process |
| RISK-007 | Cross-platform path issues | MEDIUM | MEDIUM | Use simple_file for path handling |

## Technical Risks

### RISK-001: GraphViz Installation Dependency
**Description:** Users may not have GraphViz installed; detection and error messaging unclear.
**Likelihood:** MEDIUM (GraphViz is common but not universal)
**Impact:** HIGH (library unusable without it)
**Indicators:** `dot -V` fails; user complaints about "command not found"
**Mitigation:**
- Add `is_graphviz_available: BOOLEAN` query
- Provide clear installation instructions in README
- Consider bundling Windows binaries (like simple_pdf does for wkhtmltopdf)
**Contingency:** Document manual DOT file generation as fallback

### RISK-002: Large Diagram Output Buffering
**Description:** Large codebases produce large SVG; simple_process buffer may be insufficient.
**Likelihood:** LOW (most diagrams are reasonably sized)
**Impact:** MEDIUM (truncated output, rendering errors)
**Indicators:** SVG output incomplete; XML parse errors
**Mitigation:**
- Test with large systems (100+ classes)
- Implement file-based output path (dot writes to file, we read)
- Document system limits
**Contingency:** Always use file-based output if buffering fails

### RISK-003: Parser Capability Gaps
**Description:** simple_eiffel_parser may not extract all needed structural information.
**Likelihood:** LOW (parser is feature-complete for structure)
**Impact:** HIGH (diagrams missing information)
**Indicators:** Missing parents, incomplete feature lists
**Mitigation:**
- Verify parser extracts: class names, parents, features, deferred/expanded flags
- File issues/enhancements for parser if needed
**Contingency:** Add manual class specification as fallback input

### RISK-004: DOT String Escaping
**Description:** Special characters in class/feature names break DOT syntax.
**Likelihood:** MEDIUM (Eiffel allows various characters)
**Impact:** MEDIUM (rendering failures)
**Indicators:** GraphViz errors about invalid syntax
**Mitigation:**
- Implement robust DOT escaping function
- Test with edge cases: quotes, backslashes, Unicode
- Use DOT HTML labels which have clear escaping rules
**Contingency:** Sanitize names to safe ASCII subset

### RISK-005: BON Notation Ambiguity
**Description:** BON specification unclear for some visual elements.
**Likelihood:** LOW (BON is well-documented)
**Impact:** LOW (aesthetic issue, not functional)
**Indicators:** User complaints about "incorrect" notation
**Mitigation:**
- Use EiffelStudio as visual reference
- Document our notation choices
- Make styles configurable
**Contingency:** Users can override default styles

### RISK-006: Subprocess Reliability
**Description:** GraphViz subprocess may hang, crash, or behave unexpectedly.
**Likelihood:** LOW (GraphViz is stable)
**Impact:** MEDIUM (application hangs)
**Indicators:** No response from dot command; zombie processes
**Mitigation:**
- Use simple_process timeout capability
- Default timeout of 30 seconds for rendering
- Document large diagram timeout configuration
**Contingency:** Kill stuck process; return error to user

### RISK-007: Cross-Platform Path Handling
**Description:** File paths for .e files, output files may have platform issues.
**Likelihood:** MEDIUM (Windows vs Unix paths)
**Impact:** MEDIUM (file not found errors)
**Indicators:** Works on one platform, fails on another
**Mitigation:**
- Use simple_file for all path operations
- Test on Windows (primary) and document Linux/macOS
- Use forward slashes consistently
**Contingency:** Expose raw path options for user override

## Ecosystem Risks

### RISK-008: simple_eiffel_parser Breaking Changes
**Description:** Parser library API changes could break our integration.
**Likelihood:** LOW (parser is stable v1.0)
**Impact:** MEDIUM (compilation failures)
**Indicators:** Build failures after parser update
**Mitigation:**
- Pin to specific parser version in ECF
- Abstract parser interaction through adapter
**Contingency:** Fork parser or maintain adapter shim

### RISK-009: GraphViz Version Incompatibility
**Description:** Different GraphViz versions may have different behaviors.
**Likelihood:** LOW (DOT language is stable)
**Impact:** LOW (minor visual differences)
**Indicators:** Output differs between systems
**Mitigation:**
- Test with common GraphViz versions (2.40+)
- Document minimum version requirement
- Avoid bleeding-edge DOT features
**Contingency:** Users upgrade GraphViz

## Resource Risks

### RISK-010: Development Scope Creep
**Description:** Feature requests expand scope beyond reasonable MVP.
**Likelihood:** MEDIUM (diagrams invite feature requests)
**Impact:** MEDIUM (delayed delivery)
**Indicators:** Growing requirements list; never "done"
**Mitigation:**
- Strict MVP definition (DOT generation + SVG output)
- Defer advanced features to post-v1.0
- Document "not in scope" explicitly
**Contingency:** Ship minimal viable version; iterate

### RISK-011: Testing Complexity
**Description:** Visual output is hard to test automatically.
**Likelihood:** HIGH (inherent to diagram generation)
**Impact:** LOW (manual verification possible)
**Indicators:** Tests can't validate visual correctness
**Mitigation:**
- Test DOT string generation (unit tests)
- Test GraphViz acceptance (integration tests)
- Visual regression testing deferred to CI with snapshots
**Contingency:** Manual visual verification for releases
