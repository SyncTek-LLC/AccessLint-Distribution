# AccessLint

**Static accessibility analysis for iOS/Swift.** Catch missing labels, fixed fonts, and accessibility issues in SwiftUI and UIKit code—before your users do.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![macOS 13+](https://img.shields.io/badge/macOS-13+-blue.svg)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Why AccessLint

- **Catch issues early**: Find missing accessibility labels and unsupported Dynamic Type before code review or QA
- **CI-friendly**: Runs in GitHub Actions with configurable fail thresholds—block PRs that introduce regressions
- **No simulator required**: Static analysis means fast feedback (hundreds of files in seconds)
- **SwiftUI + UIKit**: Rules for both modern declarative UI and legacy UIKit code
- **WCAG-aligned**: Presets map to WCAG 2.1 compliance levels (A, AA, AAA)

---

## Quick Start

Get running in under 2 minutes:

```bash
# 1. Download the universal binary (works on Intel + Apple Silicon)
curl -L https://github.com/mauricecarrier7/AccessLint/releases/latest/download/accesslint -o accesslint

# 2. Make it executable and move to PATH
chmod +x accesslint
sudo mv accesslint /usr/local/bin/

# 3. Run on your project
accesslint analyze --path ./MyApp
```

**What to expect:**
- Console output showing findings count and top issues
- JSON report at `./accesslint-reports/findings.json`
- Exit code `0` (no blockers), `1` (findings exist), or `2` (blockers found)

---

## Installation

### Direct Binary (Recommended)

Fastest option—pre-built universal binary for macOS:

```bash
curl -L https://github.com/mauricecarrier7/AccessLint/releases/latest/download/accesslint -o accesslint
chmod +x accesslint
sudo mv accesslint /usr/local/bin/

# Verify
accesslint --version
```

### Swift Package Manager

Add as a binary target dependency:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/mauricecarrier7/AccessLint-Distribution.git", from: "1.1.0")
]
```

### Build from Source

If you need to modify or debug:

```bash
git clone https://github.com/mauricecarrier7/AccessLint.git
cd AccessLint
swift build -c release
sudo cp .build/release/accesslint /usr/local/bin/
```

---

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `analyze` | Scan Swift files for accessibility issues (default) |
| `compare` | Compare current findings against a baseline |
| `init` | Generate a starter config file |
| `rules` | List available rules |

### Common Examples

```bash
# Analyze current directory
accesslint analyze

# Analyze a specific path
accesslint analyze --path ./Sources

# Multiple output formats
accesslint analyze --path ./MyApp --format json --format md

# Fail CI on major issues
accesslint analyze --path ./MyApp --fail-on major

# Use WCAG AA preset
accesslint analyze --path ./MyApp --preset wcag-aa

# Compare against baseline (detect regressions)
accesslint analyze --path ./MyApp --baseline ./baseline.json

# Exclude test files
accesslint analyze --path . --exclude "**/Tests/**" --exclude "**/*Tests.swift"
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

Or generate a starter config:

```bash
accesslint init
```

### Output Formats

| Format | File | Use Case |
|--------|------|----------|
| `json` | `findings.json` | CI integration, baseline comparison, programmatic access |
| `md` | `report.md` | Human-readable summary for PRs or documentation |
| `xcode` | (stdout) | Xcode-compatible warnings/errors in build logs |

### Exit Codes

| Code | Meaning | CI Action |
|------|---------|-----------|
| `0` | No findings at or above `--fail-on` level | Pass |
| `1` | Findings exist, but below `--fail-on` level | Pass (with warnings) |
| `2` | Findings at or above `--fail-on` level | Fail build |
| `64` | Usage error (bad arguments) | Fix command |
| `70` | Internal error | Report bug |

---

## CI Integration

### GitHub Actions

