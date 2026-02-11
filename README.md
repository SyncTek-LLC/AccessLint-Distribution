<p align="center">
  <img src="logo.png" alt="AccessLint" width="100" height="100" style="border-radius: 20px;">
</p>

<h1 align="center">AccessLint</h1>

<p align="center"><strong>Static accessibility analysis for iOS/Swift.</strong></p>
<p align="center"> Catch missing labels, fixed fonts, and accessibility issues in SwiftUI and UIKit code — before your users do.</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+"></a>
  <a href="https://www.apple.com/macos/"><img src="https://img.shields.io/badge/macOS-13+-blue.svg" alt="macOS 13+"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
</p>

---

## Why AccessLint

- **Catch issues early**: Find missing accessibility labels and unsupported Dynamic Type before code review or QA
- **CI-friendly**: Runs in GitHub Actions with configurable fail thresholds — block PRs that introduce regressions
- **No simulator required**: Static analysis means fast feedback (hundreds of files in seconds)
- **SwiftUI + UIKit**: Rules for both modern declarative UI and legacy UIKit code
- **WCAG-aligned**: Presets map to WCAG 2.1 compliance levels (A, AA, AAA)

---

## Quick Start

```bash
brew tap synctek-llc/accesslint && brew install accesslint
accesslint analyze --path ./Sources
```

---

## Installation

### Homebrew (recommended)

```bash
brew tap synctek-llc/accesslint
brew install accesslint
```

### Direct Download

Download the universal binary (Intel + Apple Silicon):

```bash
curl -L https://github.com/SyncTek-LLC/AccessLint-Distribution/releases/latest/download/accesslint -o accesslint
chmod +x accesslint
sudo mv accesslint /usr/local/bin/
```

### Swift Package Manager

Add as a binary target dependency:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/SyncTek-LLC/AccessLint-Distribution.git", from: "1.3.1")
]
```

### Verifying Downloads

We publish a `SHA256SUMS` file with each release. See `distribution/VERIFYING_DOWNLOADS.md`.

---

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `analyze` | Scan Swift files for accessibility issues |
| `compare` | Compare current findings against a baseline |
| `init` | Generate a starter config file |
| `rules` | List available rules |

### Common Examples

```bash
# Analyze current directory
accesslint analyze

# Analyze a specific path with JSON output
accesslint analyze --path ./Sources --format json

# Fail CI on major issues
accesslint analyze --path ./MyApp --fail-on major

# Use WCAG AA preset
accesslint analyze --path ./MyApp --preset wcag-aa

# Compare against baseline (detect regressions)
accesslint analyze --path ./MyApp --baseline ./baseline.json

# Exclude test files
accesslint analyze --path . --exclude "**/Tests/**"
```

### Configuration

Create `.accesslintrc.json` in your project root:

```json
{
  "preset": "wcag-aa",
  "rules": {
    "A11Y.SWIFTUI.FIXED_FONT": {
      "enabled": true,
      "severity": "minor"
    }
  },
  "exclude": ["**/Generated/**", "**/Pods/**"],
  "include": ["Sources/**/*.swift"]
}
```

Or generate a starter config: `accesslint init`

### Output Formats

| Format | File | Use Case |
|--------|------|----------|
| `json` | `findings.json` | CI integration, baseline comparison |
| `md` | `report.md` | Human-readable summary for PRs |
| `xcode` | (stdout) | Xcode-compatible warnings in build logs |

### Exit Codes

| Code | Meaning | CI Action |
|------|---------|-----------|
| `0` | No findings at or above `--fail-on` level | Pass |
| `1` | Findings exist, but below `--fail-on` level | Pass (with warnings) |
| `2` | Findings at or above `--fail-on` level | Fail build |

---

## CI Integration

### GitHub Action (recommended)

```yaml
name: Accessibility Lint
on: [pull_request]

jobs:
  accesslint:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: SyncTek-LLC/AccessLint@v1.3.1
        with:
          path: ./Sources
          fail-on: major
```

The action automatically generates step summaries, PR comments, and enforces your fail threshold.

**Action Inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `path` | `.` | Path to analyze |
| `fail-on` | `blocker` | Severity threshold (`blocker`, `major`, `minor`, `info`) |
| `license-key` | | Team tier license key (enables cloud features) |
| `version` | `latest` | AccessLint version to install |

### Manual CI Setup

If you prefer not to use the action:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Install AccessLint
    run: |
      brew tap synctek-llc/accesslint && brew install accesslint
  - name: Run AccessLint
    run: |
      accesslint analyze --path ./Sources --format json --fail-on major --relative-paths
```

