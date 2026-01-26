# ArchViz - Architecture Visualizer

## Executive Summary

ArchViz is a CLI-first architecture visualization tool that automatically generates multi-layer software architecture diagrams from project configuration files, source code, and dependency manifests. Unlike traditional diagramming tools that require manual updates, ArchViz treats diagrams as derived artifacts - generated fresh from the actual codebase on every build.

Built on the simple_graphviz library and leveraging multiple simple_* ecosystem components, ArchViz provides enterprise-grade SVG, PDF, and PNG output suitable for technical documentation, stakeholder presentations, and compliance audits. Its command-line interface integrates seamlessly into CI/CD pipelines, ensuring architecture documentation never becomes stale.

The tool supports multiple input formats including Eiffel ECF files, NPM package.json, Python requirements.txt, Maven POM files, and generic dependency YAML/JSON definitions. Output diagrams include class hierarchies, dependency graphs, module relationships, and custom architectural views.

## Problem Statement

**The problem:** Software architecture diagrams become outdated the moment they're created. Manual diagram maintenance is tedious, error-prone, and often deprioritized, leading to documentation that misleads rather than informs. Development teams waste hours in meetings explaining systems that are documented incorrectly, and new developers onboard slowly because they can't trust existing diagrams.

**Current solutions:** Teams use tools like Lucidchart, draw.io, or Visio to manually create diagrams. Some adopt "diagrams as code" tools like Structurizr or Mermaid, but these still require manual maintenance of a separate DSL. Enterprise tools like Sparx Enterprise Architect are expensive and heavyweight. PlantUML generates diagrams from code but lacks automation integration.

**Our approach:** ArchViz eliminates manual diagram maintenance entirely. It reads your actual project configuration - the ECF files, package manifests, and source code - and generates accurate diagrams on demand. Run it in CI/CD and your architecture docs update with every commit. Run it locally for instant visualization during development. The source of truth is your code, not a separate diagram file.

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: Software Architect | Designs system structure, communicates with stakeholders | Accurate, up-to-date architecture views; multiple abstraction levels |
| Primary: DevOps Engineer | Manages CI/CD, automates documentation | CLI integration, pipeline-friendly, scriptable |
| Secondary: Tech Lead | Oversees development, onboards team members | Quick visualization, dependency analysis |
| Secondary: Consultant | Delivers architecture assessments | Professional output, multiple formats |

## Value Proposition

**For** software architects and DevOps engineers
**Who** need accurate, current architecture documentation
**This app** generates diagrams automatically from project files
**Unlike** manual diagramming tools or heavyweight enterprise suites
**We** integrate into your build pipeline and update docs with every commit

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Open Source Core | Full CLI functionality, all diagram types | Free |
| Team License | Shared diagram repository, history, diff views | $29/user/month |
| Enterprise | Multi-project dashboards, SSO, audit logs | $99/user/month |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to first diagram | < 5 minutes | From install to generated output |
| CI/CD integration | < 30 minutes | Time to add to existing pipeline |
| Diagram accuracy | 100% | Matches actual dependencies |
| User adoption | 1000 GitHub stars in year 1 | Community engagement |
| Enterprise conversion | 5% of users | Free to paid conversion |
