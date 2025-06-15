#!/bin/bash

# Astro Host Management Script
# Provides easy commands to manage the Astro development server

case "$1" in
    start)
        echo "🚀 Starting Astro server in background..."
        npm run dev-bg
        ;;
    stop)
        echo "🛑 Stopping Astro server..."
        npm run stop-bg
        ;;
    restart)
        echo "🔄 Restarting Astro server..."
        npm run restart-bg
        ;;
    status)
        echo "📊 Checking Astro server status..."
        npm run status
        ;;
    logs)
        echo "📋 Showing Astro server logs (Ctrl+C to exit)..."
        npm run logs
        ;;
    test)
        echo "🧪 Testing Astro server and API endpoints..."
        if [ -f astro-host.pid ] && kill -0 $(cat astro-host.pid) 2>/dev/null; then
            echo "✅ Astro server is running (PID: $(cat astro-host.pid))"
            
            # Test main page
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/" | grep -q "200"; then
                echo "✅ Main page accessible"
            else
                echo "❌ Main page not accessible"
            fi
            
            # Test Node-RED status API
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/node-red-status" | grep -q "200"; then
                echo "✅ Node-RED status API working"
            else
                echo "❌ Node-RED status API not working"
            fi
            
            # Test a flow page
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/flows/kyoko-reactor-control" | grep -q "200"; then
                echo "✅ Flow pages accessible"
            else
                echo "❌ Flow pages not accessible"
            fi
            
        else
            echo "❌ Astro server is not running"
        fi
        ;;
    *)
        echo "Astro Host Management Script"
        echo "Usage: $0 {start|stop|restart|status|logs|test}"
        echo ""
        echo "Commands:"
        echo "  start   - Start Astro server in background"
        echo "  stop    - Stop Astro server"
        echo "  restart - Restart Astro server"
        echo "  status  - Show server status"
        echo "  logs    - Show server logs (follow)"
        echo "  test    - Test server and API endpoints"
        ;;
esac
