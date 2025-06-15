#!/bin/bash

# AI-Kit Industrial IoT - Unified Admin Console
# Comprehensive management tool for the entire AI-Kit system

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${PROJECT_ROOT}/scripts"
ADMIN_DIR="${SCRIPT_DIR}/admin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Character configuration
declare -A CHARACTERS=(
    ["kyoko"]="🕵️,purple,1881,5020,Investigation & Analysis"
    ["byakuya"]="💼,yellow,1882,5021,Quality Control"
    ["chihiro"]="💻,green,1883,5022,System Integration"
    ["celestia"]="🎨,red,1884,5023,UI/UX Design"
    ["sakura"]="💪,orange,1885,5024,Reliability Testing"
)

# Platform detection
detect_platform() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl2"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

PLATFORM=$(detect_platform)

# Background process tracking
BACKGROUND_PIDS=()

track_background_process() {
    local pid="$1"
    local description="$2"
    BACKGROUND_PIDS+=("$pid:$description")
}

show_background_processes() {
    echo -e "${CYAN}🔄 Background Processes:${NC}"
    if [ ${#BACKGROUND_PIDS[@]} -eq 0 ]; then
        echo -e "   No tracked background processes"
    else
        for process in "${BACKGROUND_PIDS[@]}"; do
            local pid="${process%%:*}"
            local desc="${process#*:}"
            if kill -0 "$pid" 2>/dev/null; then
                echo -e "   PID $pid: ${GREEN}✅ Running${NC} - $desc"
            else
                echo -e "   PID $pid: ${RED}❌ Stopped${NC} - $desc"
            fi
        done
    fi
}

cleanup_background_processes() {
    echo -e "${YELLOW}🧹 Cleaning up background processes...${NC}"
    for process in "${BACKGROUND_PIDS[@]}"; do
        local pid="${process%%:*}"
        local desc="${process#*:}"
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "   Stopping PID $pid ($desc)..."
            kill "$pid" 2>/dev/null || true
        fi
    done
    BACKGROUND_PIDS=()
    echo -e "${GREEN}✅ Background cleanup complete${NC}"
}

print_banner() {
    clear
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${PURPLE}🎭 AI-Kit Industrial IoT - Unified Admin Console${NC}"
    echo -e "${PURPLE}   Platform: $PLATFORM | Project: $(basename "$PROJECT_ROOT")${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    echo ""
}

show_system_status() {
    echo -e "${CYAN}📊 System Status Dashboard${NC}"
    echo -e "${CYAN}==========================${NC}"
    
    # Check main dashboard
    echo -n "🏭 Main Dashboard (4321): "
    if curl -s --connect-timeout 2 "http://localhost:4321" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Online${NC}"
    else
        echo -e "${RED}❌ Offline${NC}"
    fi
    
    # Check each character service
    for character in kyoko byakuya chihiro celestia sakura; do
        IFS=',' read -r emoji color port modbus_port specialization <<< "${CHARACTERS[$character]}"
        echo -n "$emoji $(echo $character | sed 's/^./\U&/') ($port/$modbus_port): "
        
        if curl -s --connect-timeout 2 "http://localhost:$port" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Online${NC}"
        else
            echo -e "${RED}❌ Offline${NC}"
        fi
    done
    
    # System info
    echo ""
    echo -e "${CYAN}💾 System Resources:${NC}"
    if command -v free >/dev/null 2>&1; then
        local mem_info=$(free -h | grep "Mem:")
        local mem_used=$(echo "$mem_info" | awk '{print $3}')
        local mem_total=$(echo "$mem_info" | awk '{print $2}')
        echo -e "   Memory: $mem_used / $mem_total"
    fi
    
    # Process count
    local node_processes=$(pgrep node 2>/dev/null | wc -l)
    local chrome_processes=$(pgrep chrome 2>/dev/null | wc -l)
    echo -e "   Node.js processes: $node_processes"
    echo -e "   Browser processes: $chrome_processes"
    
    # Background processes
    echo ""
    show_background_processes
}

system_management_menu() {
    while true; do
        print_banner
        echo -e "${GREEN}🚀 SYSTEM MANAGEMENT${NC}"
        echo -e "${GREEN}===================${NC}"
        echo ""
        echo "1. Setup & Installation"
        echo "2. Start Complete System"
        echo "3. Stop System"
        echo "4. Restart System"
        echo "5. Service Status"
        echo "6. Quick Service Check"
        echo "7. Background Process Management"
        echo "0. Back to Main Menu"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                echo -e "${BLUE}🔧 Running system setup...${NC}"
                if [ -f "$PROJECT_ROOT/setup.sh" ]; then
                    bash "$PROJECT_ROOT/setup.sh"
                else
                    echo -e "${RED}❌ setup.sh not found${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -e "${BLUE}🚀 Starting complete system...${NC}"
                if [ -f "$PROJECT_ROOT/launch-complete-system.sh" ]; then
                    echo -e "${CYAN}⚡ Launching system in background...${NC}"
                    nohup bash "$PROJECT_ROOT/launch-complete-system.sh" > /dev/null 2>&1 &
                    local launch_pid=$!
                    track_background_process "$launch_pid" "System Launch"
                    echo -e "${GREEN}✅ System startup initiated (PID: $launch_pid)${NC}"
                    echo -e "${YELLOW}💡 Services will start in background. Check status in a few moments.${NC}"
                else
                    echo -e "${RED}❌ launch-complete-system.sh not found${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "${YELLOW}⏹️  Stopping system services...${NC}"
                pkill -f "node.*node-red" 2>/dev/null || true
                pkill -f "npm.*dev" 2>/dev/null || true
                echo -e "${GREEN}✅ Services stopped${NC}"
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${YELLOW}🔄 Restarting system...${NC}"
                # Stop services
                pkill -f "node.*node-red" 2>/dev/null || true
                pkill -f "npm.*dev" 2>/dev/null || true
                sleep 2
                # Start system in background
                if [ -f "$PROJECT_ROOT/launch-complete-system.sh" ]; then
                    echo -e "${CYAN}⚡ Restarting system in background...${NC}"
                    nohup bash "$PROJECT_ROOT/launch-complete-system.sh" > /dev/null 2>&1 &
                    local restart_pid=$!
                    track_background_process "$restart_pid" "System Restart"
                    echo -e "${GREEN}✅ System restart initiated (PID: $restart_pid)${NC}"
                    echo -e "${YELLOW}💡 Services will restart in background. Check status in a few moments.${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            5)
                show_system_status
                read -p "Press Enter to continue..."
                ;;
            6)
                echo -e "${BLUE}🔍 Quick service connectivity check...${NC}"
                show_system_status
                read -p "Press Enter to continue..."
                ;;
            7)
                echo -e "${PURPLE}🔄 Background Process Management${NC}"
                echo ""
                show_background_processes
                echo ""
                echo "1. Clean up all background processes"
                echo "2. Kill specific background process"
                echo "0. Back"
                echo ""
                read -p "Enter choice: " bg_choice
                
                case $bg_choice in
                    1)
                        cleanup_background_processes
                        ;;
                    2)
                        echo ""
                        show_background_processes
                        echo ""
                        read -p "Enter PID to kill: " kill_pid
                        if [[ "$kill_pid" =~ ^[0-9]+$ ]]; then
                            if kill -0 "$kill_pid" 2>/dev/null; then
                                kill "$kill_pid" 2>/dev/null
                                echo -e "${GREEN}✅ Process $kill_pid terminated${NC}"
                            else
                                echo -e "${RED}❌ Process $kill_pid not found${NC}"
                            fi
                        else
                            echo -e "${RED}❌ Invalid PID${NC}"
                        fi
                        ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

