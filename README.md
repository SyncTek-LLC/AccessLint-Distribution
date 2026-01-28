# AccessLint

**iOS Accessibility Linter** - Static analysis tool for detecting accessibility issues in SwiftUI and UIKit code.

## Installation

### Swift Package Manager (Recommended)

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

### Direct Download

Download the binary from [Releases](https://github.com/mauricecarrier7/AccessLint-Distribution/releases).

## Usage

```bash
# Analyze a directory
accesslint analyze --path /path/to/your/ios/project

# Output in Xcode format (for build phase integration)
accesslint analyze --path . --format xcode

# Generate configuration file
accesslint init --preset wcag-aa

# List available rules
accesslint rules
```

## Features

- **21 accessibility rules** covering SwiftUI and UIKit
- **WCAG 2.1 mapping** - Each rule maps to WCAG success criteria
- **Xcode integration** - `--format xcode` for inline warnings
- **Configurable** - `.accesslintrc.json` for custom rules and severity
- **CI/CD ready** - Exit codes based on severity, baseline comparison

## Supported Rules

### SwiftUI
- Missing accessibility labels on buttons
- Images without accessibility configuration
- Fixed fonts (Dynamic Type)
- Missing screen titles
- Reduce motion compliance
- Touch target size
- And more...

### UIKit
- UIButton missing labels
- Hidden but accessible elements
- Fixed font sizes
- UIImageView accessibility
- And more...

## Configuration

Create `.accesslintrc.json` in your project root:

```json
{
  "preset": "wcag-aa",
  "rules": {
    "A11Y.SWIFTUI.REDUCE_MOTION": {
      "severity": "info"
    }
  },
  "exclude": ["**/Generated/**"]
}
```

## Xcode Build Phase

Add a Run Script build phase:

```bash
if which accesslint >/dev/null; then
  accesslint analyze --path "${SRCROOT}" --format xcode
fi
```

## License

Proprietary - All rights reserved.
