# 🚀 GitHub Actions Workflows

This repository includes a comprehensive set of GitHub Actions workflows for automation, security, and continuous integration.

## 📋 Workflows Overview

### 🔍 ESLint (`eslint.yml`)
**Purpose**: Automated code quality and linting checks.

**Triggers**:
- 📤 Push to main/master/dev/develop branches (only on code changes)
- 🔀 Pull requests to main/master/dev/develop branches
- 🔄 Called by other workflows (CI, Nightly Release)
- 🖱️ Manual: Via workflow dispatch

**Features**:
- ✅ Runs ESLint on JavaScript/TypeScript/Vue files
- 📊 Generates detailed JSON reports
- 💬 Comments on PRs with results
- 📤 Uploads reports as artifacts (30-day retention)
- ⚡ Cached dependencies for faster execution
- 🎯 Smart path filtering (only runs on relevant file changes)
- 🔄 Reusable workflow that can be called by other workflows

**Cache Strategy**:
- Caches Bun install cache and node_modules
- Key: `${{ runner.os }}-bun-${{ hashFiles('**/bun.lockb', '**/package.json') }}`

---

### 🌙 Nightly Dev Release (`nightly-dev-release.yml`)
**Purpose**: Automatically creates nightly development releases with detailed changelogs.

**Triggers**:
- 🕐 Scheduled: Every night at 2 AM UTC
- 🖱️ Manual: Via workflow dispatch

**Features**:
- ✅ Smart change detection (only releases if there are changes)
- 📝 Automatic changelog generation with commits, PRs, and issues
- 🔗 Direct links to all referenced items
- 📦 Source code archive included
- 🏷️ Tagged as `dev-YYYYMMDD`
- ⚡ Cached dependencies for faster execution
- 🔍 Runs ESLint before release (continues even if linting fails)

**Cache Strategy**:
- Caches Bun install cache, node_modules, .nuxt, and .output
- Key: `${{ runner.os }}-nuxa-${{ hashFiles('**/bun.lockb', '**/package.json') }}`

---

### 🔒 CodeQL Security Analysis (`codeql.yml`)
**Purpose**: Automated security vulnerability scanning and code quality analysis.

**Triggers**:
- 📤 Push to main/master/dev/develop branches
- 🔀 Pull requests to main/master/dev/develop branches
- 🕐 Scheduled: Every Monday at 4 AM UTC
- 🖱️ Manual: Via workflow dispatch

**Features**:
- 🔍 Analyzes JavaScript/TypeScript code
- 🛡️ Security and quality queries enabled
- 📊 SARIF results uploaded to GitHub Security tab
- ⚡ Cached dependencies for faster scans
- 🚫 Ignores test files and build outputs

**Cache Strategy**:
- Caches Bun install cache and node_modules
- Key: `${{ runner.os }}-bun-${{ hashFiles('**/bun.lockb', '**/package.json') }}`

---

### ⚡ CI Pipeline (`ci.yml`)
**Purpose**: Continuous integration with linting, testing, and building.

**Triggers**:
- 📤 Push to main/master/dev/develop branches
- 🔀 Pull requests to main/master/dev/develop branches
- 🖱️ Manual: Via workflow dispatch

**Jobs**:
1. **ESLint** (Reusable Workflow):
   - 🔍 Calls the ESLint workflow
   - 💬 Comments on PRs with results
   - ❌ Blocks merge if errors found

2. **Test & Build**:
   - 🧪 Runs test suite (if configured)
   - 🏗️ Builds the project
   - 📦 Caches build output
   - ⏭️ Runs after ESLint passes

3. **Type Check**:
   - 📝 Runs TypeScript type checking
   - ✅ Validates type safety

**Cache Strategy**:
- Dependencies: `${{ runner.os }}-bun-${{ hashFiles('**/bun.lockb', '**/package.json') }}`
- Build output: `${{ runner.os }}-build-${{ github.sha }}`

---

