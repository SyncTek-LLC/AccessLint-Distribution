# AccessLint

**iOS Accessibility Linter** - Static analysis tool for detecting accessibility issues in SwiftUI and UIKit code.

## Installation

### Direct Download (Recommended for CI/CD)

```bash
# Download and install
curl -L -o /usr/local/bin/accesslint \
  https://github.com/mauricecarrier7/AccessLint-Distribution/releases/download/1.0.0/accesslint
chmod +x /usr/local/bin/accesslint

# Verify installation
accesslint --version
```

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mauricecarrier7/AccessLint-Distribution.git", from: "1.0.0")
]
```

Or add via Xcode: File → Add Packages → Enter URL:
```
https://github.com/mauricecarrier7/AccessLint-Distribution.git
```

## Usage

```bash
# Analyze a directory
accesslint analyze --path /path/to/your/ios/project

# Output in Xcode format (for build phase integration)
accesslint analyze --path . --format xcode

# Output JSON and Markdown reports
accesslint analyze --path . --output ./reports --format json --format md

# Generate configuration file
accesslint init --preset wcag-aa

# List available rules
accesslint rules

# List rules with WCAG level filter
accesslint rules --wcag-level aa --framework swiftui
```

## CI/CD Integration

### GitHub Actions

Add this workflow to `.github/workflows/accessibility.yml`:

```yaml
name: Accessibility Lint

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  accessibility-lint:
    runs-on: macos-14
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Cache AccessLint
        uses: actions/cache@v4
        with:
          path: /usr/local/bin/accesslint
          key: accesslint-v1.0.0-${{ runner.os }}

      - name: Install AccessLint
        run: |
          if [ ! -f /usr/local/bin/accesslint ]; then
            curl -L -o /usr/local/bin/accesslint \
              https://github.com/mauricecarrier7/AccessLint-Distribution/releases/download/1.0.0/accesslint
            chmod +x /usr/local/bin/accesslint
          fi
          # Remove quarantine attribute (macOS security)
          xattr -d com.apple.quarantine /usr/local/bin/accesslint 2>/dev/null || true

      - name: Run AccessLint
        id: lint
        run: |
          set +e
          OUTPUT=$(accesslint analyze \
            --path ./YourSourceFolder \
            --output ./accesslint-reports \
            --format json \
            --format md \
            --relative-paths \
            --exclude '**/Tests/**' \
            --exclude '**/*Tests.swift' \
            --fail-on major 2>&1)
          EXIT_CODE=$?
          set -e
          
          echo "$OUTPUT"
          
          # Parse counts from JSON
          if [ -f "./accesslint-reports/findings.json" ]; then
            TOTAL=$(jq 'length' ./accesslint-reports/findings.json)
            MAJOR=$(jq '[.[] | select(.severity == "major")] | length' ./accesslint-reports/findings.json)
            MINOR=$(jq '[.[] | select(.severity == "minor")] | length' ./accesslint-reports/findings.json)
          else
            TOTAL=0; MAJOR=0; MINOR=0
          fi
          
          echo "total=$TOTAL" >> $GITHUB_OUTPUT
          echo "major=$MAJOR" >> $GITHUB_OUTPUT
          echo "minor=$MINOR" >> $GITHUB_OUTPUT
          echo "exit-code=$EXIT_CODE" >> $GITHUB_OUTPUT

      - name: Upload Report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: accessibility-report
          path: accesslint-reports/
          retention-days: 14
          if-no-files-found: ignore

      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const total = '${{ steps.lint.outputs.total }}' || '0';
            const major = '${{ steps.lint.outputs.major }}' || '0';
            const minor = '${{ steps.lint.outputs.minor }}' || '0';
            
            let body = '## 🔍 AccessLint Report\n\n';
            
            if (major === '0') {
              body += '✅ **No major accessibility issues found!**\n\n';
            } else {
              body += `⚠️ **${major} major issue(s) require attention**\n\n`;
            }
            
            body += '| Severity | Count |\n|----------|-------|\n';
            body += `| 🔴 Major | ${major} |\n`;
            body += `| 🟡 Minor | ${minor} |\n`;
            body += `| **Total** | **${total}** |\n\n`;
            body += `📦 [Download full report](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})`;
            
            // Find existing comment
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number
            });
            
            const existing = comments.find(c => 
              c.user.type === 'Bot' && c.body.includes('AccessLint Report')
            );
            
            if (existing) {
              await github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: existing.id,
                body
              });
            } else {
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body
              });
            }

      - name: Fail on Major Issues
        if: steps.lint.outputs.exit-code != '0'
        run: |
          echo "❌ AccessLint found major accessibility issues"
          exit 1