window_management_menu() {
    while true; do
        print_banner
        echo -e "${BLUE}🖥️  WINDOW MANAGEMENT${NC}"
        echo -e "${BLUE}===================${NC}"
        echo -e "Platform: $PLATFORM"
        echo ""
        echo "1. Launch Character Workspaces"
        echo "2. Create Browser Grid (WSL2/Linux)"
        echo "3. Create Virtual Desktops (Windows)"
        echo "4. Kill All Browser Windows"
        echo "5. Test Display Capabilities"
        echo "6. Show Window Management Tips"
        echo "0. Back to Main Menu"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                echo -e "${CYAN}🎭 Launching character workspaces...${NC}"
                case $PLATFORM in
                    "windows")
                        if [ -f "$SCRIPT_DIR/windows-virtual-desktops.ps1" ]; then
                            powershell.exe -ExecutionPolicy Bypass -File "$SCRIPT_DIR/windows-virtual-desktops.ps1"
                        else
                            echo -e "${RED}❌ Windows script not found${NC}"
                        fi
                        ;;
                    "wsl2"|"linux")
                        if [ -f "$SCRIPT_DIR/wsl2-browser-grid.sh" ]; then
                            echo -e "${CYAN}⚡ Launching browser grid in background...${NC}"
                            nohup bash "$SCRIPT_DIR/wsl2-browser-grid.sh" --create-all > /dev/null 2>&1 &
                            local grid_pid=$!
                            track_background_process "$grid_pid" "Browser Grid Creation"
                            echo -e "${GREEN}✅ Browser grid creation initiated (PID: $grid_pid)${NC}"
                            echo -e "${YELLOW}💡 Browser windows will appear shortly.${NC}"
                        else
                            echo -e "${RED}❌ WSL2 script not found${NC}"
                        fi
                        ;;
                    *)
                        echo -e "${YELLOW}⚠️  Platform-specific tools not available for: $PLATFORM${NC}"
                        ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            2)
                if [[ "$PLATFORM" == "wsl2" || "$PLATFORM" == "linux" ]]; then
                    if [ -f "$SCRIPT_DIR/wsl2-browser-grid.sh" ]; then
                        echo -e "${CYAN}⚡ Launching interactive browser grid...${NC}"
                        # Interactive script needs to run in foreground
                        bash "$SCRIPT_DIR/wsl2-browser-grid.sh"
                    else
                        echo -e "${RED}❌ WSL2 browser grid script not found${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  Browser grid is for WSL2/Linux only${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            3)
                if [ "$PLATFORM" == "windows" ]; then
                    if [ -f "$SCRIPT_DIR/windows-virtual-desktops.ps1" ]; then
                        powershell.exe -ExecutionPolicy Bypass -File "$SCRIPT_DIR/windows-virtual-desktops.ps1"
                    else
                        echo -e "${RED}❌ Windows virtual desktop script not found${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  Virtual desktops are for Windows only${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${RED}💥 Killing all browser windows...${NC}"
                case $PLATFORM in
                    "windows")
                        powershell.exe -Command "Get-Process chrome,msedge,firefox -ErrorAction SilentlyContinue | Stop-Process -Force"
                        ;;
                    *)
                        pkill -f chrome 2>/dev/null || true
                        pkill -f firefox 2>/dev/null || true
                        pkill -f edge 2>/dev/null || true
                        ;;
                esac
                echo -e "${GREEN}✅ Browser cleanup complete${NC}"
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "${BLUE}🔍 Testing display capabilities...${NC}"
                if [ -f "$SCRIPT_DIR/test-wsl2-capabilities.sh" ]; then
                    bash "$SCRIPT_DIR/test-wsl2-capabilities.sh"
                else
                    echo -e "${YELLOW}⚠️  Capability test script not found${NC}"
                    echo "Testing basic capabilities:"
                    echo -n "DISPLAY: "; echo "${DISPLAY:-Not set}"
                    echo -n "Screen resolution: "
                    if command -v xrandr >/dev/null 2>&1; then
                        xrandr | grep "current" | awk '{print $8 "x" $10}' | tr -d ','
                    else
                        echo "Unknown"
                    fi
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                echo -e "${CYAN}🎮 Window Management Tips${NC}"
                echo -e "${CYAN}=========================${NC}"
                echo ""
                case $PLATFORM in
                    "windows")
                        echo -e "Windows Virtual Desktop shortcuts:"
                        echo -e "• Win + Tab: Task View"
                        echo -e "• Win + Ctrl + D: Create new desktop"
                        echo -e "• Win + Ctrl + Left/Right: Switch desktops"
                        echo -e "• Win + Ctrl + F4: Close current desktop"
                        ;;
                    "wsl2"|"linux")
                        echo -e "Browser Window shortcuts:"
                        echo -e "• Ctrl + Shift + A: Chrome app launcher"
                        echo -e "• Ctrl + W: Close current tab"
                        echo -e "• Ctrl + Shift + W: Close current window"
                        echo -e "• Alt + Tab: Switch between windows"
                        echo -e "• Ctrl + \`: Switch between Chrome windows"
                        ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

