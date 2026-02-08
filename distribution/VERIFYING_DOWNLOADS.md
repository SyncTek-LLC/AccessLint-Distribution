# Verifying downloads

Every release publishes a `SHA256SUMS` file alongside the release assets.

## Verify (macOS)

Download the binary and checksum file from the same release:

```bash
curl -L https://github.com/SyncTek-LLC/AccessLint-Distribution/releases/download/v1.2.0/accesslint -o accesslint
curl -L https://github.com/SyncTek-LLC/AccessLint-Distribution/releases/download/v1.2.0/SHA256SUMS -o SHA256SUMS

shasum -a 256 -c SHA256SUMS
```

This should print `OK` for each asset.
