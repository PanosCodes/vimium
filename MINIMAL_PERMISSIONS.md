# Minimal Permissions Configuration

This document describes the minimal permission set required for Vimium to detect and handle keyboard shortcuts.

## Current Permissions

The extension now uses only the following permissions:

```json
{
  "permissions": ["storage"],
  "host_permissions": ["<all_urls>"]
}
```

## Why These Are Sufficient for Keyboard Shortcuts

### How Keyboard Detection Works

1. **Content Scripts Auto-Injection**
   - The `content_scripts` section in manifest.json automatically injects JavaScript into all pages
   - No special permission required - this is a standard Chrome extension feature

2. **Event Listeners**
   - Content scripts register keyboard event listeners on the window object
   - Location: `content_scripts/vimium_frontend.js` - `installListeners()`
   - Listens for: `keydown`, `keypress`, `keyup` events
   - No special permission required - standard DOM API

3. **Key Mapping Storage**
   - Custom key mappings are stored in `chrome.storage`
   - Location: `background_scripts/commands.js` stores mappings
   - Location: `content_scripts/mode_normal.js` reads mappings
   - **Requires:** `storage` permission ✅

4. **Host Permissions**
   - Content scripts need to run on all web pages
   - **Requires:** `host_permissions: ["<all_urls>"]` ✅

## What Works

### ✅ Fully Functional Commands

These commands work completely with minimal permissions:

- **Scrolling**: j, k, h, l, gg, G, d, u, zH, zL
  - Implementation: Direct DOM manipulation in content script
  - No permissions needed beyond content script injection

- **Find Mode**: /, n, N
  - Implementation: DOM-based text search in content script
  - No permissions needed

- **Insert Mode**: i, gi
  - Implementation: Mode switching in content script
  - No permissions needed

- **Visual Mode**: v, V
  - Implementation: Text selection in content script
  - No permissions needed

- **Link Hints (current tab)**: f
  - Implementation: DOM scanning and click simulation in content script
  - No permissions needed

- **URL Navigation**: 
  - H, L (back/forward) - Uses `history.go()` in content script
  - gu, gU (URL manipulation) - Uses `location.href` in content script
  - No permissions needed

- **Help Dialog**: ?
  - Implementation: UI rendered in content script
  - No permissions needed

### ❌ Non-Functional Commands

These commands are detected but fail to execute (require removed permissions):

- **Tab Operations**: J, K, t, x, X, ^ (require `tabs` permission)
- **Bookmarks**: b, B (require `bookmarks` permission)
- **History Search**: o, O (require `history`, `bookmarks`, `tabs` permissions)
- **Link Hints (new tab)**: F (requires `tabs` permission to open new tab)
- **Search**: (requires `search` permission)

## Verification Example: "j" Key Press

```
User presses "j" → 
  Event captured by window.addEventListener("keydown", ...) →
  handlerStack.bubbleEvent("keydown", event) →
  KeyHandlerMode.onKeydown(event) →
  Check key mapping from chrome.storage →
  Execute NormalModeCommands.scrollDown() →
  Scroller.scrollBy() manipulates DOM →
  Page scrolls ✅
```

**Permissions used**: `storage` (for key mapping), `host_permissions` (for content script)

## Architecture

```
manifest.json
├── permissions: ["storage"] ─────────→ Store/retrieve key mappings
├── host_permissions: ["<all_urls>"] ─→ Run content scripts on all pages
└── content_scripts: [...]  ─────────→ Auto-inject keyboard handlers
    ├── lib/keyboard_utils.js ──────→ Key event processing
    ├── content_scripts/mode_key_handler.js → Key mapping & dispatch
    └── content_scripts/mode_normal.js ─────→ Command execution
```

## Removed Permissions and Their Use Cases

| Permission | Use Case | Impact of Removal |
|------------|----------|-------------------|
| `tabs` | Switch/create/close tabs | Tab commands don't work |
| `bookmarks` | Access bookmarks | Bookmark commands don't work |
| `history` | Browse history | History navigation/search don't work |
| `sessions` | Restore closed tabs | Restore command doesn't work |
| `notifications` | Show upgrade notices | No upgrade notifications |
| `scripting` | Dynamic injection | Existing tabs not injected on install |
| `favicon` | Display favicons | No favicons in UI |
| `webNavigation` | URL change detection | No re-check on URL change |
| `search` | Search engine queries | Search commands don't work |

## Testing the Configuration

To verify keyboard shortcuts work:

1. Install the extension with minimal permissions
2. Open any webpage
3. Press these keys:
   - `j` - Page should scroll down ✅
   - `k` - Page should scroll up ✅
   - `/` - Find mode should activate ✅
   - `f` - Link hints should appear ✅
   - `i` - Insert mode should activate ✅

4. Press these keys (will detect but fail to execute):
   - `t` - New tab (fails - no tabs permission) ❌
   - `x` - Close tab (fails - no tabs permission) ❌
   - `F` - Link hints for new tab (shows hints but can't open) ❌

## Conclusion

The minimal permission set (`storage` + `host_permissions`) is **sufficient for keyboard event detection and basic shortcut handling**. The extension can detect all key presses and execute commands that operate within the content script context. Commands requiring background script APIs will fail gracefully.

This configuration prioritizes user privacy by requesting only essential permissions while maintaining core keyboard navigation functionality.
