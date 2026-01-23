# Eiffel Contract Review Request (Gemini)

You are the final reviewer in a chain. Three AIs have already reviewed these contracts:
1. Ollama - general contract review
2. Claude - MML and frame condition focus
3. Grok - edge cases and error handling

Your job is to:
1. Synthesize all findings
2. Identify any remaining gaps
3. Prioritize the most critical issues
4. Provide final recommendations

## Previous Review Results

### Ollama's Review

[PASTE OLLAMA'S RESPONSE FROM evidence/phase2-ollama-response.md HERE]

### Claude's Review

[PASTE CLAUDE'S RESPONSE FROM evidence/phase2-claude-response.md HERE]

### Grok's Review

[PASTE GROK'S RESPONSE FROM evidence/phase2-grok-response.md HERE]

---

## Gemini-Specific Review Focus

### Synthesis Questions
1. What issues did all reviewers agree on?
2. What issues were contested?
3. Are there any false positives (non-issues flagged as problems)?
4. What was missed by everyone?

### Architecture Review
- [ ] Is the class structure appropriate for the domain?
- [ ] Are responsibilities well-distributed?
- [ ] Is the fluent API pattern used consistently?
- [ ] Is the facade pattern implemented correctly?

### Contract Consistency
- [ ] Are similar features contracted similarly across classes?
- [ ] Are naming conventions consistent?
- [ ] Are postconditions proportional to complexity?

### Testability
- [ ] Can all contracts be tested?
- [ ] Are preconditions testable by callers?
- [ ] Are postconditions verifiable?

## Contracts Summary

(See phase2-ollama-review.md for full contracts)

## Output Format

### Part 1: Consensus Issues (All reviewers agree)
| Issue | Location | Severity | Fix Priority |
|-------|----------|----------|--------------|

### Part 2: Disputed Issues
| Issue | Ollama | Claude | Grok | Your Verdict |
|-------|--------|--------|------|--------------|

### Part 3: Missed Issues (New findings)
- **ISSUE**: [description]
- **LOCATION**: [class.feature]
- **SEVERITY**: [HIGH/MEDIUM/LOW]
- **SUGGESTION**: [how to fix]

### Part 4: Final Recommendations
Prioritized list of changes to make before implementation, grouped by:
1. **MUST FIX** - Correctness issues
2. **SHOULD FIX** - Completeness issues
3. **COULD FIX** - Improvement opportunities
