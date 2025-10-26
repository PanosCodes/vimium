# Building Vimium

This document describes how to compile/build the Vimium extension.

## Quick Build

To compile the extension, simply run:

```bash
./build.sh
```

This will create distributable packages in the `dist/` directory:
- `dist/firefox/vimium-firefox-{version}.zip` - Firefox version
- `dist/chrome-store/vimium-chrome-store-{version}.zip` - Chrome Web Store version
- `dist/chrome-canary/vimium-canary-{version}.zip` - Chrome Canary (development) version

## Requirements

- Bash
- Python 3
- rsync
- zip

All of these are typically pre-installed on Linux and macOS systems.

## What the Build Does

The build script:
1. Parses `manifest.json` (with JSON5 comment support)
2. Copies all necessary files to `dist/vimium/`
3. Generates browser-specific manifests:
   - Firefox: Adds Firefox-specific settings and permissions
   - Chrome: Uses the standard manifest
   - Chrome Canary: Marks as development version
4. Creates zip packages for each browser variant

## Development vs Production

- The Chrome Store package is for production releases
- The Chrome Canary package is for development/testing
- The Firefox package includes Firefox-specific modifications

## Alternative: Using Deno (Original Method)

If you have Deno installed and JSR access, you can use the original build system:

```bash
./make.js package
```

Note: The `build.sh` script was created as an alternative that doesn't require Deno or JSR access.
