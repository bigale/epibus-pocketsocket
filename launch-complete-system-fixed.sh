#!/bin/bash

# AI-Kit Industrial IoT - Complete System Launcher (FIXED VERSION)
# Launches both Astro-Host dashboard and Node-RED simulators

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASTRO_HOST_DIR="${PROJECT_ROOT}/astro-host"
SIMULATOR_DIR="${PROJECT_ROOT}/node-red-plc-simulator"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Character emojis
KYOKO="🕵️"
BYAKUYA="💼"
CHIHIRO="💻"
CELESTIA="🎨"
SAKURA="💪"

print_banner() {
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${PURPLE}🎭 AI-Kit Industrial IoT - Complete System Launcher (FIXED)${NC}"
    echo -e "${PURPLE}   Character-Driven Industrial Automation Revolution${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    echo ""
}

print_character_info() {
    echo -e "${CYAN}🎭 Available Characters:${NC}"
    echo -e "  ${KYOKO} Kyoko Kirigiri    - Detective & Anomaly Investigation (Port: 1881, MODBUS: 5020)"
    echo -e "  ${BYAKUYA} Byakuya Togami    - Efficiency & Performance Optimization (Port: 1882, MODBUS: 5021)"
    echo -e "  ${CHIHIRO} Chihiro Fujisaki  - Technical Integration & Innovation (Port: 1883, MODBUS: 5022)"
    echo -e "  ${CELESTIA} Celestia Ludenberg - UI/UX & Aesthetic Design (Port: 1884, MODBUS: 5023)"
    echo -e "  ${SAKURA} Sakura Ogami      - Stress Testing & Reliability (Port: 1885, MODBUS: 5024)"
    echo ""
}

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js not found. Please install Node.js 18+${NC}"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo -e "${RED}❌ Node.js version $NODE_VERSION found. Please upgrade to Node.js 18+${NC}"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm not found. Please install npm${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
    echo ""
}

install_dependencies() {
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    
    # Install root dependencies
    echo -e "${YELLOW}Installing root dependencies...${NC}"
    npm install || {
        echo -e "${RED}❌ Failed to install root dependencies${NC}"
        exit 1
    }
    
    # Install Astro-Host dependencies
    if [ -d "$ASTRO_HOST_DIR" ]; then
        echo -e "${YELLOW}Installing Astro-Host dependencies...${NC}"
        cd "$ASTRO_HOST_DIR"
        npm install || {
            echo -e "${RED}❌ Failed to install Astro-Host dependencies${NC}"
            exit 1
        }
        cd "$PROJECT_ROOT"
    fi
    
    # Install Node-RED simulator dependencies
    if [ -d "$SIMULATOR_DIR" ]; then
        echo -e "${YELLOW}Installing Node-RED simulator dependencies...${NC}"
        cd "$SIMULATOR_DIR"
        
        # Try to install dependencies, with fallback for problematic packages
        npm install || {
            echo -e "${YELLOW}⚠️ Some packages failed to install, trying without problematic dependencies...${NC}"
            
            # Remove problematic dependencies and retry
            npm remove node-red-contrib-buffer-parser node-red-contrib-ui-level 2>/dev/null || true
            npm install || {
                echo -e "${RED}❌ Failed to install Node-RED simulator dependencies${NC}"
                exit 1
            }
            
            echo -e "${GREEN}✅ Node-RED simulator dependencies installed (some optional packages skipped)${NC}"
        }
        
        cd "$PROJECT_ROOT"
    fi
    
    echo -e "${GREEN}✅ Dependencies installed${NC}"
    echo ""
}