```

**Important:** Replace `./YourSourceFolder` with your actual source directory (e.g., `./MyApp`, `./Sources`).

### Xcode Build Phase

Add a Run Script build phase to get inline warnings:

```bash
if [ -f /usr/local/bin/accesslint ]; then
  /usr/local/bin/accesslint analyze --path "${SRCROOT}/YourSourceFolder" --format xcode
fi
```

### Fastlane

```ruby
lane :accessibility_check do
  sh("accesslint analyze --path ../YourSourceFolder --format json --output ../reports --fail-on major")
end
```

## Features

- **21 accessibility rules** covering SwiftUI and UIKit
- **WCAG 2.1 mapping** - Each rule maps to WCAG success criteria
- **Xcode integration** - `--format xcode` for inline warnings
- **Configurable** - `.accesslintrc.json` for custom rules and severity
- **CI/CD ready** - Exit codes based on severity, baseline comparison

## Supported Rules

### SwiftUI
| Rule | Description | WCAG |
|------|-------------|------|
| MISSING_LABEL | Button missing accessibility label | 4.1.2, 1.1.1 |
| IMAGE_DECORATIVE | Image without accessibility config | 1.1.1 |
| FIXED_FONT | Fixed font size (Dynamic Type) | 1.4.4 |
| SCREEN_TITLE | Missing navigation title | 2.4.2 |
| REDUCE_MOTION | Animation without reduce motion check | 2.3.3 |
| TOUCH_TARGET | Touch target below 44x44 | 2.5.5 |
| And more... | | |

### UIKit
| Rule | Description | WCAG |
|------|-------------|------|
| BUTTON_MISSING_LABEL | UIButton without accessibility label | 4.1.2 |
| HIDDEN_BUT_ACCESSIBLE | isHidden but not accessibilityHidden | 1.3.1 |
| FIXED_FONT_DYNAMIC | UIFont without Dynamic Type | 1.4.4 |
| And more... | | |

## Configuration

Create `.accesslintrc.json` in your project root:

```json
{
  "preset": "wcag-aa",
  "rules": {
    "A11Y.SWIFTUI.REDUCE_MOTION": {
      "severity": "info"
    },
    "A11Y.SWIFTUI.FIXED_FONT": {
      "enabled": false
    }
  },
  "exclude": [
    "**/Generated/**",
    "**/Pods/**"
  ]
}
```

### Available Presets

| Preset | Description |
|--------|-------------|
| `minimal` | Only critical rules |
| `wcag-a` | WCAG 2.1 Level A compliance |
| `wcag-aa` | WCAG 2.1 Level AA compliance (recommended) |
| `wcag-aaa` | WCAG 2.1 Level AAA compliance |
| `strict` | All rules enabled |

Generate a config file:
```bash
accesslint init --preset wcag-aa
```

## CLI Reference

```
USAGE: accesslint <command> [options]

COMMANDS:
  analyze     Analyze Swift files for accessibility issues
  compare     Compare findings against a baseline
  init        Generate a configuration file
  rules       List available rules

ANALYZE OPTIONS:
  --path <path>           Path to analyze (required)
  --output <dir>          Output directory (default: current)
  --format <fmt>          Output format: json, md, xcode (can repeat)
  --exclude <pattern>     Glob pattern to exclude (can repeat)
  --include <pattern>     Glob pattern to include (can repeat)
  --config <file>         Path to config file
  --preset <name>         Use built-in preset
  --baseline <file>       Compare against baseline JSON
  --fail-on <severity>    Exit non-zero if issues >= severity
  --relative-paths        Use relative paths in output
  --no-cache              Disable caching
```

## Troubleshooting

### macOS Gatekeeper Warning

If you see "cannot be opened because the developer cannot be verified":

```bash
xattr -d com.apple.quarantine /usr/local/bin/accesslint
```

### Binary Not Found in CI

Ensure the download step completed and the binary is executable:

```bash
ls -la /usr/local/bin/accesslint
file /usr/local/bin/accesslint
```

## License

Proprietary - All rights reserved.
