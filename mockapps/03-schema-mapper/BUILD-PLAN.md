# SchemaMap - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI - SQLite + PostgreSQL | 4-5 days | simple_graphviz, simple_sql, simple_cli |
| Phase 2 | Multi-database + DDL parsing | 3-4 days | Phase 1 + additional extractors |
| Phase 3 | Advanced features | 3-4 days | Phase 2 + simple_diff, simple_template |
| Phase 4 | Production polish | 2-3 days | Phase 3 complete |

---

## Phase 1: MVP

### Objective

Deliver a working CLI that can connect to SQLite and PostgreSQL databases and generate ER diagrams. SQLite requires no server setup (great for development), and PostgreSQL is the most common open-source production database.

### Deliverables

1. **SCHEMAMAP_CLI** - Main entry point with argument parsing
2. **SCHEMAMAP_ENGINE** - Core orchestration logic
3. **SCHEMA_MODEL** - Universal schema representation
4. **TABLE_MODEL, COLUMN_MODEL, RELATIONSHIP_MODEL** - Model components
5. **SQLITE_EXTRACTOR** - Extract schema from SQLite
6. **POSTGRESQL_EXTRACTOR** - Extract schema from PostgreSQL
7. **ER_DIAGRAM_GENERATOR** - Create ER diagrams
8. **SCHEMAMAP_CONFIG** - Configuration handling

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, test target passes |
| T1.2 | Implement SCHEMAMAP_CLI | `schemamap --help` shows usage |
| T1.3 | Implement SCHEMA_MODEL hierarchy | Tables, columns, relationships modeled |
| T1.4 | Implement SQLITE_EXTRACTOR | Extracts tables, columns, FKs from SQLite |
| T1.5 | Implement POSTGRESQL_EXTRACTOR | Extracts tables, columns, FKs from PostgreSQL |
| T1.6 | Implement SCHEMAMAP_ENGINE | Orchestrates extraction and generation |
| T1.7 | Implement ER_DIAGRAM_GENERATOR | Creates record-style ER diagrams |
| T1.8 | Add output format options | `-f svg/pdf/png` works correctly |
| T1.9 | Add `--focus` option | Generates focused diagram on one table |
| T1.10 | Implement `schemamap analyze` | Shows schema structure |
| T1.11 | Write MVP tests | All test cases pass |
| T1.12 | Write MVP documentation | README with quickstart |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC1.1 | `schemamap --help` | Help text displayed, exit 0 |
| TC1.2 | `schemamap generate -u sqlite:///test.db` | ER diagram SVG created |
| TC1.3 | `schemamap generate -u postgresql://... -s public` | PostgreSQL ER diagram |
| TC1.4 | `schemamap generate --focus users` | Diagram centered on users table |
| TC1.5 | `schemamap analyze -u sqlite:///test.db` | Schema analysis output |
| TC1.6 | `schemamap generate -u invalid://` | Error message, exit 1 |
| TC1.7 | `schemamap generate -t users,orders` | Filtered diagram |

### Phase 1 Exit Criteria

- [ ] SQLite schema extraction works
- [ ] PostgreSQL schema extraction works
- [ ] Foreign keys detected and visualized
- [ ] ER diagrams generated correctly
- [ ] SVG, PDF, PNG output works
- [ ] Error handling for common cases
- [ ] All MVP tests pass

---

## Phase 2: Multi-Database + DDL

### Objective

Add support for MySQL, SQL Server, and Oracle databases. Also add DDL file parsing so diagrams can be generated without database access - useful for CI/CD and documentation from migration files.

### Deliverables

1. **MYSQL_EXTRACTOR** - Extract schema from MySQL/MariaDB
2. **SQLSERVER_EXTRACTOR** - Extract schema from SQL Server
3. **ORACLE_EXTRACTOR** - Extract schema from Oracle
4. **DDL_PARSER** - Parse CREATE TABLE statements
5. **CONNECTION_MANAGER** - Named connection storage
6. **RELATIONSHIP_INFERRER** - Detect implicit FKs by naming

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement MYSQL_EXTRACTOR | Extracts schema from MySQL 5.7+ |
| T2.2 | Implement SQLSERVER_EXTRACTOR | Extracts schema from SQL Server 2017+ |
| T2.3 | Implement ORACLE_EXTRACTOR | Extracts schema from Oracle 19c+ |
| T2.4 | Implement DDL_PARSER | Parses CREATE TABLE, ALTER TABLE |
| T2.5 | Implement CONNECTION_MANAGER | Store/retrieve named connections |
| T2.6 | Implement `schemamap connections` | Add, list, remove, test connections |
| T2.7 | Implement RELATIONSHIP_INFERRER | Detect user_id -> users.id patterns |
| T2.8 | Add `--infer-relationships` flag | Enable implicit FK detection |
| T2.9 | Add environment variable expansion | ${VAR} in connection URLs |
| T2.10 | Write Phase 2 tests | All test cases pass |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC2.1 | `schemamap generate -u mysql://...` | MySQL ER diagram |
| TC2.2 | `schemamap generate -u sqlserver://...` | SQL Server ER diagram |
| TC2.3 | `schemamap generate -d ./schema.sql` | ER diagram from DDL |
| TC2.4 | `schemamap connections add prod "..."` | Connection saved |
| TC2.5 | `schemamap generate -c prod` | Uses saved connection |
| TC2.6 | `schemamap generate --infer-relationships` | Implicit FKs shown |
| TC2.7 | `schemamap connections test prod` | Connection test result |