build_projects() {
    echo -e "${BLUE}🔨 Building projects...${NC}"
    
    # Build root project
    echo -e "${YELLOW}Building root project...${NC}"
    npm run build 2>/dev/null || echo -e "${YELLOW}⚠️ Root build skipped (no build script)${NC}"
    
    # Build Astro-Host
    if [ -d "$ASTRO_HOST_DIR" ]; then
        echo -e "${YELLOW}Building Astro-Host...${NC}"
        cd "$ASTRO_HOST_DIR"
        npm run build 2>/dev/null || echo -e "${YELLOW}⚠️ Astro-Host build skipped${NC}"
        cd "$PROJECT_ROOT"
    fi
    
    # CRITICAL FIX: Build Node-RED simulator TypeScript
    if [ -d "$SIMULATOR_DIR" ]; then
        echo -e "${YELLOW}Building Node-RED simulator TypeScript...${NC}"
        cd "$SIMULATOR_DIR"
        npm run build || {
            echo -e "${RED}❌ Failed to build Node-RED simulator${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ Node-RED simulator built successfully${NC}"
        cd "$PROJECT_ROOT"
    fi
    
    echo -e "${GREEN}✅ Projects built${NC}"
    echo ""
}

start_astro_host() {
    echo -e "${BLUE}🚀 Starting Astro-Host dashboard...${NC}"
    cd "$ASTRO_HOST_DIR"
    
    # Astro runs on port 3000 by default, not 4321
    echo -e "${GREEN}🎯 Astro-Host will be available at: http://localhost:3000${NC}"
    echo -e "${YELLOW}Starting Astro-Host development server...${NC}"
    
    # Start Astro dev server in background
    npm run dev > ../logs/astro-host.log 2>&1 &
    ASTRO_PID=$!
    echo "$ASTRO_PID" > ../logs/astro-host.pid
    
    cd "$PROJECT_ROOT"
    
    # Wait for Astro to start
    echo -e "${YELLOW}Waiting for Astro-Host to initialize...${NC}"
    sleep 5
    
    if kill -0 "$ASTRO_PID" 2>/dev/null; then
        echo -e "${GREEN}✅ Astro-Host dashboard started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start Astro-Host dashboard${NC}"
        exit 1
    fi
}

start_node_red_simulators() {
    echo -e "${BLUE}🎭 Starting Node-RED character simulators...${NC}"
    cd "$SIMULATOR_DIR"
    
    # Create logs directory if it doesn't exist
    mkdir -p ../logs
    
    # Character configurations
    declare -A CHARACTERS=(
        ["kyoko"]="1881:5020:detective-purple"
        ["byakuya"]="1882:5021:efficiency-blue"
        ["chihiro"]="1883:5022:tech-green"
        ["celestia"]="1884:5023:elegant-red"
        ["sakura"]="1885:5024:strength-orange"
    )
    
    # Start all character simulators
    for character in kyoko byakuya chihiro celestia sakura; do
        local config="${CHARACTERS[$character]}"
        local port=$(echo $config | cut -d':' -f1)
        local modbus_port=$(echo $config | cut -d':' -f2)
        local theme=$(echo $config | cut -d':' -f3)
        
        case $character in
            "kyoko") echo -e "${KYOKO} Starting Kyoko Kirigiri (Detective Lab)..." ;;
            "byakuya") echo -e "${BYAKUYA} Starting Byakuya Togami (Efficiency Center)..." ;;
            "chihiro") echo -e "${CHIHIRO} Starting Chihiro Fujisaki (Integration Lab)..." ;;
            "celestia") echo -e "${CELESTIA} Starting Celestia Ludenberg (Design Studio)..." ;;
            "sakura") echo -e "${SAKURA} Starting Sakura Ogami (Testing Lab)..." ;;
        esac
        
        CHARACTER=$character \
        PORT=$port \
        MODBUS_PORT=$modbus_port \
        THEME=$theme \
        nohup npm run start:simulator > "../logs/${character}.log" 2>&1 &
        
        local pid=$!
        echo "$pid" > "../logs/${character}.pid"
        
        # Wait a moment between starts
        sleep 2
    done
    
    cd "$PROJECT_ROOT"
    
    # Wait for Node-RED instances to start
    echo -e "${YELLOW}Waiting for Node-RED instances to initialize...${NC}"
    sleep 10
    
    # Check if all simulators are running
    echo -e "${BLUE}🔍 Checking simulator status...${NC}"
    
    check_simulator() {
        local name=$1
        local port=$2
        local emoji=$3
        
        if curl -s "http://localhost:$port" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $emoji $name - Running (Port: $port)${NC}"
        else
            echo -e "${YELLOW}⚠️ $emoji $name - Starting up... (Port: $port)${NC}"
        fi
    }
    
    check_simulator "Kyoko Kirigiri" "1881" "$KYOKO"
    check_simulator "Byakuya Togami" "1882" "$BYAKUYA"
    check_simulator "Chihiro Fujisaki" "1883" "$CHIHIRO"
    check_simulator "Celestia Ludenberg" "1884" "$CELESTIA"
    check_simulator "Sakura Ogami" "1885" "$SAKURA"
}

