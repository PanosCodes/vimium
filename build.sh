#!/bin/bash
# Simple build script for Vimium that builds the extension packages
# This replicates the package functionality from make.js

set -e

echo "Building Vimium extension packages..."
echo ""

# Helper function to parse manifest with comment removal
parse_manifest() {
python3 << 'PYEOF'
import json, re, sys, uuid

def remove_json_comments(text):
    """Remove JSON5-style comments while preserving URLs in strings"""
    temp_marker = str(uuid.uuid4())
    strings = []
    
    # Extract and protect all strings
    def save_string(match):
        strings.append(match.group(0))
        return f'"{temp_marker}{len(strings)-1}"'
    
    text = re.sub(r'"(?:[^"\\]|\\.)*"', save_string, text)
    
    # Now remove comments
    text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    
    # Restore strings
    for i, s in enumerate(strings):
        text = text.replace(f'"{temp_marker}{i}"', s)
    
    return text

with open('manifest.json', 'r') as f:
    text = remove_json_comments(f.read())
    manifest = json.loads(text)
    
print(json.dumps(manifest))
PYEOF
}

# Parse manifest.json and extract version
MANIFEST_JSON=$(parse_manifest)
VERSION=$(echo "$MANIFEST_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['version'])")

echo "Version: $VERSION"

# Exclude list for rsync
EXCLUDE_ARGS=(
  --exclude='*.md'
  --exclude='.*'
  --exclude='CREDITS'
  --exclude='MIT-LICENSE.txt'
  --exclude='build_scripts'
  --exclude='dist'
  --exclude='make.js'
  --exclude='build.js'
  --exclude='build.sh'
  --exclude='deno.json'
  --exclude='deno.lock'
  --exclude='reload.html'
  --exclude='reload.js'
  --exclude='test_harnesses'
  --exclude='tests'
)

# Clean and create dist directories
rm -rf dist/vimium
mkdir -p dist/vimium dist/chrome-canary dist/chrome-store dist/firefox

# Copy files to dist/vimium
echo "Copying files..."
rsync -r . dist/vimium "${EXCLUDE_ARGS[@]}"

# Generate Firefox manifest
echo "Generating Firefox manifest..."
python3 << 'EOF'
import json, re, sys, uuid

def remove_json_comments(text):
    """Remove JSON5-style comments while preserving URLs in strings"""
    temp_marker = str(uuid.uuid4())
    strings = []
    
    # Extract and protect all strings
    def save_string(match):
        strings.append(match.group(0))
        return f'"{temp_marker}{len(strings)-1}"'
    
    text = re.sub(r'"(?:[^"\\]|\\.)*"', save_string, text)
    
    # Now remove comments
    text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    
    # Restore strings
    for i, s in enumerate(strings):
        text = text.replace(f'"{temp_marker}{i}"', s)
    
    return text

with open('manifest.json', 'r') as f:
    text = remove_json_comments(f.read())

manifest = json.loads(text)

# Modify for Firefox
manifest['permissions'] = [p for p in manifest['permissions'] if p != 'favicon']
manifest['permissions'].extend(['clipboardRead', 'clipboardWrite'])

# Firefox doesn't support service_worker yet
del manifest['background']['service_worker']
manifest['background']['scripts'] = ['background_scripts/main.js']

# Firefox-specific settings
manifest['action']['default_area'] = 'navbar'
manifest['browser_specific_settings'] = {
    'gecko': {
        'id': '{d7742d87-e61d-4b78-b8a1-b469842139fa}',
        'strict_min_version': '112.0'
    }
}

# Firefox supports SVG icons
manifest['icons'] = {
    '16': 'icons/icon.svg',
    '32': 'icons/icon.svg',
    '48': 'icons/icon.svg',
    '64': 'icons/icon.svg',
    '96': 'icons/icon.svg',
    '128': 'icons/icon.svg'
}
manifest['action']['default_icon'] = 'icons/action_disabled.svg'

with open('dist/vimium/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)

EOF

# Build Firefox package
echo "Building Firefox package..."
cd dist/vimium
zip -r --filesync ../firefox/vimium-firefox-$VERSION.zip . -x 'icons/*.png'
cd ../..

# Generate Chrome manifest
echo "Generating Chrome manifest..."
python3 << 'EOF'
import json, re, sys, uuid

def remove_json_comments(text):
    """Remove JSON5-style comments while preserving URLs in strings"""
    temp_marker = str(uuid.uuid4())
    strings = []
    
    # Extract and protect all strings
    def save_string(match):
        strings.append(match.group(0))
        return f'"{temp_marker}{len(strings)-1}"'
    
    text = re.sub(r'"(?:[^"\\]|\\.)*"', save_string, text)
    
    # Now remove comments
    text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    
    # Restore strings
    for i, s in enumerate(strings):
        text = text.replace(f'"{temp_marker}{i}"', s)
    
    return text

with open('manifest.json', 'r') as f:
    text = remove_json_comments(f.read())

manifest = json.loads(text)

with open('dist/vimium/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)
EOF

# Build Chrome Store package
echo "Building Chrome Store package..."
cd dist/vimium
zip -r --filesync ../chrome-store/vimium-chrome-store-$VERSION.zip .
cd ../..

# Generate Chrome Canary manifest
echo "Generating Chrome Canary manifest..."
python3 << 'EOF'
import json, re, sys, uuid

def remove_json_comments(text):
    """Remove JSON5-style comments while preserving URLs in strings"""
    temp_marker = str(uuid.uuid4())
    strings = []
    
    # Extract and protect all strings
    def save_string(match):
        strings.append(match.group(0))
        return f'"{temp_marker}{len(strings)-1}"'
    
    text = re.sub(r'"(?:[^"\\]|\\.)*"', save_string, text)
    
    # Now remove comments
    text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    
    # Restore strings
    for i, s in enumerate(strings):
        text = text.replace(f'"{temp_marker}{i}"', s)
    
    return text

with open('manifest.json', 'r') as f:
    text = remove_json_comments(f.read())

manifest = json.loads(text)
manifest['name'] = 'Vimium Canary'
manifest['description'] = 'This is the development branch of Vimium (it is beta software).'

with open('dist/vimium/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)
EOF

# Build Chrome Canary package
echo "Building Chrome Canary package..."
cd dist/vimium
zip -r --filesync ../chrome-canary/vimium-canary-$VERSION.zip .
cd ../..

echo ""
echo "✓ Build complete! Version $VERSION"
echo "Output files:"
echo "  - dist/firefox/vimium-firefox-$VERSION.zip"
echo "  - dist/chrome-store/vimium-chrome-store-$VERSION.zip"
echo "  - dist/chrome-canary/vimium-canary-$VERSION.zip"