---

## Rules & Severity

25 rules across SwiftUI and UIKit. Run `accesslint rules` for the full list.

### Severity Levels

| Level | Meaning |
|-------|---------|
| `blocker` | Critical accessibility failure |
| `major` | Significant issue affecting usability |
| `minor` | Best practice or minor issue |
| `info` | Informational, review and decide |

### Built-in Presets

| Preset | Use Case |
|--------|----------|
| `minimal` | Quick checks, getting started |
| `wcag-a` | Basic legal compliance |
| `wcag-aa` | **Recommended for most apps** |
| `wcag-aaa` | Maximum accessibility |
| `strict` | Pre-release audits |

### Sample Rules

| Rule | Severity | Framework | What It Catches |
|------|----------|-----------|-----------------|
| `MISSING_LABEL` | major | SwiftUI | Button/control missing `.accessibilityLabel()` |
| `IMAGE_DECORATIVE` | minor | SwiftUI | Image without label or `.accessibilityHidden(true)` |
| `FIXED_FONT` | info | SwiftUI | Fixed font size (won't scale with Dynamic Type) |
| `BUTTON_MISSING_LABEL` | major | UIKit | UIButton with no `accessibilityLabel` |
| `HIDDEN_BUT_ACCESSIBLE` | major | UIKit | `isHidden = true` but still in accessibility tree |

---

## Suppression

Override specific findings with inline comments:

```swift
// accesslint:disable A11Y.SWIFTUI.FIXED_FONT
Text("Logo").font(.system(size: 48))  // Intentionally fixed for branding
// accesslint:enable A11Y.SWIFTUI.FIXED_FONT
```

---

## Pricing

The CLI is **free forever**. Cloud features unlock team workflows.

| | Free | Team ($49/mo) | Enterprise ($299/mo) |
|---|------|---------------|----------------------|
| CLI analysis (25 rules) | Yes | Yes | Yes |
| JSON/Markdown output | Yes | Yes | Yes |
| Baseline comparison | Yes | Yes | Yes |
| CI exit codes | Yes | Yes | Yes |
| PR comments | | Yes | Yes |
| Hosted baselines | | Yes | Yes |
| Historical trends | | Yes | Yes |
| Slack notifications | | Yes | Yes |
| Custom rules | | | Yes |
| SSO / SAML | | | Yes |
| SLA | | | Yes |

**Start a Team plan:** [accesslint.app](https://accesslint.app)
**Enterprise:** [info@synctek.io](mailto:info@synctek.io)

---

## Troubleshooting

### macOS Gatekeeper

If macOS blocks the binary:

```bash
xattr -d com.apple.quarantine /usr/local/bin/accesslint
```

### "command not found: accesslint"

Ensure the binary is in your PATH:

```bash
which accesslint || echo "Not in PATH"
# If using Homebrew, it should be at /opt/homebrew/bin/accesslint
```

### "No files analyzed"

Check that `--path` points to a directory with `.swift` files and your excludes aren't filtering everything.

---

## FAQ

**Does this replace manual accessibility testing?**
No. AccessLint catches code-level issues (missing labels, fixed fonts) but can't verify runtime VoiceOver behavior, color contrast, or touch target sizes. Use it for early detection alongside manual testing.

**What platforms are supported?**
macOS (Intel + Apple Silicon). Analyzes iOS/macOS Swift code (SwiftUI and UIKit). Objective-C and Storyboards are not yet supported.

**Can I add custom rules?**
Custom rules are available on the Enterprise tier. Contact [info@synctek.io](mailto:info@synctek.io).

---

## Links

- **Website**: [accesslint.app](https://accesslint.app)
- **Releases**: [github.com/SyncTek-LLC/AccessLint-Distribution/releases](https://github.com/SyncTek-LLC/AccessLint-Distribution/releases)
- **Issues**: [github.com/SyncTek-LLC/AccessLint-Distribution/issues](https://github.com/SyncTek-LLC/AccessLint-Distribution/issues)
- **Contact**: [info@synctek.io](mailto:info@synctek.io)

---

## License

MIT License. See [LICENSE](LICENSE) for details.
