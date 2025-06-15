# Node-RED Editor URL Fix - RESOLVED ✅

## Issue Summary
The "Open Node-RED Editor" button on flow documentation pages was pointing to incorrect URLs using `/red` path, which resulted in 404 errors.

## Root Cause Analysis
The issue was in `/home/bigale/repos/epibus-pocketsocket/astro-host/src/pages/flows/[slug].astro` where the Node-RED editor links were constructed incorrectly:

### ❌ Incorrect (Before Fix)
```typescript
href={`http://localhost:${port}/red`}
```

### ✅ Correct (After Fix)  
```typescript
href={`http://localhost:${port}/`}
```

## Technical Details

Based on the Node-RED simulator configuration in `character-simulator.ts`:

```typescript
const settings = {
  httpAdminRoot: '/',      // Editor is at root path
  httpNodeRoot: '/api',    // Runtime/Dashboard is at /api
  // ...
};
```

- **Node-RED Editor**: Available at base URL (e.g., `http://localhost:1882/`)
- **Node-RED Dashboard**: Available at `/api/ui/` (e.g., `http://localhost:1882/api/ui/`)
- **Node-RED Runtime**: Available at `/api/` (e.g., `http://localhost:1882/api/`)

## Current Port Mapping ✅

| Character | Port | Editor URL | Dashboard URL |
|-----------|------|------------|---------------|
| Kyoko | 1881 | http://localhost:1881/ | http://localhost:1881/api/ui/ |
| Byakuya | 1882 | http://localhost:1882/ | http://localhost:1882/api/ui/ |
| Chihiro | 1883 | http://localhost:1883/ | http://localhost:1883/api/ui/ |
| Celestia | 1884 | http://localhost:1884/ | http://localhost:1884/api/ui/ |
| Sakura | 1885 | http://localhost:1885/ | http://localhost:1885/api/ui/ |

## Verification Steps

1. **Visit any flow documentation page**: 
   - Example: http://localhost:3000/flows/kyoko-reactor-control
   
2. **Click "Open Node-RED Editor" button**
   - Should now open the correct Node-RED editor interface
   - No more 404 errors

3. **Test multiple characters**:
   - All character editor links should work correctly
   - Each opens the respective character's Node-RED editor

## Files Modified

- `/home/bigale/repos/epibus-pocketsocket/astro-host/src/pages/flows/[slug].astro`
  - Fixed Node-RED editor URL from `/red` to `/` (root path)

## Status: COMPLETE ✅

The Node-RED editor button now correctly opens the Node-RED flow editor interface for each character. Users can:

- ✅ View live flow implementations  
- ✅ Edit Node-RED flows directly
- ✅ Access character-specific Node-RED editors
- ✅ No more broken `/red` links

This completes the final fix for all dashboard connectivity issues in the AI-Kit Industrial IoT system.
