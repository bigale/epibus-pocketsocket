#!/bin/bash

# AI-Kit Node-RED Character Simulators - Restart All Script
# This script stops all simulators and starts them again

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Restarting all AI-Kit Node-RED Character Simulators..."

# Stop all simulators first
echo "🛑 Step 1: Stopping all simulators..."
"$SCRIPT_DIR/stop-all.sh"

if [ $? -eq 0 ]; then
    echo "✅ Stop completed successfully"
else
    echo "⚠️  Stop completed with warnings"
fi

echo ""

# Start all simulators
echo "🚀 Step 2: Starting all simulators..."
"$SCRIPT_DIR/start-all.sh"

if [ $? -eq 0 ]; then
    echo "🎉 Restart operation completed successfully!"
else
    echo "⚠️  Restart completed with some issues. Check logs for details."
fi