### 🧹 Cache Cleanup (`cache-cleanup.yml`)
**Purpose**: Automatically removes old caches to optimize storage.

**Triggers**:
- 🕐 Scheduled: Every Sunday at 1 AM UTC
- 🖱️ Manual: Via workflow dispatch

**Features**:
- 🗑️ Deletes caches older than 7 days
- 💾 Reports freed storage space
- 📊 Detailed summary of cleanup operations

---

### 🤖 Dependabot (`dependabot.yml`)
**Purpose**: Automated dependency updates with smart grouping.

**Schedule**: Weekly on Mondays at 3 AM UTC

**Dependency Groups**:
- **Nuxt Core**: Nuxt, Vue, Vite, Nitro
- **UI Dependencies**: Tailwind, shadcn, Nuxt UI, icons, fonts
- **Auth & Security**: Clerk, security modules, Turnstile
- **Data Management**: Prisma, Pinia, Supabase
- **Content & SEO**: Content module, sitemap, robots, SEO
- **Integrations**: PostHog, Stripe, Apollo, Scalar
- **Utilities**: GSAP, i18n, image, color-mode
- **Dev Dependencies**: All development packages

**Features**:
- 🏷️ Auto-labels PRs with relevant tags
- 👤 Auto-assigns to repository owner
- 📝 Consistent commit message format
- 🔒 Ignores major version updates for Vue & Nuxt
- 📦 Supports NPM, Docker, and GitHub Actions

---

## 🎯 Cache Strategy Summary

All workflows use GitHub Actions cache to optimize performance:

| Workflow | Cached Items | Cache Key Pattern |
|----------|--------------|-------------------|
| Nightly Release | Bun cache, node_modules, .nuxt, .output | `nuxa-{lockfile-hash}` |
| CodeQL | Bun cache, node_modules | `bun-{lockfile-hash}` |
| CI Pipeline | Bun cache, node_modules, build output | `bun-{lockfile-hash}` + `build-{sha}` |

**Cache Benefits**:
- ⚡ Faster workflow execution
- 💰 Reduced GitHub Actions minutes usage
- 🔄 Consistent build environments

---

## 🛠️ Configuration

### Required Secrets
No additional secrets required! All workflows use the built-in `GITHUB_TOKEN`.

### Required Permissions
Workflows automatically request the following permissions:
- `contents: write` - For creating releases
- `issues: read` - For reading issue data
- `pull-requests: read/write` - For reading PR data
- `security-events: write` - For CodeQL results
- `actions: write` - For cache management

### Customization

**Change Schedule Times**:
Edit the `cron` expressions in each workflow file.

**Adjust Cache Retention**:
Modify the cache cleanup workflow to change the 7-day retention period.

**Add/Remove Dependency Groups**:
Edit `dependabot.yml` to customize dependency grouping.

---

## 📊 Monitoring

### View Workflow Runs
Navigate to: **Actions** tab → Select workflow

### View Security Alerts
Navigate to: **Security** tab → **Code scanning**

### View Releases
Navigate to: **Releases** section

### View Dependabot PRs
Navigate to: **Pull requests** tab → Filter by `dependencies` label

---

## 🎨 Workflow Design Philosophy

All workflows follow these principles:
- 🎯 **Clear naming** with emojis for visual scanning
- 📊 **Detailed summaries** in GitHub Actions UI
- ⚡ **Performance optimized** with caching
- 🔒 **Security first** with minimal permissions
- 🤖 **Fully automated** with manual trigger options
- 📝 **Well documented** with inline comments

---

## 🚀 Getting Started

1. **Push to your repository** - Workflows are automatically enabled
2. **Check Actions tab** - Verify workflows are running
3. **Review first run** - Check for any configuration issues
4. **Customize as needed** - Adjust schedules and settings

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [CodeQL Documentation](https://codeql.github.com/docs/)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [Actions Cache Documentation](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)

---

*Last updated: 2025-10-27*
