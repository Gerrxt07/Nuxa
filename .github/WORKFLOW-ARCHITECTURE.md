# 🏗️ Workflow Architecture

This document explains how the workflows are connected and work together.

## 🔄 Workflow Integration

```
┌─────────────────────────────────────────────────────────────┐
│                     ESLint Workflow                         │ 
│                   (Reusable Workflow)                       │
│                                                             │
│  • Runs linting checks                                      │
│  • Generates reports                                        │
│  • Comments on PRs                                          │
│  • Can be called by other workflows                         │
└──────────────┬──────────────────────────┬───────────────────┘
               │                          │
               │ Called by                │ Called by
               ▼                          ▼
   ┌───────────────────────┐  ┌──────────────────────────┐
   │   CI Pipeline         │  │     Nightly Release      │
   │                       │  │                          │
   │  1. ESLint (reuse)    │  │  1. ESLint (reuse)       │
   │  2. Test & Build      │  │  2. Check Changes        │
   │  3. Type Check        │  │  3. Generate Changelog   │
   │                       │  │  4. Create Release       │
   └───────────────────────┘  └──────────────────────────┘
```

## 📊 Workflow Relationships

### Primary Workflows (Standalone)

**🔍 ESLint**
- Can run independently on push/PR
- Can be called by other workflows
- Provides reusable linting functionality

**🔒 CodeQL**
- Runs independently for security scanning
- No dependencies on other workflows

**🤖 Dependabot**
- Runs independently for dependency updates
- Creates PRs that trigger CI workflow

**🧹 Cache Cleanup**
- Runs independently on schedule
- Maintains cache health across all workflows

### Composite Workflows (Use Other Workflows)

**⚡ CI Pipeline**
```
Trigger: Push/PR
  ├─> 🔍 ESLint (reusable workflow)
  ├─> 🧪 Test & Build (depends on ESLint)
  └─> 📝 Type Check (parallel)
```

**🌙 Nightly Release**
```
Trigger: Schedule (2 AM UTC)
  ├─> 🔍 ESLint (reusable workflow)
  └─> 🚀 Check & Release (depends on ESLint, continues even if fails)
```

## 🎯 Trigger Matrix

| Workflow | Push | PR | Schedule | Manual | Called By |
|----------|------|-----|----------|--------|-----------|
| ESLint | ✅ | ✅ | ❌ | ✅ | CI, Nightly |
| CI Pipeline | ✅ | ✅ | ❌ | ✅ | - |
| Nightly Release | ❌ | ❌ | ✅ (2 AM) | ✅ | - |
| CodeQL | ✅ | ✅ | ✅ (Mon 4 AM) | ✅ | - |
| Cache Cleanup | ❌ | ❌ | ✅ (Sun 1 AM) | ✅ | - |
| Dependabot | ❌ | ❌ | ✅ (Mon 3 AM) | ❌ | - |

## 🔐 Permission Requirements

### ESLint Workflow
```yaml
permissions:
  contents: read        # Read repository code
  pull-requests: write  # Comment on PRs
  checks: write        # Create check runs
```

### CI Pipeline
```yaml
permissions:
  contents: read        # Read repository code
  pull-requests: write  # Comment on PRs
  checks: write        # Create check runs
```

### Nightly Release
```yaml
permissions:
  contents: write       # Create releases and tags
  issues: read         # Read issue data
  pull-requests: read  # Read PR data
  checks: write        # Run ESLint checks
```

### CodeQL
```yaml
permissions:
  actions: read         # Read workflow data
  contents: read       # Read repository code
  security-events: write # Upload security results
  pull-requests: read  # Analyze PRs
```

## 📦 Cache Sharing

All workflows share the same cache keys for efficiency:

```yaml
# Dependency Cache (shared across all workflows)
Key: ${{ runner.os }}-bun-${{ hashFiles('**/bun.lockb', '**/package.json') }}
Paths:
  - ~/.bun/install/cache
  - node_modules

# Build Cache (CI specific)
Key: ${{ runner.os }}-build-${{ github.sha }}
Paths:
  - .nuxt
  - .output
  - dist

# Nuxa Cache (Nightly Release specific)
Key: ${{ runner.os }}-nuxa-${{ hashFiles('**/bun.lockb', '**/package.json') }}
Paths:
  - ~/.bun/install/cache
  - node_modules
  - .nuxt
  - .output
```

## 🎨 Design Patterns

### 1. Reusable Workflow Pattern
**ESLint** is designed as a reusable workflow that can be called by other workflows:

```yaml
# In eslint.yml
on:
  workflow_call:
    outputs:
      lint-status:
        value: ${{ jobs.lint.outputs.status }}

# In ci.yml or nightly-dev-release.yml
jobs:
  eslint:
    uses: ./.github/workflows/eslint.yml
    permissions:
      contents: read
      pull-requests: write
      checks: write
```

**Benefits:**
- ✅ Single source of truth for linting
- ✅ Consistent behavior across workflows
- ✅ Easier maintenance
- ✅ Reduced duplication

### 2. Conditional Continuation Pattern
**Nightly Release** continues even if ESLint fails:

```yaml
jobs:
  eslint:
    uses: ./.github/workflows/eslint.yml
  
  check-and-release:
    needs: eslint
    if: always() # Continue even if ESLint fails
```

**Benefits:**
- ✅ Dev releases aren't blocked by linting issues
- ✅ Linting status is still checked and reported
- ✅ Encourages fixing issues without blocking releases

### 3. Dependency Chain Pattern
**CI Pipeline** blocks on ESLint success:

```yaml
jobs:
  eslint:
    uses: ./.github/workflows/eslint.yml
  
  test:
    needs: eslint # Only runs if ESLint passes
```

**Benefits:**
- ✅ Prevents running expensive tests on broken code
- ✅ Faster feedback on linting issues
- ✅ Saves CI minutes

## 🚀 Execution Flow Examples

### Example 1: Push to Main Branch

```
1. Push detected
   ├─> ESLint Workflow (standalone)
   ├─> CI Pipeline
   │   ├─> ESLint (reusable)
   │   ├─> Test & Build (after ESLint)
   │   └─> Type Check (parallel)
   └─> CodeQL (parallel)
```

### Example 2: Pull Request

```
1. PR created/updated
   ├─> ESLint Workflow (standalone)
   │   └─> Comments on PR with results
   ├─> CI Pipeline
   │   ├─> ESLint (reusable)
   │   │   └─> Comments on PR with results
   │   ├─> Test & Build (after ESLint)
   │   └─> Type Check (parallel)
   └─> CodeQL (parallel)
```

### Example 3: Nightly at 2 AM UTC

```
1. Schedule trigger
   └─> Nightly Release
       ├─> ESLint (reusable)
       └─> Check & Release (continues even if ESLint fails)
           ├─> Check for changes
           ├─> Generate changelog
           └─> Create release (if changes found)
```

## 💡 Best Practices

1. **Reusability**: Use `workflow_call` for workflows that are used multiple times
2. **Caching**: Share cache keys across workflows for efficiency
3. **Permissions**: Use minimal required permissions for security
4. **Conditional Execution**: Use `if: always()` when you want to continue despite failures
5. **Dependencies**: Use `needs:` to create execution order
6. **Path Filtering**: Use `paths:` to avoid unnecessary workflow runs

## 🔧 Maintenance Tips

- **Adding New Workflows**: Consider if they should be reusable
- **Modifying ESLint**: Changes affect CI and Nightly Release
- **Cache Keys**: Keep them consistent across workflows
- **Permissions**: Review regularly and use least privilege
- **Documentation**: Update this file when architecture changes

---

*Last updated: 2025-10-27*
