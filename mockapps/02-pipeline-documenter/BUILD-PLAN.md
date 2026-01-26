# PipeDoc - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI - GitHub Actions | 3-4 days | simple_graphviz, simple_yaml, simple_cli |
| Phase 2 | Multi-platform support | 3-4 days | Phase 1 + additional parsers |
| Phase 3 | Advanced features | 3-4 days | Phase 2 + simple_watcher, simple_diff |
| Phase 4 | Production polish | 2-3 days | Phase 3 complete |

---

## Phase 1: MVP

### Objective

Deliver a working CLI that can parse GitHub Actions workflows and generate workflow diagrams. GitHub Actions is the most popular CI/CD platform, making it the highest-value starting point.

### Deliverables

1. **PIPEDOC_CLI** - Main entry point with argument parsing
2. **PIPEDOC_ENGINE** - Core orchestration logic
3. **GITHUB_ACTIONS_PARSER** - Parse .github/workflows/*.yml
4. **WORKFLOW_DIAGRAM_GENERATOR** - Create workflow visualizations
5. **PIPELINE_MODEL** - Universal pipeline representation
6. **PIPEDOC_CONFIG** - Basic configuration handling

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, test target passes |
| T1.2 | Implement PIPEDOC_CLI | `pipedoc --help` shows usage |
| T1.3 | Implement PIPELINE_MODEL | Can represent jobs, stages, dependencies |
| T1.4 | Implement GITHUB_ACTIONS_PARSER | Parses workflows, extracts jobs, needs |
| T1.5 | Implement PIPEDOC_ENGINE | Orchestrates parsing and generation |
| T1.6 | Implement WORKFLOW_DIAGRAM_GENERATOR | Creates flowchart-style diagrams |
| T1.7 | Add output format options | `-f svg/pdf/png` works correctly |
| T1.8 | Add style options | `-s full/compact/minimal` works |
| T1.9 | Implement `pipedoc list` | Lists detected workflows |
| T1.10 | Write MVP tests | All test cases pass |
| T1.11 | Write MVP documentation | README with quickstart |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC1.1 | `pipedoc --help` | Help text displayed, exit 0 |
| TC1.2 | `pipedoc generate` (in repo with .github/workflows) | Workflow diagrams created |
| TC1.3 | `pipedoc generate -p .github/workflows/ci.yml` | Single workflow diagram |
| TC1.4 | `pipedoc generate -f pdf` | PDF output |
| TC1.5 | `pipedoc list` | Shows detected workflows |
| TC1.6 | `pipedoc analyze` | Pipeline structure analysis |
| TC1.7 | `pipedoc generate -p ./nonexistent` | Error message, exit 1 |

### Phase 1 Exit Criteria

- [ ] GitHub Actions workflows parsed correctly
- [ ] Job dependencies visualized
- [ ] Triggers shown
- [ ] SVG, PDF, PNG output works
- [ ] Error handling for common cases
- [ ] All MVP tests pass

---

## Phase 2: Multi-Platform Support

### Objective

Extend parser support to GitLab CI, Azure Pipelines, Jenkins, and CircleCI. This covers the major enterprise CI/CD platforms and maximizes market reach.

### Deliverables

1. **GITLAB_CI_PARSER** - Parse .gitlab-ci.yml
2. **AZURE_PIPELINES_PARSER** - Parse azure-pipelines.yml
3. **JENKINS_PARSER** - Parse declarative Jenkinsfile
4. **CIRCLECI_PARSER** - Parse .circleci/config.yml
5. **PLATFORM_DETECTOR** - Auto-detect platform from files
6. **Enhanced PIPELINE_MODEL** - Support platform-specific features

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement GITLAB_CI_PARSER | Parses stages, jobs, needs, rules |
| T2.2 | Implement AZURE_PIPELINES_PARSER | Parses stages, jobs, dependsOn |
| T2.3 | Implement JENKINS_PARSER | Parses declarative pipeline stages |
| T2.4 | Implement CIRCLECI_PARSER | Parses jobs, workflows, requires |
| T2.5 | Implement PLATFORM_DETECTOR | Auto-detects from file presence |
| T2.6 | Add `--platform` override | Force specific platform parser |
| T2.7 | Add `--include-steps` flag | Show job steps in diagram |
| T2.8 | Add `--show-conditions` flag | Show conditional paths |
| T2.9 | Implement .pipedoc.yaml config | Configuration file support |
| T2.10 | Write Phase 2 tests | All test cases pass |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC2.1 | `pipedoc generate -p .gitlab-ci.yml` | GitLab CI diagram |
| TC2.2 | `pipedoc generate -p azure-pipelines.yml` | Azure Pipelines diagram |
| TC2.3 | `pipedoc generate -p Jenkinsfile` | Jenkins diagram |
| TC2.4 | `pipedoc generate -p .circleci/config.yml` | CircleCI diagram |
| TC2.5 | `pipedoc generate` (mixed platforms) | Correct auto-detection |
| TC2.6 | `pipedoc generate --include-steps` | Steps shown in diagram |
| TC2.7 | `pipedoc generate --show-conditions` | Conditions visualized |

### Phase 2 Exit Criteria

- [ ] GitLab CI supported
- [ ] Azure Pipelines supported
- [ ] Jenkins (declarative) supported
- [ ] CircleCI supported
- [ ] Auto-detection works
- [ ] All Phase 2 tests pass

---

## Phase 3: Advanced Features

### Objective

Add power-user features: watch mode for live updates, compare command for pipeline diffing, highlighting for debugging, and HTML documentation output.

### Deliverables

1. **Watch Mode** - Auto-regenerate on file changes
2. **Compare Command** - Diff pipelines between versions
3. **Job Highlighting** - Highlight specific jobs and dependencies
4. **HTML Report** - Generate HTML documentation with diagrams
5. **Validation Command** - Check pipeline syntax

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement `pipedoc watch` | Regenerates on file change |
| T3.2 | Implement `pipedoc compare` | Shows pipeline differences |
| T3.3 | Implement `--highlight` option | Highlights job and deps |
| T3.4 | Implement HTML output | Generates documentation with diagrams |
| T3.5 | Implement `pipedoc validate` | Checks syntax, reports errors |
| T3.6 | Add theme support | `--theme github/gitlab/dark` |
| T3.7 | Add matrix build visualization | Show matrix expansions |
| T3.8 | Write Phase 3 tests | All test cases pass |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC3.1 | `pipedoc watch` | Regenerates on workflow change |
| TC3.2 | `pipedoc compare main feature` | Shows added/removed jobs |
| TC3.3 | `pipedoc generate --highlight deploy` | Deploy job highlighted |
| TC3.4 | `pipedoc generate -f html` | HTML report with diagrams |
| TC3.5 | `pipedoc validate` | Reports syntax issues |

### Phase 3 Exit Criteria

- [ ] Watch mode works
- [ ] Compare command works
- [ ] Highlighting works
- [ ] HTML output works
- [ ] Validation works
- [ ] All Phase 3 tests pass

---

## Phase 4: Production Polish

### Objective

Harden for production: comprehensive error handling, performance optimization, thorough documentation, and release preparation.

### Deliverables

1. Error handling hardening
2. Performance optimization for large workflows
3. Comprehensive help documentation
4. Man page generation
5. Release binaries

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T4.1 | Harden error handling | All error paths tested |
| T4.2 | Optimize for large workflows | <10s for 50-job workflows |
| T4.3 | Write comprehensive --help | Every option documented |
| T4.4 | Generate man page | `man pipedoc` works |
| T4.5 | Create Windows installer | INNO setup works |
| T4.6 | Create Linux package | .deb and .rpm packages |
| T4.7 | Write user guide | Complete documentation |
| T4.8 | Final test sweep | All tests pass |
| T4.9 | Tag v1.0.0 release | GitHub release with binaries |

### Phase 4 Exit Criteria

- [ ] No unhandled error paths
- [ ] Performance acceptable
- [ ] Documentation complete
- [ ] Release artifacts ready
- [ ] Version 1.0.0 tagged

---

## ECF Target Structure

```xml
<!-- Library target (reusable core) -->
<target name="pipedoc">
    <root class="PIPEDOC_ENGINE" feature="default_create"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <!-- All library dependencies -->
</target>

<!-- CLI executable target -->
<target name="pipedoc_cli" extends="pipedoc">
    <root class="PIPEDOC_CLI" feature="make"/>
    <setting name="executable_name" value="pipedoc"/>
</target>

<!-- Test target -->
<target name="pipedoc_tests" extends="pipedoc">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench mode)
/d/prod/ec.sh -batch -config pipedoc.ecf -target pipedoc_cli -c_compile

# Compile CLI (finalized)
/d/prod/ec.sh -batch -config pipedoc.ecf -target pipedoc_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config pipedoc.ecf -target pipedoc_tests -c_compile
./EIFGENs/pipedoc_tests/W_code/pipedoc.exe

# Run finalized tests
/d/prod/ec.sh -batch -config pipedoc.ecf -target pipedoc_tests -finalize -c_compile
./EIFGENs/pipedoc_tests/F_code/pipedoc.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Platforms | CI/CD platforms supported | 5+ |
| Performance | 50-job workflow | < 10 seconds |
| Documentation | README + man page | Complete |
| Ecosystem integration | Libraries used | 7+ simple_* |
