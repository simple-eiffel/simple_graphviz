# Eiffel Contract Review Request (Claude)

You are the second reviewer in a chain. An Ollama model has already reviewed these contracts. Your job is to:
1. Find issues Ollama missed
2. Validate or challenge Ollama's findings
3. Focus on MML correctness and frame conditions

## Ollama's Review Results

[PASTE OLLAMA'S RESPONSE FROM evidence/phase2-ollama-response.md HERE]

---

## Claude-Specific MML Review Checklist

- [ ] MML model queries correctly represent collection semantics
- [ ] Frame conditions use `|=|` for model equality (not reference equality)
- [ ] Postconditions use `old` expressions correctly with MML
- [ ] Model queries are pure (no side effects)
- [ ] MML types match collection types (MML_SET for sets, MML_SEQUENCE for lists, MML_MAP for tables)
- [ ] All collection mutations have frame conditions

## Contracts to Review

(Same contracts as Ollama prompt - see phase2-ollama-review.md for full content)

### Key Classes with MML

**DOT_ATTRIBUTES** - `attributes_model: MML_MAP [STRING, STRING]`
```eiffel
put (a_key, a_value: STRING)
    ensure
        others_unchanged: attributes_model.removed (a_key).domain |=| old attributes_model.removed (a_key).domain
```

**DOT_GRAPH** - Multiple MML models:
```eiffel
nodes_model: MML_SEQUENCE [DOT_NODE]
edges_model: MML_SEQUENCE [DOT_EDGE]
subgraphs_model: MML_SEQUENCE [DOT_SUBGRAPH]
node_ids_model: MML_SET [STRING]

add_node ensure:
    edges_unchanged: edges_model |=| old edges_model
    subgraphs_unchanged: subgraphs_model |=| old subgraphs_model

add_edge ensure:
    nodes_unchanged: nodes_model |=| old nodes_model
    subgraphs_unchanged: subgraphs_model |=| old subgraphs_model
```

**DOT_SUBGRAPH** - Similar pattern:
```eiffel
nodes_model: MML_SEQUENCE [DOT_NODE]
edges_model: MML_SEQUENCE [DOT_EDGE]

add_node ensure:
    edges_unchanged: edges_model |=| old edges_model

add_edge ensure:
    nodes_unchanged: nodes_model |=| old nodes_model
```

**STATE_MACHINE_BUILDER** - `states_model: MML_SET [STRING]`

## Implementation Approach

(See phase2-ollama-review.md for full approach)

## Questions to Consider

1. Is the `|=|` operator being used correctly for frame conditions?
2. Are the `old` expressions capturing the right state?
3. Should postconditions be stronger (e.g., specify exactly what was added)?
4. Are there missing model queries for any collections?
5. Is the XOR invariant on GRAPHVIZ_RESULT sufficient?

## Output Format

List issues found as:
- **ISSUE**: [description]
- **LOCATION**: [class.feature]
- **SEVERITY**: [HIGH/MEDIUM/LOW]
- **AGREES WITH OLLAMA**: [yes/no/partially]
- **SUGGESTION**: [how to fix]

Also provide a summary comparing your findings to Ollama's.
