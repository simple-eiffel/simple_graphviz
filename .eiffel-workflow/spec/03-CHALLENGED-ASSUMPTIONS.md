# CHALLENGED ASSUMPTIONS: simple_graphviz

## Assumptions Challenged

### A-001: GraphViz `dot` accepts DOT via stdin
**Challenge:** Does simple_process support stdin piping? What if it doesn't?
**Evidence for:** GraphViz documentation confirms stdin support; Python graphviz uses pipe()
**Evidence against:** simple_process README shows `output_of_command` - need to verify stdin
**Verdict:** NEEDS_VALIDATION
**Action:** Test simple_process with stdin piping. If not supported, use temp file approach (write DOT to temp file, call dot with file path, read output file). simple_file can handle temp files.

### A-002: simple_process can capture large SVG output
**Challenge:** What's the buffer limit? 100+ class diagrams could be large.
**Evidence for:** simple_process used in simple_pdf for HTML-to-PDF conversion (large output)
**Evidence against:** No explicit documentation of buffer size
**Verdict:** NEEDS_VALIDATION
**Action:** Design with file-based fallback from the start. Primary path: pipe. Fallback: write DOT to temp, render to temp SVG, read SVG file.

### A-003: simple_eiffel_parser extracts inheritance info
**Challenge:** Does the parser have all we need?
**Evidence for:** Verified by reading parser source:
- EIFFEL_CLASS_NODE: name, is_deferred, is_expanded, is_frozen, parents, features
- EIFFEL_PARENT_NODE: parent_name, renames, redefines, undefines, selects
- EIFFEL_FEATURE_NODE: name, kind, return_type, arguments, is_deferred, export_status
**Evidence against:** None - parser has complete structural info
**Verdict:** VALID
**Action:** None - parser confirmed suitable

### A-004: HTML + embedded SVG works with simple_pdf
**Challenge:** Can simple_pdf render embedded SVG correctly?
**Evidence for:** wkhtmltopdf/Chrome handle SVG in HTML
**Evidence against:** May have sizing or scaling issues
**Verdict:** NEEDS_VALIDATION
**Action:** Test SVG embedding in simple_pdf during implementation. Fallback: use dot -Tpdf directly for simple cases.

## Requirements Questioned

### FR-004: Represent client-supplier arrows
**Challenge:** How do we detect client-supplier relationships? Feature return types? Attribute types?
**Verdict:** MODIFY
**If MODIFY:** Client-supplier detection is complex (analyze types in features). Defer to Phase 2. For MVP, support manual client-supplier edge addition in low-level API.

### FR-009: Display class features
**Challenge:** How much detail? All features? Just public? Just signatures?
**Verdict:** MODIFY
**If MODIFY:** Make configurable. Default: public features only, signature only (no body). Option: include_all_features, include_private, show_contracts.

### FR-010: Support cluster grouping
**Challenge:** How do we determine clusters? Directory structure? Manual specification?
**Verdict:** KEEP
**Note:** Use directory structure by default when using from_directory. Also support manual cluster specification.

### FR-013: Generate from directory tree
**Challenge:** Recursive? What about test directories? Generated code?
**Verdict:** MODIFY
**If MODIFY:** Add filter patterns. Default: *.e files, exclude /testing/, /EIFGENs/. Allow custom include/exclude patterns.

## Missing Requirements Identified

| ID | Missing Requirement | How Discovered |
|----|---------------------|----------------|
| FR-NEW-001 | DOT string escaping utility | Analyzing RISK-004 |
| FR-NEW-002 | Layout engine selection (dot/neato/fdp) | GraphViz has multiple engines |
| FR-NEW-003 | Save DOT source to file | Users may want to edit DOT manually |
| FR-NEW-004 | Timeout configuration for rendering | Addressing RISK-006 |
| FR-NEW-005 | File-based rendering fallback | Addressing RISK-002 |
| FR-NEW-006 | GraphViz version detection | Addressing RISK-009 |

## Design Constraints Validated

| Constraint | Valid? | Notes |
|------------|--------|-------|
| simple_* first | YES | Dependencies: simple_eiffel_parser, simple_process, simple_file, simple_pdf |
| SCOOP-compatible | YES | simple_process is SCOOP-safe, no threading |
| Void-safe | YES | Will use detachable appropriately |
| GraphViz external | YES | Cannot avoid - core rendering engine |

## Parser API Verification

Verified simple_eiffel_parser provides:

| Need | Parser Provides | Status |
|------|-----------------|--------|
| Class name | EIFFEL_CLASS_NODE.name | YES |
| Is deferred | EIFFEL_CLASS_NODE.is_deferred | YES |
| Is expanded | EIFFEL_CLASS_NODE.is_expanded | YES |
| Is frozen | EIFFEL_CLASS_NODE.is_frozen | YES |
| Parent classes | EIFFEL_CLASS_NODE.parents → EIFFEL_PARENT_NODE.parent_name | YES |
| Features | EIFFEL_CLASS_NODE.features → EIFFEL_FEATURE_NODE | YES |
| Feature name | EIFFEL_FEATURE_NODE.name | YES |
| Feature kind | EIFFEL_FEATURE_NODE.kind (attribute/function/procedure) | YES |
| Return type | EIFFEL_FEATURE_NODE.return_type | YES |
| Arguments | EIFFEL_FEATURE_NODE.arguments → EIFFEL_ARGUMENT_NODE | YES |
| Export status | EIFFEL_FEATURE_NODE.export_status | YES |
| Signature | EIFFEL_FEATURE_NODE.signature | YES |

**Conclusion:** Parser API is complete for BON diagram generation.