### Phase 2 Exit Criteria

- [ ] MySQL supported
- [ ] SQL Server supported
- [ ] Oracle supported
- [ ] DDL parsing works
- [ ] Named connections work
- [ ] Relationship inference works
- [ ] All Phase 2 tests pass

---

## Phase 3: Advanced Features

### Objective

Add power-user features: schema comparison, data flow diagrams, HTML documentation, export capabilities, and schema validation.

### Deliverables

1. **Compare Command** - Compare schemas between sources
2. **DATA_FLOW_GENERATOR** - Show data flow through tables
3. **HTML Report** - Generate HTML documentation
4. **Export Command** - Export as DDL/JSON/CSV
5. **Validate Command** - Validate schema conventions

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement `schemamap compare` | Shows schema differences |
| T3.2 | Implement DATA_FLOW_GENERATOR | Traces reference chains |
| T3.3 | Implement HTML output | Generates documentation with diagrams |
| T3.4 | Implement export to DDL | Creates CREATE TABLE statements |
| T3.5 | Implement export to JSON | Creates JSON schema definition |
| T3.6 | Implement export to CSV | Creates CSV of tables/columns |
| T3.7 | Implement `schemamap validate` | Checks naming conventions |
| T3.8 | Add `--show-indexes` flag | Include index information |
| T3.9 | Add theming support | `--theme dark/blueprint` |
| T3.10 | Write Phase 3 tests | All test cases pass |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TC3.1 | `schemamap compare --source dev --target prod` | Diff report |
| TC3.2 | `schemamap generate --show-data-flow` | Data flow diagram |
| TC3.3 | `schemamap generate -f html` | HTML documentation |
| TC3.4 | `schemamap export -c prod -f ddl` | DDL file |
| TC3.5 | `schemamap export -c prod -f json` | JSON schema |
| TC3.6 | `schemamap validate -c prod` | Validation report |

### Phase 3 Exit Criteria

- [ ] Compare command works
- [ ] Data flow diagrams work
- [ ] HTML output works
- [ ] Export works (DDL, JSON, CSV)
- [ ] Validation works
- [ ] All Phase 3 tests pass

---

## Phase 4: Production Polish

### Objective

Harden for production: comprehensive error handling, performance optimization, thorough documentation, and release preparation.

### Deliverables

1. Error handling hardening
2. Performance optimization for large schemas
3. Comprehensive help documentation
4. Man page generation
5. Release binaries

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T4.1 | Harden error handling | All error paths tested |
| T4.2 | Optimize for large schemas | <15s for 200-table schemas |
| T4.3 | Add connection pooling | Efficient repeated queries |
| T4.4 | Write comprehensive --help | Every option documented |
| T4.5 | Generate man page | `man schemamap` works |
| T4.6 | Create Windows installer | INNO setup works |
| T4.7 | Create Linux package | .deb and .rpm packages |
| T4.8 | Write user guide | Complete documentation |
| T4.9 | Final test sweep | All tests pass |
| T4.10 | Tag v1.0.0 release | GitHub release with binaries |

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
<target name="schemamap">
    <root class="SCHEMAMAP_ENGINE" feature="default_create"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <!-- All library dependencies -->
</target>

<!-- CLI executable target -->
<target name="schemamap_cli" extends="schemamap">
    <root class="SCHEMAMAP_CLI" feature="make"/>
    <setting name="executable_name" value="schemamap"/>
</target>

<!-- Test target -->
<target name="schemamap_tests" extends="schemamap">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench mode)
/d/prod/ec.sh -batch -config schemamap.ecf -target schemamap_cli -c_compile

# Compile CLI (finalized)
/d/prod/ec.sh -batch -config schemamap.ecf -target schemamap_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config schemamap.ecf -target schemamap_tests -c_compile
./EIFGENs/schemamap_tests/W_code/schemamap.exe

# Run finalized tests
/d/prod/ec.sh -batch -config schemamap.ecf -target schemamap_tests -finalize -c_compile
./EIFGENs/schemamap_tests/F_code/schemamap.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Databases | Database engines supported | 5+ |
| Performance | 200-table schema | < 15 seconds |
| Documentation | README + man page | Complete |
| Ecosystem integration | Libraries used | 8+ simple_* |