monitoring_diagnostics_menu() {
    while true; do
        print_banner
        echo -e "${YELLOW}📊 MONITORING & DIAGNOSTICS${NC}"
        echo -e "${YELLOW}===========================${NC}"
        echo ""
        echo "1. Service Health Check"
        echo "2. View Live Logs"
        echo "3. Connection Testing"
        echo "4. Performance Monitor"
        echo "5. Error Analysis"
        echo "6. WebSocket Testing"
        echo "0. Back to Main Menu"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                show_system_status
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -e "${BLUE}📝 Live log monitoring...${NC}"
                echo "Available log files:"
                find "$PROJECT_ROOT" -name "*.log" -type f 2>/dev/null | head -10
                echo ""
                echo "1. Show recent logs (quick view)"
                echo "2. Live tail specific log file"
                echo "0. Back"
                echo ""
                read -p "Enter choice: " log_choice
                
                case $log_choice in
                    1)
                        echo -e "${CYAN}📄 Recent logs from all files:${NC}"
                        find "$PROJECT_ROOT" -name "*.log" -type f -exec sh -c 'echo "=== $1 ==="; tail -3 "$1" 2>/dev/null' _ {} \;
                        ;;
                    2)
                        read -p "Enter log file path: " log_file
                        if [ -f "$log_file" ]; then
                            echo -e "${CYAN}⚡ Starting live log tail in background...${NC}"
                            echo -e "${YELLOW}💡 Press Ctrl+C to stop log monitoring${NC}"
                            sleep 2
                            tail -f "$log_file"
                        else
                            echo -e "${RED}❌ Log file not found: $log_file${NC}"
                        fi
                        ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "${BLUE}🔍 Testing connections...${NC}"
                show_system_status
                
                echo ""
                echo -e "${CYAN}WebSocket Testing:${NC}"
                for character in kyoko byakuya chihiro celestia sakura; do
                    IFS=',' read -r emoji color port modbus_port specialization <<< "${CHARACTERS[$character]}"
                    echo -n "$emoji $character websocket: "
                    if command -v wscat >/dev/null 2>&1; then
                        timeout 3 wscat -c "ws://localhost:$port/ws" -x "ping" 2>/dev/null && echo -e "${GREEN}✅${NC}" || echo -e "${RED}❌${NC}"
                    else
                        echo -e "${YELLOW}wscat not available${NC}"
                    fi
                done
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${BLUE}📈 Performance monitoring...${NC}"
                
                # CPU and Memory
                if command -v top >/dev/null 2>&1; then
                    echo "Top processes (5 seconds):"
                    timeout 5 top -b -n 1 | head -15
                fi
                
                # Disk usage
                if command -v df >/dev/null 2>&1; then
                    echo ""
                    echo "Disk usage:"
                    df -h | grep -E "(Filesystem|/dev)"
                fi
                
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "${RED}🔍 Error analysis...${NC}"
                echo "Scanning logs for errors..."
                
                # Search for common error patterns
                find "$PROJECT_ROOT" -name "*.log" -type f -exec grep -l -i "error\|fail\|exception" {} \; 2>/dev/null | while read -r log_file; do
                    echo ""
                    echo -e "${YELLOW}Errors in $(basename "$log_file"):${NC}"
                    grep -i "error\|fail\|exception" "$log_file" | tail -3 | sed 's/^/  /'
                done
                
                read -p "Press Enter to continue..."
                ;;
            6)
                echo -e "${BLUE}🔌 WebSocket testing...${NC}"
                if [ -f "$PROJECT_ROOT/node-red-plc-simulator/scripts/test-websockets.sh" ]; then
                    bash "$PROJECT_ROOT/node-red-plc-simulator/scripts/test-websockets.sh"
                else
                    echo -e "${YELLOW}⚠️  WebSocket test script not found${NC}"
                    # Basic WebSocket test
                    for character in kyoko byakuya chihiro celestia sakura; do
                        IFS=',' read -r emoji color port modbus_port specialization <<< "${CHARACTERS[$character]}"
                        echo -n "$emoji Testing $character (port $port): "
                        if curl -s --connect-timeout 2 "http://localhost:$port/ws" >/dev/null 2>&1; then
                            echo -e "${GREEN}✅ Endpoint available${NC}"
                        else
                            echo -e "${RED}❌ Not responding${NC}"
                        fi
                    done
                fi
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

