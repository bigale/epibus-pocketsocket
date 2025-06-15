#!/bin/bash

# AI-Kit Character Simulators - Interactive Demo
# This script provides a guided tour of the character simulators

echo "🎭 Welcome to AI-Kit Industrial IoT Character Simulators!"
echo "======================================================="
echo ""
echo "This demo will guide you through using the character-driven"
echo "industrial automation system with Danganronpa personalities."
echo ""

# Check if simulators are running
echo "🔍 Checking simulator status..."
cd "$(dirname "$0")"
STATUS_OUTPUT=$(./scripts/manage.sh status 2>/dev/null)

if echo "$STATUS_OUTPUT" | grep -q "5/5 simulators running"; then
    echo "✅ All simulators are running!"
else
    echo "⚠️  Not all simulators are running. Starting them now..."
    ./scripts/manage.sh start
    sleep 10
fi

echo ""
echo "🌐 Character Dashboard URLs:"
echo "============================"
./scripts/manage.sh urls

echo ""
echo "📋 Demo Scenarios Available:"
echo "1. 🎯 Kyoko's Detective Lab - Anomaly Detection Demo"
echo "2. 💰 Byakuya's Efficiency Center - Performance Monitoring"
echo "3. 💻 Chihiro's Integration Hub - Data Processing Pipeline"
echo "4. 👑 Celestia's Risk Center - Predictive Analytics"
echo "5. 💪 Sakura's Testing Lab - Reliability Monitoring"
echo "6. 🎭 Multi-Character Collaboration Demo"
echo "7. 📊 View All Character Status"
echo "8. 🔧 Management Tools Overview"
echo ""

