#!/bin/bash

# AI-Kit Node-RED Character Simulators - Quick Management Script
# This script provides quick access to all management functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo "🎭 AI-Kit Node-RED Character Simulators Manager"
    echo "=============================================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start    - Start all simulators"
    echo "  stop     - Stop all simulators"
    echo "  restart  - Restart all simulators"
    echo "  status   - Show simulator status"
    echo "  urls     - Show all dashboard URLs"
    echo "  logs     - Show recent logs from all simulators"
    echo "  test-ws  - Test WebSocket connections"
    echo "  build    - Build TypeScript and restart simulators"
    echo "  help     - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 restart"
}

show_urls() {
    echo "🌐 AI-Kit Character Simulator URLs"
    echo "=================================="
    echo "🎯 Kyoko Kirigiri:     http://localhost:1881"
    echo "💰 Byakuya Togami:     http://localhost:1882"  
    echo "💻 Chihiro Fujisaki:   http://localhost:1883"
    echo "👑 Celestia Ludenberg: http://localhost:1884"
    echo "💪 Sakura Ogami:       http://localhost:1885"
}

show_logs() {
    echo "📝 Recent Simulator Logs"
    echo "========================"
    cd "$(dirname "$SCRIPT_DIR")"
    
    for character in kyoko byakuya chihiro celestia sakura; do
        if [ -f "${character}.log" ]; then
            echo ""
            echo "🎭 $character:"
            tail -3 "${character}.log" 2>/dev/null | sed 's/^/   /'
        fi
    done
}

build_and_restart() {
    echo "🔨 Building TypeScript and restarting simulators..."
    cd "$(dirname "$SCRIPT_DIR")"
    
    echo "📦 Building TypeScript..."
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful, restarting simulators..."
        "$SCRIPT_DIR/restart-all.sh"
    else
        echo "❌ Build failed, not restarting simulators"
        exit 1
    fi
}

case "$1" in
    start)
        "$SCRIPT_DIR/start-all.sh"
        ;;
    stop)
        "$SCRIPT_DIR/stop-all.sh"
        ;;
    restart)
        "$SCRIPT_DIR/restart-all.sh"
        ;;
    status)
        "$SCRIPT_DIR/status.sh"
        ;;
    urls)
        show_urls
        ;;
    logs)
        show_logs
        ;;
    test-ws)
        "$SCRIPT_DIR/test-websockets.sh"
        ;;
    build)
        build_and_restart
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