help_information_menu() {
    while true; do
        print_banner
        echo -e "${PURPLE}📖 HELP & INFORMATION${NC}"
        echo -e "${PURPLE}=====================${NC}"
        echo ""
        echo "1. Show Character Information"
        echo "2. Show Port Mappings"
        echo "3. Show Available URLs"
        echo "4. Troubleshooting Guide"
        echo "5. System Architecture"
        echo "0. Back to Main Menu"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                echo -e "${CYAN}🎭 AI-Kit Character Information${NC}"
                echo -e "${CYAN}===============================${NC}"
                for character in kyoko byakuya chihiro celestia sakura; do
                    IFS=',' read -r emoji color port modbus_port specialization <<< "${CHARACTERS[$character]}"
                    echo -e "\n$emoji $(echo $character | sed 's/^./\U&/') - $specialization"
                    echo -e "   HTTP Port: $port"
                    echo -e "   MODBUS Port: $modbus_port"
                    echo -e "   URL: http://localhost:$port"
                done
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -e "${CYAN}🔌 Port Mapping Reference${NC}"
                echo -e "${CYAN}=========================${NC}"
                echo -e "Main Dashboard:    4321"
                echo -e "Kyoko (Detective): 1881 / 5020"
                echo -e "Byakuya (Quality): 1882 / 5021"
                echo -e "Chihiro (Tech):    1883 / 5022"
                echo -e "Celestia (UI/UX):  1884 / 5023"
                echo -e "Sakura (Testing):  1885 / 5024"
                echo ""
                echo -e "${YELLOW}Note: First port is HTTP, second is MODBUS${NC}"
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "${CYAN}🌐 Available URLs${NC}"
                echo -e "${CYAN}=================${NC}"
                echo -e "🏭 Main Dashboard:     http://localhost:4321"
                echo -e "🕵️  Kyoko Dashboard:    http://localhost:1881"
                echo -e "💼 Byakuya Dashboard:   http://localhost:1882"
                echo -e "💻 Chihiro Dashboard:   http://localhost:1883"
                echo -e "🎨 Celestia Dashboard:  http://localhost:1884"
                echo -e "💪 Sakura Dashboard:    http://localhost:1885"
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${YELLOW}🔧 Troubleshooting Guide${NC}"
                echo -e "${YELLOW}========================${NC}"
                echo ""
                echo -e "${CYAN}Common Issues:${NC}"
                echo "1. Services not starting:"
                echo "   - Check Node.js installation"
                echo "   - Run setup.sh first"
                echo "   - Check port conflicts"
                echo ""
                echo "2. Browser windows not appearing:"
                echo "   - Check DISPLAY variable (WSL2)"
                echo "   - Test X11 forwarding"
                echo "   - Try running capability test"
                echo ""
                echo "3. Connection timeouts:"
                echo "   - Wait for services to fully start"
                echo "   - Check firewall settings"
                echo "   - Verify localhost resolution"
                echo ""
                echo -e "${CYAN}Debug Commands:${NC}"
                echo "- Check processes: ps aux | grep node"
                echo "- Check ports: netstat -tulpn | grep :18"
                echo "- Check logs: find . -name '*.log' -exec tail {} \\;"
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "${PURPLE}🏗️  System Architecture${NC}"
                echo -e "${PURPLE}======================${NC}"
                echo ""
                echo -e "${CYAN}Components:${NC}"
                echo "• Astro-Host Dashboard (Port 4321)"
                echo "• Node-RED Character Simulators (Ports 1881-1885)"
                echo "• MODBUS TCP Servers (Ports 5020-5024)"
                echo "• PocketSocket PLC Engine"
                echo "• Universal PLC Adapter"
                echo "• Character-Driven AI Agents"
                echo ""
                echo -e "${CYAN}Data Flow:${NC}"
                echo "Browser ↔ Astro Dashboard ↔ Character Agents ↔ Node-RED ↔ MODBUS ↔ PLC"
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

main_menu() {
    while true; do
        print_banner
        show_system_status
        echo ""
        echo -e "${CYAN}🎮 MAIN MENU${NC}"
        echo -e "${CYAN}============${NC}"
        echo ""
        echo "1. 🚀 System Management"
        echo "2. 🖥️  Window Management"
        echo "3. 📊 Monitoring & Diagnostics"
        echo "4. 🔧 Maintenance (Coming Soon)"
        echo "5. 🧪 Testing & Validation (Coming Soon)"
        echo "6. 📖 Help & Information"
        echo "0. Exit"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                system_management_menu
                ;;
            2)
                window_management_menu
                ;;
            3)
                monitoring_diagnostics_menu
                ;;
            4)
                echo -e "${YELLOW}🔧 Maintenance features coming in next update...${NC}"
                sleep 2
                ;;
            5)
                echo -e "${YELLOW}🧪 Testing features coming in next update...${NC}"
                sleep 2
                ;;
            6)
                help_information_menu
                ;;
            0)
                # Exit will trigger cleanup_on_exit via trap
                exit 0
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

