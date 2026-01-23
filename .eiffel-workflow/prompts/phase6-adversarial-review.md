# Adversarial Test Suggestions for simple_graphviz

## Attack Vectors Identified

### 1. Boundary Values
- Empty strings for node/edge IDs
- Very long strings (stress DOT output buffer)
- Special characters in names: quotes, backslashes, newlines
- Unicode characters in labels
- Zero/negative values for numeric attributes

### 2. Capacity Limits
- Graphs with thousands of nodes
- Many edges between same pair of nodes
- Deep subgraph nesting
- Attribute collision (same key many times)

### 3. State Violations
- Adding duplicate nodes
- Adding edges to non-existent nodes (intentional DOT behavior)
- Accessing node by ID before any added
- Empty graph operations

### 4. Renderer Edge Cases
- Empty DOT string
- Invalid DOT syntax
- Very long DOT strings
- Binary data in DOT string
- Timeout with complex graphs

### 5. Fluent API Misuse
- Calling methods in unexpected order
- Chaining without using result
- Mixed builder usage

### 6. SCOOP Concurrent Access
- Multiple agents accessing same graph
- Concurrent node additions

## Tests to Generate

1. test_empty_node_id - Precondition violation expected
2. test_special_chars_in_labels - Should escape properly
3. test_stress_many_nodes - Performance/capacity
4. test_duplicate_node_precondition - Contract violation
5. test_deep_subgraph_nesting - Stack/recursion stress
6. test_renderer_empty_dot - Should handle gracefully
7. test_renderer_invalid_dot - Should return failure result
8. test_unicode_in_labels - Should escape/handle
9. test_very_long_names - Buffer handling
10. test_builder_reuse - Same builder multiple diagrams