```yaml
name: Accessibility Lint

on:
  pull_request:
    paths: ['**/*.swift']

jobs:
  accesslint:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      # Install AccessLint
      - name: Install AccessLint
        run: |
          curl -L https://github.com/mauricecarrier7/AccessLint/releases/latest/download/accesslint -o accesslint
          chmod +x accesslint
          sudo mv accesslint /usr/local/bin/

      # Run analysis
      - name: Run AccessLint
        run: |
          accesslint analyze \
            --path ./Sources \
            --format json \
            --format md \
            --fail-on major \
            --relative-paths

      # Upload report as artifact
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: accesslint-report
          path: accesslint-reports/
```

### Best Practices

- **Pin the version**: Use a specific release URL instead of `latest` for reproducible builds
- **Run on PRs**: Trigger on `pull_request` with path filter for `**/*.swift`
- **Use `--relative-paths`**: Makes reports portable across CI and local machines
- **Save baseline**: Commit `baseline.json` to track regressions over time
- **Fail on major**: Use `--fail-on major` to block PRs with significant issues while allowing minor ones

---

## Rules & Severity

### Severity Levels

| Level | Meaning | Recommended Action |
|-------|---------|-------------------|
| `blocker` | Critical accessibility failure (e.g., completely inaccessible control) | Must fix before merge |
| `major` | Significant issue affecting usability (e.g., missing label on button) | Should fix before merge |
| `minor` | Minor issue or best practice (e.g., missing hint text) | Fix when possible |
| `info` | Informational, potential issue (e.g., heuristic-based detection) | Review and decide |

### Built-in Presets

| Preset | Rules | Use Case |
|--------|-------|----------|
| `minimal` | 6 core rules | Quick checks, getting started |
| `wcag-a` | Level A compliance | Basic legal compliance |
| `wcag-aa` | Level AA compliance | **Recommended for most apps** |
| `wcag-aaa` | Level AAA compliance | Maximum accessibility |
| `strict` | All rules, highest severities | Pre-release audits |

### Core Rules

