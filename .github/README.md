# 🤖 GitHub Automation

This directory contains all GitHub Actions workflows and configurations for automated CI/CD, security scanning, and dependency management.

## 📁 Files

```
.github/
├── workflows/
│   ├── eslint.yml               # 🔍 Code quality & linting
│   ├── nightly-dev-release.yml  # 🌙 Nightly dev releases
│   ├── codeql.yml               # 🔒 Security scanning
│   ├── ci.yml                   # ⚡ CI pipeline
│   └── cache-cleanup.yml        # 🧹 Cache management
├── dependabot.yml               # 🤖 Dependency updates
├── WORKFLOWS.md                 # 📚 Detailed documentation
└── README.md                    # 📖 This file
```

## 🚀 Quick Start

All workflows are **automatically enabled** when you push this repository to GitHub. No additional configuration needed!

## 📊 Workflow Status

Check the **Actions** tab in your repository to see:
- ✅ Successful runs
- ❌ Failed runs
- ⏳ In-progress runs
- 📊 Workflow statistics

## 🔑 Key Features

- **🔍 Code Quality**: ESLint checks with PR comments
- **🌙 Nightly Releases**: Automatic dev builds with changelogs
- **🔒 Security Scanning**: CodeQL analysis on every push
- **⚡ Fast CI**: Cached dependencies for quick builds
- **🤖 Auto Updates**: Dependabot keeps dependencies current
- **🧹 Cache Management**: Automatic cleanup of old caches
- **🔄 Reusable Workflows**: ESLint workflow shared across CI and releases

## 📖 Documentation

For detailed information about each workflow, see [WORKFLOWS.md](./WORKFLOWS.md)

## 🛠️ Customization

Edit the workflow files in `.github/workflows/` to customize:
- Schedule times
- Branch triggers
- Cache strategies
- Notification settings

## 💡 Tips

1. **Manual Triggers**: All workflows support manual execution via workflow_dispatch
2. **Cache Hits**: Check workflow summaries to see cache performance
3. **Security Alerts**: Review the Security tab for CodeQL findings
4. **Dependabot PRs**: Auto-merge safe updates or review manually

---

*For questions or issues, check the workflow logs in the Actions tab*
