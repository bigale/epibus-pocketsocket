#!/bin/bash

# AI-Kit Node-RED Character Simulators - Status Check Script
# This script shows the current status of all character simulators

echo "📊 AI-Kit Node-RED Character Simulators Status"
echo "=============================================="

# Characters and their expected ports
CHARACTERS=("kyoko" "byakuya" "chihiro" "celestia" "sakura")
PORTS=(1881 1882 1883 1884 1885)
MODBUS_PORTS=(5020 5021 5022 5023 5024)
WEBSOCKET_PORTS=(1981 1982 1983 1984 1985)

TOTAL_RUNNING=0

for i in "${!CHARACTERS[@]}"; do
    CHARACTER="${CHARACTERS[$i]}"
    PORT="${PORTS[$i]}"
    MODBUS_PORT="${MODBUS_PORTS[$i]}"
    WS_PORT="${WEBSOCKET_PORTS[$i]}"
    
    echo ""
    echo "🎭 $CHARACTER Simulator:"
    
    # Check if log file exists and shows successful startup
    LOG_EXISTS=false
    IS_HEALTHY=false
    
    if [ -f "${CHARACTER}.log" ]; then
        LOG_EXISTS=true
        if grep -q "simulator running on port $PORT" "${CHARACTER}.log" 2>/dev/null; then
            IS_HEALTHY=true
        fi
    fi
    
    # Check if ports are listening to determine if process is running
    DASHBOARD_LISTENING=false
    MODBUS_LISTENING=false
    WS_LISTENING=false
    
    if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
        DASHBOARD_LISTENING=true
    fi
    
    if netstat -tuln 2>/dev/null | grep -q ":$MODBUS_PORT "; then
        MODBUS_LISTENING=true
    fi
    
    if netstat -tuln 2>/dev/null | grep -q ":$WS_PORT "; then
        WS_LISTENING=true
    fi
    
    # Determine if simulator is running based on port listening
    if [ "$DASHBOARD_LISTENING" = true ]; then
        # Get PID from netstat
        PID=$(netstat -tulpn 2>/dev/null | grep ":$PORT " | awk '{print $7}' | cut -d'/' -f1)
        echo "   ✅ Process: Running (PID: $PID)"
        TOTAL_RUNNING=$((TOTAL_RUNNING + 1))
        
        echo "   ✅ Dashboard: http://localhost:$PORT (listening)"
        
        if [ "$MODBUS_LISTENING" = true ]; then
            echo "   ✅ MODBUS: localhost:$MODBUS_PORT (listening)"
        else
            echo "   ⚠️  MODBUS: localhost:$MODBUS_PORT (not ready yet)"
        fi
        
        if [ "$WS_LISTENING" = true ]; then
            echo "   ✅ WebSocket: Port $WS_PORT (listening)"
        else
            echo "   ❌ WebSocket: Port $WS_PORT not listening"
        fi
        
        if [ "$IS_HEALTHY" = true ]; then
            echo "   ✅ Status: Healthy"
        else
            echo "   ⚠️  Status: Check ${CHARACTER}.log for issues"
        fi
        
    else
        echo "   ❌ Process: Not running"
        echo "   ❌ Dashboard: http://localhost:$PORT (offline)"
        echo "   ❌ MODBUS: localhost:$MODBUS_PORT (offline)"
        echo "   ❌ WebSocket: Port $WS_PORT (offline)"
        
        if [ "$LOG_EXISTS" = true ] && [ "$IS_HEALTHY" = false ]; then
            echo "   ⚠️  Status: Failed to start (check ${CHARACTER}.log)"
        fi
    fi
done

echo ""
echo "=============================================="
echo "📈 Summary: $TOTAL_RUNNING/${#CHARACTERS[@]} simulators running"

if [ $TOTAL_RUNNING -eq ${#CHARACTERS[@]} ]; then
    echo "🎉 All simulators are running!"
elif [ $TOTAL_RUNNING -eq 0 ]; then
    echo "🛑 No simulators are running. Use './scripts/start-all.sh' to start them."
else
    echo "⚠️  Some simulators are down. Use './scripts/restart-all.sh' to restart all."
fi

echo ""
echo "💡 Available commands:"
echo "   ./scripts/start-all.sh   - Start all simulators"
echo "   ./scripts/stop-all.sh    - Stop all simulators"
echo "   ./scripts/restart-all.sh - Restart all simulators"
echo "   ./scripts/status.sh      - Show this status"