# Cleanup function for script exit
cleanup_on_exit() {
    echo ""
    echo -e "${YELLOW}🧹 Cleaning up before exit...${NC}"
    if [ ${#BACKGROUND_PIDS[@]} -gt 0 ]; then
        echo -e "${CYAN}Background processes still running:${NC}"
        show_background_processes
        echo ""
        read -p "Clean up background processes before exit? (y/N): " cleanup_choice
        if [[ $cleanup_choice =~ ^[Yy]$ ]]; then
            cleanup_background_processes
        fi
    fi
    echo -e "${GREEN}👋 Goodbye! AI-Kit Industrial IoT Admin Console${NC}"
}

# Set up exit trap
trap cleanup_on_exit EXIT

# Main execution
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "🎭 AI-Kit Industrial IoT - Unified Admin Console"
    echo "==============================================="
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help"
    echo "  --status       Show system status and exit"
    echo "  --platform     Show platform info and exit"
    echo ""
    echo "Interactive mode:"
    echo "  $0             Launch interactive admin console"
    exit 0
elif [ "${1:-}" = "--status" ]; then
    show_system_status
    exit 0
elif [ "${1:-}" = "--platform" ]; then
    echo "Platform: $PLATFORM"
    echo "Project: $PROJECT_ROOT"
    exit 0
else
    # Launch interactive console
    main_menu
fi
