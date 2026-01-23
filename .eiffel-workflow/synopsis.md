# Phase 2 Synopsis: simple_graphviz Contract Review

## Review Chain Summary

| Reviewer | Status | Valid Issues | False Positives |
|----------|--------|--------------|-----------------|
| Ollama (qwen2.5-coder:14b) | Complete | 0 | 20 |
| Claude (Opus 4.5) | Complete | 6 | 0 |
| Grok | Skipped | - | - |
| Gemini | Skipped | - | - |

## Consolidated Findings

### Contract Strengths (Confirmed by Both Reviewers)

1. **MML Model Queries**: DOT_GRAPH has proper MML_SEQUENCE models for nodes, edges, and subgraphs
2. **Frame Conditions**: `|=|` operator correctly used to specify unchanged collections
3. **XOR Invariant**: GRAPHVIZ_RESULT uses proper success-or-error pattern
4. **Fluent API**: All setters ensure `Result = Current`
5. **Precondition Validation**: `is_valid_engine` used as precondition in GRAPHVIZ_RENDERER

### Issues to Address

| ID | Severity | Location | Issue | Action |
|----|----------|----------|-------|--------|
| C01 | MEDIUM | DOT_SUBGRAPH | Cluster prefix mentioned but not enforced | Document intention or add invariant |
| C02 | LOW | DOT_GRAPH.add_edge | Allows edges to non-existent nodes | Document as intentional (DOT allows implicit nodes) |
| C03 | LOW | GRAPHVIZ_STYLE | String-based enum not type-safe | Acceptable for simple library |
| C04 | LOW | GRAPHVIZ_RENDERER.render | No frame conditions on render | Add comment explaining external side-effect nature |
| C05 | MEDIUM | Builder classes | No MML models on builders | Document DOT_GRAPH models are authoritative |
| C06 | LOW | DOT_ATTRIBUTES | May not cover all DOT escapes | Add precondition documenting supported chars |

### Recommended Actions Before Phase 3

1. **ISSUE-C01**: Add note to DOT_SUBGRAPH that `cluster_` prefix is recommended but not enforced (DOT supports non-cluster subgraphs)

2. **ISSUE-C02**: Add comment to `add_edge` explaining that DOT language allows implicit node creation, so edges can reference undefined nodes

3. **ISSUE-C05**: Add note to builder classes that MML verification happens at the DOT_GRAPH level, not at builder level

### Deferred to Phase 4

- ISSUE-C04: Add frame conditions to render methods when implementing
- ISSUE-C06: Review DOT escaping spec during implementation

## Verdict

**PASS** - Contracts are well-designed with proper MML usage. No HIGH severity issues. MEDIUM issues can be addressed with documentation clarifications.

## Recommendation

**PROCEED to Phase 3** (`/eiffel.tasks`) after adding documentation notes for C01, C02, and C05.
