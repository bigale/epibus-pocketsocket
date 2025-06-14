#!/bin/bash

# WebSocket Connection Test Script
# Tests if Node-RED WebSocket endpoints are working

echo "🔍 Testing Node-RED WebSocket Connections"
echo "========================================"

CHARACTERS=("kyoko" "byakuya" "chihiro" "celestia" "sakura")
PORTS=(1881 1882 1883 1884 1885)

for i in "${!CHARACTERS[@]}"; do
    CHARACTER="${CHARACTERS[$i]}"
    PORT="${PORTS[$i]}"
    
    echo ""
    echo "🎭 Testing $CHARACTER (port $PORT):"
    
    # Test HTTP endpoint first
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/")
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "   ✅ HTTP: Node-RED editor accessible"
    else
        echo "   ❌ HTTP: Not accessible (status: $HTTP_STATUS)"
        continue
    fi
    
    # Test if WebSocket upgrade is available using curl with upgrade headers
    WS_TEST=$(curl -s -I -H "Connection: upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" "http://localhost:$PORT/comms" 2>/dev/null | head -1)
    
    if echo "$WS_TEST" | grep -q "101"; then
        echo "   ✅ WebSocket: /comms endpoint supports WebSocket upgrade"
    elif echo "$WS_TEST" | grep -q "404"; then
        echo "   ❌ WebSocket: /comms endpoint not found"
    else
        echo "   ⚠️  WebSocket: /comms response: $(echo $WS_TEST | tr -d '\r')"
    fi
    
    # Test character-specific WebSocket endpoint
    CHAR_WS_TEST=$(curl -s -I -H "Connection: upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" "http://localhost:$PORT/character-ws" 2>/dev/null | head -1)
    
    if echo "$CHAR_WS_TEST" | grep -q "101"; then
        echo "   ✅ Character WebSocket: /character-ws endpoint available"
    else
        echo "   ⚠️  Character WebSocket: /character-ws not available"
    fi
done

echo ""
echo "💡 Note: Node-RED WebSocket connections should work in the browser even if"
echo "   command-line tests show issues due to WebSocket handshake complexity."
