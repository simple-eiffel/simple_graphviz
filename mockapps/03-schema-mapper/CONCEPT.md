# SchemaMap - Database Schema Mapper

## Executive Summary

SchemaMap is a CLI-first database schema visualization tool that generates Entity-Relationship diagrams and data flow visualizations from live database connections or DDL files. It provides DBAs, data engineers, and backend developers with always-current schema documentation that updates automatically as databases evolve.

Database schemas are living documents that change with every migration. Traditional ER diagram tools create static snapshots that become outdated within days, leading to incorrect assumptions about data relationships and costly development mistakes. SchemaMap solves this by treating database schemas as the source of truth and generating diagrams on demand, either from live connections or from DDL/migration files in version control.

Built on simple_graphviz and leveraging simple_sql for database connectivity, SchemaMap produces enterprise-grade SVG, PDF, and PNG diagrams suitable for technical documentation, data dictionaries, and compliance audits. Its CLI interface integrates into migration scripts and CI/CD pipelines, ensuring schema documentation stays synchronized with the actual database.

## Problem Statement

**The problem:** Database schemas evolve constantly through migrations, yet schema documentation rarely keeps pace. Teams rely on outdated ER diagrams that mislead developers about actual relationships, missing foreign keys, and deprecated tables. New team members learn the wrong model, queries are written against imagined relationships, and data integrity issues go undetected until production incidents occur.

**Current solutions:**
- **Database IDE tools** (DBeaver, DataGrip): Require manual export, no automation
- **ER diagram tools** (dbdiagram.io, DrawSQL): Manual maintenance, divorced from actual schema
- **Reverse engineering tools** (MySQL Workbench, pgModeler): Platform-specific, heavyweight
- **Documentation generators** (SchemaSpy): Java-based, complex setup, outdated technology

**Our approach:** SchemaMap connects directly to your database (or reads your DDL files) and generates accurate diagrams instantly. Run it after migrations to update documentation automatically. Run it in CI to catch schema drift. Run it before reviews to ensure everyone sees the current state. No manual maintenance - your database IS your documentation source.

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: Database Administrator | Manages database structure, migrations | Accurate current-state diagrams, change tracking |
| Primary: Data Engineer | Builds data pipelines, understands data flow | Cross-database views, relationship mapping |
| Secondary: Backend Developer | Writes queries, designs data models | Quick reference, relationship understanding |
| Secondary: Data Analyst | Queries databases, builds reports | Table discovery, column documentation |
| Secondary: Compliance Officer | Audits data structures | Point-in-time documentation, change history |

## Value Proposition

**For** database administrators and data engineers
**Who** need accurate, current schema documentation
**This app** generates ER diagrams directly from database connections
**Unlike** manual diagramming or platform-specific IDE features
**We** support all major databases with consistent, automated output

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Open Source Core | Full CLI, DDL parsing, all formats | Free |
| Pro License | Live database connections, scheduled refresh | $19/user/month |
| Enterprise | Multi-database, cross-database relationships, audit trail | $99/user/month |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to first diagram | < 3 minutes | From install to visualization |
| Database coverage | 5+ databases | PostgreSQL, MySQL, SQLite, SQL Server, Oracle |
| Schema accuracy | 100% | All tables, columns, relationships captured |
| Migration integration | < 10 minutes | Time to add to migration workflow |
| Documentation freshness | Real-time | Diagrams always match current schema |