while true; do
    read -p "Choose a demo (1-8) or 'q' to quit: " choice
    
    case $choice in
        1)
            echo ""
            echo "🎯 KYOKO'S DETECTIVE LAB - Anomaly Detection Demo"
            echo "================================================"
            echo "Kyoko specializes in investigating anomalies and solving mysteries."
            echo "Her dashboard includes:"
            echo "• Anomaly detection algorithms"
            echo "• Evidence collection workflows"
            echo "• Investigation flow templates"
            echo "• Root cause analysis tools"
            echo ""
            echo "Opening Kyoko's dashboard..."
            if command -v xdg-open >/dev/null; then
                xdg-open "http://localhost:1881" 2>/dev/null &
            else
                echo "Visit: http://localhost:1881"
            fi
            echo ""
            echo "💡 Try This:"
            echo "1. Look for the 'anomaly-detector' node in the palette"
            echo "2. Create a flow: [inject] → [anomaly-detector] → [debug]"
            echo "3. Configure the anomaly detector with sample data"
            echo "4. Deploy and test the flow"
            echo ""
            ;;
        2)
            echo ""
            echo "💰 BYAKUYA'S EFFICIENCY CENTER - Performance Monitoring"
            echo "======================================================"
            echo "Byakuya focuses on optimization and performance excellence."
            echo "His dashboard includes:"
            echo "• Efficiency optimization tools"
            echo "• Performance monitoring dashboards"
            echo "• Cost analysis calculators"
            echo "• Quality control systems"
            echo ""
            echo "Opening Byakuya's dashboard..."
            if command -v xdg-open >/dev/null; then
                xdg-open "http://localhost:1882" 2>/dev/null &
            else
                echo "Visit: http://localhost:1882"
            fi
            echo ""
            echo "💡 Try This:"
            echo "1. Find the 'efficiency-optimizer' node"
            echo "2. Create a monitoring flow with performance metrics"
            echo "3. Add a dashboard chart to visualize efficiency"
            echo "4. Set up alerts for performance thresholds"
            echo ""
            ;;
        3)
            echo ""
            echo "💻 CHIHIRO'S INTEGRATION HUB - Data Processing Pipeline"
            echo "======================================================"
            echo "Chihiro excels at data processing and system integration."
            echo "Their dashboard includes:"
            echo "• Advanced data processing nodes"
            echo "• System integration connectors"
            echo "• Database connectivity tools"
            echo "• Complex logic builders"
            echo ""
            echo "Opening Chihiro's dashboard..."
            if command -v xdg-open >/dev/null; then
                xdg-open "http://localhost:1883" 2>/dev/null &
            else
                echo "Visit: http://localhost:1883"
            fi
            echo ""
            echo "💡 Try This:"
            echo "1. Use the 'data-processor' node for data transformation"
            echo "2. Connect multiple data sources with 'system-integrator'"
            echo "3. Build complex logic with 'logic-builder'"
            echo "4. Store results using 'database-connector'"
            echo ""
            ;;
        4)
            echo ""
            echo "👑 CELESTIA'S RISK CENTER - Predictive Analytics"
            echo "==============================================="
            echo "Celestia specializes in risk assessment and strategic planning."
            echo "Her dashboard includes:"
            echo "• Risk assessment algorithms"
            echo "• Predictive modeling tools"
            echo "• Strategic planning workflows"
            echo "• Probability calculators"
            echo ""
            echo "Opening Celestia's dashboard..."
            if command -v xdg-open >/dev/null; then
                xdg-open "http://localhost:1884" 2>/dev/null &
            else
                echo "Visit: http://localhost:1884"
            fi
            echo ""
            echo "💡 Try This:"
            echo "1. Use 'risk-assessor' to evaluate operational risks"
            echo "2. Create predictive models with 'predictor' node"
            echo "3. Plan strategies using 'strategy-planner'"
            echo "4. Calculate probabilities for decision making"
            echo ""
            ;;
        5)
            echo ""
            echo "💪 SAKURA'S TESTING LAB - Reliability Monitoring"
            echo "==============================================="
            echo "Sakura focuses on system reliability and endurance testing."
            echo "Her dashboard includes:"
            echo "• Stress testing tools"
            echo "• Endurance monitoring systems"
            echo "• Load generation utilities"
            echo "• Reliability analysis algorithms"
            echo ""
            echo "Opening Sakura's dashboard..."
            if command -v xdg-open >/dev/null; then
                xdg-open "http://localhost:1885" 2>/dev/null &
            else
                echo "Visit: http://localhost:1885"
            fi
            echo ""
            echo "💡 Try This:"
            echo "1. Set up stress tests with 'stress-tester'"
            echo "2. Monitor long-term performance with 'endurance-monitor'"
            echo "3. Generate test loads using 'load-generator'"
            echo "4. Analyze reliability metrics"
            echo ""
            ;;
        6)
            echo ""
            echo "🎭 MULTI-CHARACTER COLLABORATION DEMO"
            echo "===================================="
            echo "See how characters work together for comprehensive automation:"
            echo ""
            echo "Opening all character dashboards..."
            for port in 1881 1882 1883 1884 1885; do
                if command -v xdg-open >/dev/null; then
                    xdg-open "http://localhost:$port" 2>/dev/null &
                else
                    echo "Visit: http://localhost:$port"
                fi
                sleep 1
            done
            echo ""
            echo "💡 Collaboration Ideas:"
            echo "1. 🎯 Kyoko detects anomalies → 💰 Byakuya optimizes response"
            echo "2. 👑 Celestia predicts risks → 💪 Sakura tests reliability"
            echo "3. 💻 Chihiro processes data → All characters analyze results"
            echo "4. Cross-character MQTT/HTTP communication"
            echo ""
            echo "🔗 Integration Points:"
            echo "• MQTT broker for real-time data sharing"
            echo "• HTTP APIs for character communication"
            echo "• Shared databases for persistent data"
            echo "• WebSocket connections for live updates"
            echo ""
            ;;
        7)
            echo ""
            echo "📊 ALL CHARACTER STATUS"
            echo "======================"
            ./scripts/manage.sh status
            echo ""
            echo "💡 Status Information:"
            echo "• Process: Shows if character simulator is running"
            echo "• Dashboard: HTTP interface for Node-RED editor"
            echo "• MODBUS: Industrial protocol server status"
            echo "• WebSocket: Real-time communication status"
            echo "• Status: Overall health assessment"
            echo ""
            ;;
        8)
            echo ""
            echo "🔧 MANAGEMENT TOOLS OVERVIEW"
            echo "============================"
            echo "Available management commands:"
            echo ""
            echo "./scripts/manage.sh start    - Start all simulators"
            echo "./scripts/manage.sh stop     - Stop all simulators"
            echo "./scripts/manage.sh restart  - Restart all simulators"
            echo "./scripts/manage.sh status   - Show detailed status"
            echo "./scripts/manage.sh urls     - List dashboard URLs"
            echo "./scripts/manage.sh logs     - View recent logs"
            echo "./scripts/manage.sh test-ws  - Test WebSocket connections"
            echo "./scripts/manage.sh build    - Build and restart"
            echo ""
            echo "Individual script usage:"
            echo "./scripts/start-all.sh       - Start with verification"
            echo "./scripts/stop-all.sh        - Safe shutdown"
            echo "./scripts/status.sh          - Detailed health check"
            echo ""
            echo "💡 Pro Tips:"
            echo "• Always check status before making changes"
            echo "• Use logs to troubleshoot issues"
            echo "• test-ws helps diagnose connection problems"
            echo "• build command rebuilds TypeScript automatically"
            echo ""
            ;;
        q|Q)
            echo ""
            echo "🎉 Thanks for exploring the AI-Kit Character Simulators!"
            echo "Remember: Each character brings unique personality and"
            echo "expertise to your industrial automation challenges."
            echo ""
            echo "📚 For more information, see:"
            echo "• USER-GUIDE.md - Complete usage documentation"
            echo "• scripts/README.md - Management scripts reference"
            echo ""
            echo "Happy automating! 🤖✨"
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1-8 or 'q' to quit."
            ;;
    esac
    
    if [[ $choice =~ ^[1-6]$ ]]; then
        echo ""
        read -p "Press Enter to continue..."
    fi
    echo ""
done
