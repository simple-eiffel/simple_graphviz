# PipeDoc - Pipeline Documenter

## Executive Summary

PipeDoc is a CLI-first tool that automatically generates visual documentation from CI/CD pipeline definitions. It reads pipeline configuration files from GitHub Actions, GitLab CI, Azure DevOps, Jenkins, and other platforms, producing clear workflow diagrams that help teams understand, debug, and communicate their deployment processes.

Modern DevOps teams maintain complex multi-stage pipelines with conditional steps, parallel jobs, and cross-workflow dependencies. Understanding these pipelines from raw YAML is cognitively demanding, especially for team members new to the codebase or when debugging production issues under pressure. PipeDoc solves this by generating instant visual representations that make pipeline structure obvious at a glance.

Built on simple_graphviz and leveraging the simple_* ecosystem, PipeDoc integrates into existing development workflows. Run it locally for instant visualization, add it to CI for auto-updating documentation, or use watch mode for live pipeline development. Output formats include SVG for web documentation, PDF for stakeholder reports, and PNG for quick sharing.

## Problem Statement

**The problem:** CI/CD pipelines have grown from simple "build-test-deploy" to complex DAGs with dozens of jobs, conditional paths, matrix builds, and reusable workflows. Reading raw YAML to understand what happens when is slow, error-prone, and creates knowledge silos. When pipelines break, teams waste precious minutes deciphering configuration instead of fixing problems. New team members take days to understand deployment processes that could be explained in minutes with a diagram.

**Current solutions:**
- **Manual diagramming** (Lucidchart, draw.io): Time-consuming, instantly stale
- **Platform-specific visualizers** (GitHub Actions UI): Only work for that platform, require web access
- **Generic diagram-as-code** (Mermaid, PlantUML): Require learning DSL, manual maintenance
- **Pipeline-specific viewers** (Jenkins Blue Ocean): Platform-locked, inconsistent with others

**Our approach:** PipeDoc reads your actual pipeline definitions and generates diagrams automatically. No DSL to learn, no manual updates, no platform lock-in. Your pipeline YAML is the source of truth, and diagrams are derived artifacts that regenerate on every change. Cross-platform support means teams with mixed tooling get consistent visualization across all their pipelines.

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: DevOps Engineer | Builds and maintains CI/CD pipelines | Quick visualization, debugging support, documentation automation |
| Primary: Platform Engineer | Manages multi-project pipelines | Cross-project views, consistency checking |
| Secondary: Release Manager | Coordinates deployments | Stakeholder-friendly diagrams, release documentation |
| Secondary: Developer | Triggers and monitors pipelines | Understanding what runs, debugging failures |
| Secondary: Auditor | Reviews deployment processes | Compliance documentation, change tracking |

## Value Proposition

**For** DevOps and platform engineers
**Who** manage complex CI/CD pipelines across multiple projects
**This app** generates clear visual documentation automatically
**Unlike** manual diagrams or platform-specific visualizers
**We** support all major CI/CD platforms with consistent output

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Open Source Core | Full CLI, all platforms, all formats | Free |
| Team License | Multi-repo aggregation, history, notifications | $49/user/month |
| Enterprise | Cross-org views, SSO, audit logs, SLA | $99/user/month |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to first diagram | < 2 minutes | From install to visualization |
| Platform coverage | 5+ platforms | GitHub, GitLab, Azure, Jenkins, CircleCI |
| Diagram accuracy | 100% | All jobs and dependencies shown |
| CI integration time | < 15 minutes | Time to add to existing pipeline |
| Debug time reduction | 50% | Time to understand pipeline issues |
