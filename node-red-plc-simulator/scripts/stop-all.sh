#!/bin/bash

# AI-Kit Node-RED Character Simulators - Stop All Script
# This script stops all running character simulators

echo "🛑 Stopping all AI-Kit Node-RED Character Simulators..."

# Find and kill all character simulator processes
PIDS=$(ps aux | grep "node dist/character-simulator.js" | grep -v grep | awk '{print $2}')

if [ -z "$PIDS" ]; then
    echo "ℹ️  No character simulators are currently running"
else
    echo "🔍 Found running simulators with PIDs: $PIDS"
    
    for PID in $PIDS; do
        echo "🔫 Killing process $PID..."
        kill $PID 2>/dev/null
        
        # Wait a moment and force kill if still running
        sleep 1
        if kill -0 $PID 2>/dev/null; then
            echo "💥 Force killing stubborn process $PID..."
            kill -9 $PID 2>/dev/null
        fi
    done
    
    echo "⏳ Waiting for processes to terminate..."
    sleep 2
fi

# Check for any remaining processes
REMAINING=$(ps aux | grep "node dist/character-simulator.js" | grep -v grep | wc -l)
if [ $REMAINING -eq 0 ]; then
    echo "✅ All character simulators stopped successfully"
else
    echo "⚠️  Warning: $REMAINING simulators may still be running"
fi

# Clean up any stale log files if requested
if [ "$1" = "--clean-logs" ]; then
    echo "🧹 Cleaning up log files..."
    rm -f *.log
    echo "✅ Log files cleaned"
fi

echo "🏁 Stop all operation completed"
