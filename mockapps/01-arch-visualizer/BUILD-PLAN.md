# ArchViz - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI - Eiffel ECF support | 3-4 days | simple_graphviz, simple_xml, simple_cli |
| Phase 2 | Multi-format support | 2-3 days | Phase 1 + simple_json, simple_yaml |
| Phase 3 | Advanced features | 3-4 days | Phase 2 + simple_watcher, simple_diff |
| Phase 4 | Production polish | 2-3 days | Phase 3 complete |

---

## Phase 1: MVP

### Objective

Deliver a working CLI that can parse Eiffel ECF files and generate dependency and hierarchy diagrams. This proves the core value proposition: automatic diagram generation from project files.

### Deliverables

1. **ARCHVIZ_CLI** - Main entry point with argument parsing
2. **ARCHVIZ_ENGINE** - Core orchestration logic
3. **ECF_PROJECT_PARSER** - Enhanced ECF parsing (extends simple_graphviz's ECF_PARSER)
4. **DEPENDENCY_DIAGRAM_GENERATOR** - Create dependency graphs
5. **HIERARCHY_DIAGRAM_GENERATOR** - Create inheritance hierarchies
6. **ARCHVIZ_CONFIG** - Basic configuration handling

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, test target passes |
| T1.2 | Implement ARCHVIZ_CLI | `archviz --help` shows usage |
| T1.3 | Implement ECF_PROJECT_PARSER | Parses ECF files, extracts targets/clusters/libraries |
| T1.4 | Implement ARCHVIZ_ENGINE | Orchestrates parsing and generation |
| T1.5 | Implement dependency diagram | `archviz generate -t deps` produces SVG |
| T1.6 | Implement hierarchy diagram | `archviz generate -t hierarchy` produces SVG |
| T1.7 | Add output format options | `-f svg/pdf/png` works correctly |
| T1.8 | Add verbose/quiet modes | `-v` and `-q` control output |
| T1.9 | Write MVP tests | All test cases pass |
| T1.10 | Write MVP documentation | README with quickstart |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC1.1 | `archviz --help` | Help text displayed, exit 0 |
| TC1.2 | `archviz generate -p ./simple_graphviz` | Dependency + hierarchy SVGs created |
| TC1.3 | `archviz generate -t deps` | Only dependency diagram created |
| TC1.4 | `archviz generate -t hierarchy -f pdf` | PDF hierarchy diagram created |
| TC1.5 | `archviz generate -p ./nonexistent` | Error message, exit 1 |
| TC1.6 | `archviz analyze -p ./simple_graphviz` | Project analysis printed to stdout |

### Phase 1 Exit Criteria

- [ ] ECF files parsed correctly
- [ ] Dependency diagrams generated
- [ ] Hierarchy diagrams generated
- [ ] SVG, PDF, PNG output works
- [ ] Error handling for common cases
- [ ] All MVP tests pass

---

## Phase 2: Multi-Format Support

### Objective

Extend parser support to handle NPM, Maven, and Python projects, plus add YAML/JSON configuration support. This expands the addressable market significantly.

### Deliverables

1. **NPM_PROJECT_PARSER** - Parse package.json
2. **MAVEN_PROJECT_PARSER** - Parse pom.xml
3. **PYTHON_PROJECT_PARSER** - Parse requirements.txt, pyproject.toml
4. **GENERIC_PROJECT_PARSER** - Parse custom YAML/JSON definitions
5. **PROJECT_DETECTOR** - Auto-detect project type
6. **Enhanced ARCHVIZ_CONFIG** - YAML configuration file support

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement NPM_PROJECT_PARSER | Parses package.json dependencies |
| T2.2 | Implement MAVEN_PROJECT_PARSER | Parses pom.xml dependencies |
| T2.3 | Implement PYTHON_PROJECT_PARSER | Parses requirements.txt and pyproject.toml |
| T2.4 | Implement GENERIC_PROJECT_PARSER | Parses custom YAML/JSON dependency files |
| T2.5 | Implement PROJECT_DETECTOR | Auto-detects project type from files |
| T2.6 | Implement .archviz.yaml config | Loads and applies configuration |
| T2.7 | Add `archviz init` command | Creates default .archviz.yaml |
| T2.8 | Add `--no-externals` flag | Excludes external dependencies |
| T2.9 | Add `--depth` option | Limits dependency traversal depth |
| T2.10 | Write Phase 2 tests | All test cases pass |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC2.1 | `archviz generate -p ./npm-project` | Diagrams from package.json |
| TC2.2 | `archviz generate -p ./maven-project` | Diagrams from pom.xml |
| TC2.3 | `archviz generate -p ./python-project` | Diagrams from requirements.txt |
| TC2.4 | `archviz generate` in mixed project | Correct auto-detection |
| TC2.5 | `archviz init` | Creates .archviz.yaml |
| TC2.6 | `archviz generate --no-externals` | No external deps in diagram |

### Phase 2 Exit Criteria

- [ ] NPM projects supported
- [ ] Maven projects supported
- [ ] Python projects supported
- [ ] Auto-detection works
- [ ] Configuration file works
- [ ] All Phase 2 tests pass

---

## Phase 3: Advanced Features

### Objective

Add power-user features: watch mode for live updates, diff command for architecture comparison, caching for performance, and module diagrams for large projects.

### Deliverables

1. **Watch Mode** - Auto-regenerate on file changes
2. **Diff Command** - Compare architecture between commits
3. **Module Diagrams** - Higher-level module views
4. **Caching** - Cache parsed results for performance
5. **HTML Report** - Generate HTML documentation with diagrams

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement `archviz watch` | Regenerates diagrams on file change |
| T3.2 | Implement `archviz diff` | Shows architecture differences |
| T3.3 | Implement MODULE_DIAGRAM_GENERATOR | Creates module-level views |
| T3.4 | Implement caching layer | Faster repeat runs on large projects |
| T3.5 | Implement HTML report output | Generates documentation with embedded diagrams |
| T3.6 | Add `--group-by` option | Groups nodes by cluster/module |
| T3.7 | Add theming support | `--theme dark/minimal/corporate` |
| T3.8 | Write Phase 3 tests | All test cases pass |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC3.1 | `archviz watch -p ./project` | Regenerates on .ecf change |
| TC3.2 | `archviz diff main..feature` | Shows added/removed deps |
| TC3.3 | `archviz generate -t modules` | Module diagram created |
| TC3.4 | Repeat `archviz generate` | Second run faster (cached) |
| TC3.5 | `archviz generate -f html` | HTML report with diagrams |

### Phase 3 Exit Criteria

- [ ] Watch mode works
- [ ] Diff command works
- [ ] Module diagrams generated
- [ ] Caching improves performance
- [ ] HTML output works
- [ ] All Phase 3 tests pass

---

## Phase 4: Production Polish

### Objective

Harden the application for production use: comprehensive error handling, performance optimization, thorough documentation, and release preparation.

### Deliverables

1. Error handling hardening
2. Performance optimization for large projects
3. Comprehensive help documentation
4. Man page generation
5. Release binaries for Windows/Linux/macOS

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T4.1 | Harden error handling | All error paths tested and documented |
| T4.2 | Optimize for large projects | <30s for 100+ node projects |
| T4.3 | Write comprehensive --help | Every option documented |
| T4.4 | Generate man page | `man archviz` works |
| T4.5 | Create Windows installer | INNO setup works |
| T4.6 | Create Linux package | .deb and .rpm packages |
| T4.7 | Create macOS package | Homebrew formula |
| T4.8 | Write user guide | Complete documentation |
| T4.9 | Final test sweep | All tests pass, no regressions |
| T4.10 | Tag v1.0.0 release | GitHub release with binaries |

### Phase 4 Exit Criteria

- [ ] No unhandled error paths
- [ ] Performance acceptable for real projects
- [ ] Documentation complete
- [ ] Release artifacts ready
- [ ] Version 1.0.0 tagged

---

## ECF Target Structure

```xml
<!-- Library target (reusable core) -->
<target name="archviz">
    <root class="ARCHVIZ_ENGINE" feature="default_create"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <!-- All library dependencies -->
</target>

<!-- CLI executable target -->
<target name="archviz_cli" extends="archviz">
    <root class="ARCHVIZ_CLI" feature="make"/>
    <setting name="executable_name" value="archviz"/>
</target>

<!-- Test target -->
<target name="archviz_tests" extends="archviz">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench mode for development)
/d/prod/ec.sh -batch -config archviz.ecf -target archviz_cli -c_compile

# Compile CLI (finalized for release)
/d/prod/ec.sh -batch -config archviz.ecf -target archviz_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config archviz.ecf -target archviz_tests -c_compile
./EIFGENs/archviz_tests/W_code/archviz.exe

# Run finalized tests
/d/prod/ec.sh -batch -config archviz.ecf -target archviz_tests -finalize -c_compile
./EIFGENs/archviz_tests/F_code/archviz.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Performance | 100-node project | < 30 seconds |
| Documentation | README + man page | Complete |
| Error handling | All paths covered | 100% |
| Ecosystem integration | Libraries used | 8+ simple_* |
