#!/bin/bash

# AI-Kit Node-RED Character Simulators - Start All Script
# This script starts all character simulators with proper environment configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting all AI-Kit Node-RED Character Simulators..."
echo "📁 Project directory: $PROJECT_DIR"

# Ensure we're in the correct directory
cd "$PROJECT_DIR"

# Check if TypeScript has been compiled
if [ ! -d "dist" ]; then
    echo "❌ Error: dist/ directory not found. Please run 'npm run build' first"
    exit 1
fi

if [ ! -f "dist/character-simulator.js" ]; then
    echo "❌ Error: character-simulator.js not found in dist/. Please run 'npm run build' first"
    exit 1
fi

# Characters to start
CHARACTERS=("kyoko" "byakuya" "chihiro" "celestia" "sakura")
PORTS=(1881 1882 1883 1884 1885)
MODBUS_PORTS=(5020 5021 5022 5023 5024)
WEBSOCKET_PORTS=(1981 1982 1983 1984 1985)

echo "🔧 Starting simulators..."

for i in "${!CHARACTERS[@]}"; do
    CHARACTER="${CHARACTERS[$i]}"
    PORT="${PORTS[$i]}"
    MODBUS_PORT="${MODBUS_PORTS[$i]}"
    WS_PORT="${WEBSOCKET_PORTS[$i]}"
    
    echo "🎭 Starting $CHARACTER simulator..."
    echo "   📊 Dashboard: http://localhost:$PORT"
    echo "   🔌 MODBUS: localhost:$MODBUS_PORT"
    echo "   🔄 WebSocket: $WS_PORT"
    
    # Start the simulator in background
    CHARACTER="$CHARACTER" nohup node dist/character-simulator.js > "${CHARACTER}.log" 2>&1 &
    PID=$!
    
    echo "   ✅ Started with PID: $PID"
    
    # Brief pause between starts to avoid race conditions
    sleep 1
done

echo "⏳ Waiting for simulators to initialize..."
sleep 5

# Verify all simulators are running
echo "🔍 Verifying simulator status..."
RUNNING_COUNT=0

for CHARACTER in "${CHARACTERS[@]}"; do
    # Check if process is still running and log shows success
    if pgrep -f "CHARACTER=$CHARACTER.*character-simulator.js" > /dev/null; then
        if grep -q "simulator running on port" "${CHARACTER}.log" 2>/dev/null; then
            echo "   ✅ $CHARACTER: Running successfully"
            RUNNING_COUNT=$((RUNNING_COUNT + 1))
        else
            echo "   ⚠️  $CHARACTER: Process running but may have issues (check ${CHARACTER}.log)"
        fi
    else
        echo "   ❌ $CHARACTER: Failed to start (check ${CHARACTER}.log)"
    fi
done

echo ""
echo "📊 Summary: $RUNNING_COUNT/${#CHARACTERS[@]} simulators running"

if [ $RUNNING_COUNT -eq ${#CHARACTERS[@]} ]; then
    echo "🎉 All simulators started successfully!"
    echo ""
    echo "🌐 Access URLs:"
    echo "   🎯 Kyoko Kirigiri:     http://localhost:1881"
    echo "   💰 Byakuya Togami:     http://localhost:1882"
    echo "   💻 Chihiro Fujisaki:   http://localhost:1883"
    echo "   👑 Celestia Ludenberg: http://localhost:1884"
    echo "   💪 Sakura Ogami:       http://localhost:1885"
else
    echo "⚠️  Some simulators failed to start. Check individual log files for details."
    echo "💡 Try running: ./scripts/stop-all.sh && ./scripts/start-all.sh"
fi

echo "🏁 Start all operation completed"
