#!/bin/bash

# 🎭 Character-Driven Node-RED PLC Simulator Management Script
# This script manages multiple Node-RED instances for AI-Kit character-driven simulation

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"
DATA_DIR="$PROJECT_DIR/data"

# Ensure directories exist
mkdir -p "$LOG_DIR"
mkdir -p "$DATA_DIR"

# Character configurations
declare -A CHARACTERS=(
    ["kyoko"]="1881:5020:detective-purple"
    ["byakuya"]="1882:5021:efficiency-blue"
    ["chihiro"]="1883:5022:tech-green"
    ["celestia"]="1884:5023:elegant-red"
    ["sakura"]="1885:5024:strength-orange"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Character-specific logging
character_log() {
    local character=$1
    local message=$2
    local color=""
    
    case $character in
        "kyoko") color=$PURPLE ;;
        "byakuya") color=$BLUE ;;
        "chihiro") color=$GREEN ;;
        "celestia") color=$RED ;;
        "sakura") color=$YELLOW ;;
        *) color=$CYAN ;;
    esac
    
    echo -e "${color}[🎭 $character]${NC} $message"
}

# Check if a character simulator is running
is_character_running() {
    local character=$1
    local config="${CHARACTERS[$character]}"
    local port=$(echo $config | cut -d':' -f1)
    
    if lsof -i :$port > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Start a character simulator
start_character() {
    local character=$1
    
    if [[ -z "${CHARACTERS[$character]}" ]]; then
        error "Unknown character: $character"
        return 1
    fi
    
    if is_character_running $character; then
        warn "$character simulator is already running"
        return 0
    fi
    
    character_log $character "Starting simulator..."
    
    local config="${CHARACTERS[$character]}"
    local port=$(echo $config | cut -d':' -f1)
    local modbus_port=$(echo $config | cut -d':' -f2)
    local theme=$(echo $config | cut -d':' -f3)
    
    # Create character-specific data directory
    mkdir -p "$DATA_DIR/$character"
    
    # Start Node-RED instance for character
    cd "$PROJECT_DIR"
    
    CHARACTER=$character \
    PORT=$port \
    MODBUS_PORT=$modbus_port \
    THEME=$theme \
    nohup npm run start:simulator > "$LOG_DIR/${character}-simulator.log" 2>&1 &
    
    local pid=$!
    echo $pid > "$DATA_DIR/$character/simulator.pid"
    
    # Wait a moment for startup
    sleep 3
    
    if is_character_running $character; then
        character_log $character "✅ Simulator started successfully on port $port"
        character_log $character "🌐 Dashboard: http://localhost:$port"
        character_log $character "🔌 MODBUS: localhost:$modbus_port"
        character_log $character "📊 WebSocket: ws://localhost:$((port + 100))"
    else
        error "Failed to start $character simulator"
        return 1
    fi
}

# Stop a character simulator
stop_character() {
    local character=$1
    
    if [[ -z "${CHARACTERS[$character]}" ]]; then
        error "Unknown character: $character"
        return 1
    fi
    
    if ! is_character_running $character; then
        warn "$character simulator is not running"
        return 0
    fi
    
    character_log $character "Stopping simulator..."
    
    local config="${CHARACTERS[$character]}"
    local port=$(echo $config | cut -d':' -f1)
    local pid_file="$DATA_DIR/$character/simulator.pid"
    
    # Try to stop gracefully first
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill -TERM "$pid" 2>/dev/null; then
            character_log $character "Sent graceful shutdown signal"
            sleep 5
        fi
        rm -f "$pid_file"
    fi
    
    # Force kill if still running
    if is_character_running $character; then
        local pids=$(lsof -t -i :$port 2>/dev/null || true)
        if [[ -n "$pids" ]]; then
            kill -KILL $pids 2>/dev/null || true
            sleep 2
        fi
    fi
    
    if ! is_character_running $character; then
        character_log $character "✅ Simulator stopped successfully"
    else
        error "Failed to stop $character simulator"
        return 1
    fi
}

# Show status of all simulators
show_status() {
    log "🎭 AI-Kit Node-RED Character Simulator Status"
    echo
    
    printf "%-12s %-8s %-6s %-12s %-15s %-10s\n" "Character" "Status" "Port" "MODBUS" "Dashboard" "Theme"
    printf "%-12s %-8s %-6s %-12s %-15s %-10s\n" "---------" "------" "----" "------" "---------" "-----"
    
    for character in "${!CHARACTERS[@]}"; do
        local config="${CHARACTERS[$character]}"
        local port=$(echo $config | cut -d':' -f1)
        local modbus_port=$(echo $config | cut -d':' -f2)
        local theme=$(echo $config | cut -d':' -f3)
        
        if is_character_running $character; then
            local status="${GREEN}Running${NC}"
            local dashboard="http://localhost:$port"
        else
            local status="${RED}Stopped${NC}"
            local dashboard="Not Available"
        fi
        
        printf "%-12s %-8s %-6s %-12s %-15s %-10s\n" "$character" "$status" "$port" "$modbus_port" "$dashboard" "$theme"
    done
    
    echo
    
    # Show system resources
    log "System Resources:"
    echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
    echo "Memory Usage: $(free | grep Mem | awk '{printf("%.2f%%", $3/$2 * 100.0)}')"
    echo "Node-RED Processes: $(pgrep -f "node-red" | wc -l)"
}

# Install Node-RED and dependencies for character simulators
install_dependencies() {
    log "Installing Node-RED and character-specific dependencies..."
    
    # Install global Node-RED if not present
    if ! command -v node-red &> /dev/null; then
        info "Installing Node-RED globally..."
        npm install -g node-red
    fi
    
    # Install character-specific nodes
    log "Installing character-specific Node-RED nodes..."
    
    local nodes=(
        "node-red-contrib-modbus"
        "node-red-dashboard"
        "node-red-contrib-ui-level"
        "node-red-contrib-buffer-parser"
        "node-red-contrib-cron-plus"
    )
    
    for node in "${nodes[@]}"; do
        info "Installing $node..."
        npm install -g "$node" || warn "Failed to install $node"
    done
    
    log "✅ Dependencies installation completed"
}

# Health check for all simulators
health_check() {
    log "🏥 Running health check on all character simulators..."
    echo
    
    local healthy=0
    local total=0
    
    for character in "${!CHARACTERS[@]}"; do
        total=$((total + 1))
        local config="${CHARACTERS[$character]}"
        local port=$(echo $config | cut -d':' -f1)
        
        if is_character_running $character; then
            # Test HTTP endpoint
            if curl -s "http://localhost:$port" > /dev/null; then
                character_log $character "✅ Healthy - HTTP responding"
                healthy=$((healthy + 1))
            else
                character_log $character "⚠️  Warning - Port open but HTTP not responding"
            fi
        else
            character_log $character "❌ Down - Not running"
        fi
    done
    
    echo
    log "Health Check Summary: $healthy/$total simulators healthy"
    
    if [[ $healthy -eq $total ]]; then
        log "🎉 All character simulators are running perfectly!"
        return 0
    else
        warn "Some simulators need attention"
        return 1
    fi
}

# Create collaborative scenario across multiple characters
create_collaborative_scenario() {
    local scenario_name=$1
    
    if [[ -z "$scenario_name" ]]; then
        error "Please provide a scenario name"
        return 1
    fi
    
    log "🎭 Creating collaborative scenario: $scenario_name"
    
    local running_characters=()
    for character in "${!CHARACTERS[@]}"; do
        if is_character_running $character; then
            running_characters+=($character)
        fi
    done
    
    if [[ ${#running_characters[@]} -lt 2 ]]; then
        error "Need at least 2 running character simulators for collaboration"
        return 1
    fi
    
    log "Involving characters: ${running_characters[*]}"
    
    # Send scenario activation to each character
    for character in "${running_characters[@]}"; do
        local config="${CHARACTERS[$character]}"
        local port=$(echo $config | cut -d':' -f1)
        
        character_log $character "Activating collaborative scenario..."
        
        # Send POST request to character's API
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "{\"scenario\": \"$scenario_name\", \"collaborative\": true, \"participants\": [\"${running_characters[*]}\"]}" \
            "http://localhost:$port/api/scenario/collaborative" > /dev/null
        
        if [[ $? -eq 0 ]]; then
            character_log $character "✅ Scenario activated"
        else
            character_log $character "⚠️  Failed to activate scenario"
        fi
    done
    
    log "🎉 Collaborative scenario '$scenario_name' created successfully!"
}

# Monitor logs in real-time
monitor_logs() {
    local character=$1
    
    if [[ -n "$character" ]]; then
        if [[ -z "${CHARACTERS[$character]}" ]]; then
            error "Unknown character: $character"
            return 1
        fi
        
        local log_file="$LOG_DIR/${character}-simulator.log"
        if [[ -f "$log_file" ]]; then
            character_log $character "Monitoring logs..."
            tail -f "$log_file"
        else
            error "Log file not found: $log_file"
            return 1
        fi
    else
        log "Monitoring all character simulator logs..."
        tail -f "$LOG_DIR"/*-simulator.log
    fi
}

# Main script logic
case "${1:-}" in
    "start")
        if [[ -n "${2:-}" ]]; then
            start_character "$2"
        else
            log "Starting all character simulators..."
            for character in "${!CHARACTERS[@]}"; do
                start_character "$character"
                sleep 2  # Stagger startups
            done
        fi
        ;;
    "stop")
        if [[ -n "${2:-}" ]]; then
            stop_character "$2"
        else
            log "Stopping all character simulators..."
            for character in "${!CHARACTERS[@]}"; do
                stop_character "$character"
            done
        fi
        ;;
    "restart")
        if [[ -n "${2:-}" ]]; then
            stop_character "$2"
            sleep 2
            start_character "$2"
        else
            log "Restarting all character simulators..."
            for character in "${!CHARACTERS[@]}"; do
                stop_character "$character"
            done
            sleep 3
            for character in "${!CHARACTERS[@]}"; do
                start_character "$character"
                sleep 2
            done
        fi
        ;;
    "status")
        show_status
        ;;
    "health")
        health_check
        ;;
    "install")
        install_dependencies
        ;;
    "logs")
        monitor_logs "${2:-}"
        ;;
    "collaborate")
        create_collaborative_scenario "${2:-multi_character_scenario}"
        ;;
    *)
        echo "🎭 AI-Kit Node-RED Character Simulator Manager"
        echo
        echo "Usage: $0 <command> [character]"
        echo
        echo "Commands:"
        echo "  start [character]    - Start simulator(s)"
        echo "  stop [character]     - Stop simulator(s)"
        echo "  restart [character]  - Restart simulator(s)"
        echo "  status               - Show status of all simulators"
        echo "  health               - Run health check"
        echo "  install              - Install dependencies"
        echo "  logs [character]     - Monitor logs"
        echo "  collaborate [name]   - Create collaborative scenario"
        echo
        echo "Characters: ${!CHARACTERS[*]}"
        echo
        echo "Examples:"
        echo "  $0 start kyoko       # Start Kyoko's simulator"
        echo "  $0 start             # Start all simulators"
        echo "  $0 status            # Show status"
        echo "  $0 logs byakuya      # Monitor Byakuya's logs"
        echo "  $0 collaborate mystery # Create mystery scenario"
        ;;
esac