**SwiftUI:**
| Rule ID | Default Severity | What It Catches |
|---------|-----------------|-----------------|
| `A11Y.SWIFTUI.MISSING_LABEL` | major | Button/control with non-text content missing `.accessibilityLabel()` |
| `A11Y.SWIFTUI.IMAGE_DECORATIVE` | minor | Image without label or `.accessibilityHidden(true)` |
| `A11Y.SWIFTUI.FIXED_FONT` | info | Fixed font size (won't scale with Dynamic Type) |

**UIKit:**
| Rule ID | Default Severity | What It Catches |
|---------|-----------------|-----------------|
| `A11Y.UIKIT.BUTTON_MISSING_LABEL` | major | UIButton with empty title and no `accessibilityLabel` |
| `A11Y.UIKIT.HIDDEN_BUT_ACCESSIBLE` | major | `isHidden = true` but still in accessibility tree |
| `A11Y.UIKIT.FIXED_FONT_DYNAMIC_TYPE` | major | UIFont without Dynamic Type support |

Use `accesslint rules` to see all available rules.

---

## Example Output

### Console Output

```
AccessLint v1.1.0

Analyzing: ./Sources
Files: 47 | Rules: 6 | Jobs: 8

✓ Analysis complete in 0.82s

Summary:
  Files analyzed: 47
  Total findings: 12
  By severity: major=4, minor=6, info=2

Top issues (major):
  1. Button with Image missing accessibilityLabel
     Sources/Views/SettingsView.swift:45
  2. UIButton has empty title with no accessibilityLabel
     Sources/Controllers/HomeVC.swift:112
  ...

Reports written to: ./accesslint-reports/
  - findings.json (12 findings)
```

### Markdown Report (excerpt)

```markdown
# AccessLint Report

## Summary

| Metric | Value |
|--------|-------|
| Files Analyzed | 47 |
| Rules Run | 6 |
| Total Findings | 12 |
| Duration | 0.82s |

### Findings by Severity

- **Major**: 4
- **Minor**: 6
- **Info**: 2

## Findings

### 1. Button with Image missing accessibilityLabel

- **Rule**: `A11Y.SWIFTUI.MISSING_LABEL`
- **Severity**: major
- **Location**: `Sources/Views/SettingsView.swift:45`

Button contains an Image but no Text, and is missing an accessibilityLabel.

**Code:**
```swift
Button(action: { showSettings() }) {
    Image(systemName: "gear")
}
```

**Fix:** Add `.accessibilityLabel("Settings")` to describe the button's purpose.
```

---

## Suppression

Suppress specific findings with inline comments when you need to override:

```swift
// Suppress a specific rule for the next line
// accesslint:disable A11Y.SWIFTUI.FIXED_FONT
Text("Logo").font(.system(size: 48))  // Intentionally fixed for branding
// accesslint:enable A11Y.SWIFTUI.FIXED_FONT

// Suppress all rules for a block
// accesslint:disable-all
Image("decorative-divider")  // Verified decorative
// accesslint:enable-all
```

---

## Troubleshooting

### macOS Gatekeeper / "unidentified developer"

If macOS blocks the binary:

```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine /usr/local/bin/accesslint
```

### "Permission denied"

```bash
# Ensure the binary is executable
chmod +x accesslint

# Or install to user directory instead of system
mkdir -p ~/bin
mv accesslint ~/bin/
export PATH="$HOME/bin:$PATH"  # Add to ~/.zshrc
```

### "command not found: accesslint"

The binary isn't in your PATH:

```bash
# Check where it is
which accesslint

# If installed to /usr/local/bin, ensure it's in PATH
echo $PATH | grep -q "/usr/local/bin" || export PATH="/usr/local/bin:$PATH"
```

### "No files analyzed" / 0 findings

- **Check path**: Does `--path` point to a directory with `.swift` files?
- **Check excludes**: Are your files excluded by default patterns (Pods, .build, etc.)?
- **Check includes**: If using `--include`, does the pattern match your files?

```bash
# Debug: see which files would be analyzed
find ./Sources -name "*.swift" | head -20
```

### Build from source fails

Ensure you have the correct Swift version:

```bash
swift --version  # Requires 5.9+
xcode-select -p  # Should show Xcode path
```

---

## FAQ

**Does this replace manual accessibility testing?**

No. AccessLint catches common code-level issues (missing labels, fixed fonts) but can't verify:
- Actual VoiceOver behavior at runtime
- Color contrast (requires rendered colors)
- Touch target sizes (requires layout)
- Logical reading order

Use AccessLint for early detection, but still test with VoiceOver and real users.

**Does it run in CI?**

Yes. AccessLint is designed for CI:
- Fast execution (no simulator required)
- Configurable exit codes (`--fail-on`)
- JSON output for programmatic processing
- Baseline comparison for regression detection

**What platforms/languages are supported?**

- **Platforms**: macOS (Intel + Apple Silicon). The tool analyzes iOS/macOS Swift code but runs on macOS.
- **Languages**: Swift only. Specifically SwiftUI and UIKit patterns.
- **Not supported**: Objective-C, Storyboards/XIBs (yet), Android, web.

**How do I customize rule severity?**

Use a config file (`.accesslintrc.json`) or CLI:

```json
{
  "rules": {
    "A11Y.SWIFTUI.FIXED_FONT": { "severity": "major" }
  }
}
```

**Can I add custom rules?**

Not yet in the public release. Custom rules require building from source. See the [main repository](https://github.com/mauricecarrier7/AccessLint) for rule authoring.

---

## Links

- **Source Repository**: [github.com/mauricecarrier7/AccessLint](https://github.com/mauricecarrier7/AccessLint)
- **Releases**: [github.com/mauricecarrier7/AccessLint/releases](https://github.com/mauricecarrier7/AccessLint/releases)
- **Issues**: [github.com/mauricecarrier7/AccessLint/issues](https://github.com/mauricecarrier7/AccessLint/issues)

---

## License

MIT License. See [LICENSE](LICENSE) for details.