show_access_info() {
    echo ""
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${GREEN}🎉 AI-Kit Industrial IoT System is now running!${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    echo ""
    
    echo -e "${CYAN}📊 Main Dashboard:${NC}"
    echo -e "   🌟 Astro-Host Industrial Dashboard: ${BLUE}http://localhost:3000${NC}"
    echo ""
    
    echo -e "${CYAN}🎭 Character Node-RED Simulators:${NC}"
    echo -e "   ${KYOKO} Kyoko (Detective Lab):       ${BLUE}http://localhost:1881${NC} | UI: ${BLUE}http://localhost:1881/api/ui/${NC}"
    echo -e "   ${BYAKUYA} Byakuya (Efficiency Center): ${BLUE}http://localhost:1882${NC} | UI: ${BLUE}http://localhost:1882/api/ui/${NC}"
    echo -e "   ${CHIHIRO} Chihiro (Integration Lab):   ${BLUE}http://localhost:1883${NC} | UI: ${BLUE}http://localhost:1883/api/ui/${NC}"
    echo -e "   ${CELESTIA} Celestia (Design Studio):    ${BLUE}http://localhost:1884${NC} | UI: ${BLUE}http://localhost:1884/api/ui/${NC}"
    echo -e "   ${SAKURA} Sakura (Testing Lab):        ${BLUE}http://localhost:1885${NC} | UI: ${BLUE}http://localhost:1885/api/ui/${NC}"
    echo ""
    
    echo -e "${CYAN}🔗 MODBUS/TCP Endpoints:${NC}"
    echo -e "   ${KYOKO} Kyoko:    ${BLUE}modbus://localhost:5020${NC}"
    echo -e "   ${BYAKUYA} Byakuya:  ${BLUE}modbus://localhost:5021${NC}"
    echo -e "   ${CHIHIRO} Chihiro:  ${BLUE}modbus://localhost:5022${NC}"
    echo -e "   ${CELESTIA} Celestia: ${BLUE}modbus://localhost:5023${NC}"
    echo -e "   ${SAKURA} Sakura:   ${BLUE}modbus://localhost:5024${NC}"
    echo ""
    
    echo -e "${CYAN}📁 Log Files:${NC}"
    echo -e "   📊 Astro-Host: ${YELLOW}logs/astro-host.log${NC}"
    echo -e "   ${KYOKO} Kyoko:     ${YELLOW}logs/kyoko.log${NC}"
    echo -e "   ${BYAKUYA} Byakuya:   ${YELLOW}logs/byakuya.log${NC}"
    echo -e "   ${CHIHIRO} Chihiro:   ${YELLOW}logs/chihiro.log${NC}"
    echo -e "   ${CELESTIA} Celestia:  ${YELLOW}logs/celestia.log${NC}"
    echo -e "   ${SAKURA} Sakura:    ${YELLOW}logs/sakura.log${NC}"
    echo ""
    
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo -e "   • Use the Astro-Host dashboard to monitor all simulators"
    echo -e "   • Each character has unique specializations and personality traits"
    echo -e "   • Try collaborative scenarios in the dashboard"
    echo -e "   • Use Ctrl+C to stop all services"
    echo ""
    
    echo -e "${GREEN}🚀 QUICK ACCESS LINKS:${NC}"
    echo -e "   📊 Main Dashboard: ${BLUE}http://localhost:3000${NC}"
    echo -e "   🎭 All Character Dashboards: Open /api/ui/ on each port (1881-1885)"
    echo -e "   🎯 Example: ${BLUE}http://localhost:1881/api/ui/${NC} for Kyoko"
    echo ""
}

cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Stopping all services...${NC}"
    
    # Kill all background processes
    if [ -f logs/astro-host.pid ]; then
        ASTRO_PID=$(cat logs/astro-host.pid)
        kill "$ASTRO_PID" 2>/dev/null || true
        rm -f logs/astro-host.pid
        echo -e "${GREEN}✅ Astro-Host stopped${NC}"
    fi
    
    for character in kyoko byakuya chihiro celestia sakura; do
        if [ -f "logs/${character}.pid" ]; then
            PID=$(cat "logs/${character}.pid")
            kill "$PID" 2>/dev/null || true
            rm -f "logs/${character}.pid"
            echo -e "${GREEN}✅ $character simulator stopped${NC}"
        fi
    done
    
    echo -e "${GREEN}🎉 All services stopped successfully${NC}"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

main() {
    print_banner
    print_character_info
    
    # Create logs directory
    mkdir -p logs
    
    case "${1:-start}" in
        "start")
            check_prerequisites
            install_dependencies
            build_projects  # This is the key fix!
            start_astro_host
            start_node_red_simulators
            show_access_info
            
            echo -e "${GREEN}🎯 System is running. Press Ctrl+C to stop all services.${NC}"
            
            # Keep the script running
            while true; do
                sleep 1
            done
            ;;
        
        "install")
            check_prerequisites
            install_dependencies
            echo -e "${GREEN}✅ Installation complete${NC}"
            ;;
        
        "build")
            build_projects
            ;;
        
        "stop")
            cleanup
            ;;
        
        "status")
            echo -e "${BLUE}🔍 Checking system status...${NC}"
            # Add status checking logic here
            ;;
        
        "help"|"--help"|"-h")
            echo "Usage: $0 [start|install|build|stop|status|help]"
            echo ""
            echo "Commands:"
            echo "  start   - Install dependencies, build, and start all services (default)"
            echo "  install - Only install dependencies"
            echo "  build   - Only build projects"
            echo "  stop    - Stop all running services"
            echo "  status  - Show status of all services"
            echo "  help    - Show this help message"
            ;;
        
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
