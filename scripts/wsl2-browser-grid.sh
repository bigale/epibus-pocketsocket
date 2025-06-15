#!/bin/bash

# AI-Kit Industrial IoT - WSL2 Browser-Only Window Manager
# Works without wmctrl/xdotool - uses browser positioning only

set -e

# Configuration
DISPLAY="${DISPLAY:-localhost:10.0}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
    ["kyoko"]="purple,1881,5020,Investigation & Analysis"
    ["byakuya"]="yellow,1882,5021,Quality Control"
    ["chihiro"]="green,1883,5022,System Integration"
    ["celestia"]="red,1884,5023,UI/UX Design"
    ["sakura"]="orange,1885,5024,Reliability Testing"
)

# Screen configuration (from your system: 2731x1440)
SCREEN_WIDTH=2731
SCREEN_HEIGHT=1440

get_grid_position() {
    local index="$1"
    local total_windows="$2"
    
    # Calculate optimal grid for your ultrawide screen
    local cols=3
    local rows=2
    
    if [ "$total_windows" -gt 6 ]; then
        cols=4
        rows=2
    fi
    
    local col=$((index % cols))
    local row=$((index / cols))
    
    # Calculate window dimensions with padding
    local padding=20
    local win_width=$(((SCREEN_WIDTH - (padding * (cols + 1))) / cols))
    local win_height=$(((SCREEN_HEIGHT - (padding * (rows + 1))) / rows))
    
    # Calculate position
    local x=$((padding + (col * (win_width + padding))))
    local y=$((padding + (row * (win_height + padding))))
    
    echo "$x,$y,$win_width,$win_height"
}

launch_character_browser() {
    local character="$1"
    local window_index="$2"
    local window_type="$3"  # "editor" or "dashboard"
    
    # Parse character data
    IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
    
    # Color mapping
    case $color in
        "purple") color_code="$PURPLE" ;;
        "yellow") color_code="$YELLOW" ;;
        "green") color_code="$GREEN" ;;
        "red") color_code="$RED" ;;
        "orange") color_code="$YELLOW" ;;
        *) color_code="$NC" ;;
    esac
    
    local char_name=$(echo $character | sed 's/^./\U&/')
    
    # Get position for this window
    local position_info=$(get_grid_position "$window_index" 10)
    IFS=',' read -r x y width height <<< "$position_info"
    
    # Determine URL and title
    local url title
    if [ "$window_type" = "editor" ]; then
        url="http://localhost:$port"
        title="$char_name Node-RED Editor"
    else
        url="http://localhost:$port/api/ui"
        title="$char_name Dashboard"
    fi
    
    echo -e "${color_code}🌐 [$((window_index + 1))] $title${NC}"
    echo -e "   📍 Position: ($x,$y) Size: ${width}x${height}"
    echo -e "   🔗 URL: $url"
    
    # Launch Chrome with specific positioning
    google-chrome \
        --new-window \
        --window-position="$x,$y" \
        --window-size="$width,$height" \
        --app="$url" \
        --title="$title" &
    
    sleep 1.5  # Prevent browser overwhelm
}

create_character_workspace() {
    local character="$1"
    
    if [ -z "${CHARACTERS[$character]:-}" ]; then
        echo -e "${RED}❌ Unknown character: $character${NC}"
        echo -e "${YELLOW}Available characters: ${!CHARACTERS[*]}${NC}"
        return 1
    fi
    
    # Parse character data
    IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
    local char_name=$(echo $character | sed 's/^./\U&/')
    
    case $color in
        "purple") color_code="$PURPLE" ;;
        "yellow") color_code="$YELLOW" ;;
        "green") color_code="$GREEN" ;;
        "red") color_code="$RED" ;;
        "orange") color_code="$YELLOW" ;;
        *) color_code="$NC" ;;
    esac
    
    echo -e "\n${color_code}🎭 Creating workspace for $char_name - $specialization${NC}"
    
    # Check if services are running
    if ! curl -s "http://localhost:$port" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Service not responding on port $port${NC}"
        echo -e "${BLUE}💡 Make sure Node-RED simulators are running${NC}"
    fi
    
    # Launch editor window (index 0)
    launch_character_browser "$character" 0 "editor"
    
    # Launch dashboard window (index 1)  
    launch_character_browser "$character" 1 "dashboard"
    
    # Launch main dashboard for Kyoko
    if [ "$character" = "kyoko" ]; then
        echo -e "${CYAN}🏭 Opening Main AI-Kit Dashboard${NC}"
        local main_pos=$(get_grid_position 2 10)
        IFS=',' read -r x y width height <<< "$main_pos"
        
        google-chrome \
            --new-window \
            --window-position="$x,$y" \
            --window-size="$width,$height" \
            --app="http://localhost:4321" \
            --title="AI-Kit Industrial IoT" &
        sleep 1.5
    fi
    
    echo -e "${GREEN}✅ $char_name workspace ready!${NC}"
}

create_all_workspaces_grid() {
    echo -e "${CYAN}🏭 AI-Kit Industrial IoT - Browser Grid Layout${NC}"
    echo -e "${CYAN}Optimized for $SCREEN_WIDTH x $SCREEN_HEIGHT display${NC}"
    
    # Check if Chrome is available
    if ! command -v google-chrome >/dev/null 2>&1; then
        echo -e "${RED}❌ Google Chrome not found${NC}"
        echo -e "${YELLOW}💡 This script requires Google Chrome for positioning${NC}"
        return 1
    fi
    
    echo -e "\n${BLUE}🔍 Checking services...${NC}"
    local services_ok=true
    for character in kyoko byakuya chihiro celestia sakura; do
        IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
        if curl -s "http://localhost:$port" >/dev/null 2>&1; then
            echo -e "   ✅ $character (port $port)"
        else
            echo -e "   ❌ $character (port $port) - Not responding"
            services_ok=false
        fi
    done
    
    if [ "$services_ok" = false ]; then
        echo -e "\n${YELLOW}⚠️  Some services are not running. Continue anyway? (y/N)${NC}"
        read -r continue_choice
        if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}💡 Start services with: ./launch-complete-system.sh${NC}"
            return 1
        fi
    fi
    
    echo -e "\n${BLUE}🎨 Creating character grid layout...${NC}"
    
    # Grid layout: Editor and Dashboard for each character
    local window_index=0
    
    for character in kyoko byakuya chihiro celestia sakura; do
        IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
        local char_name=$(echo $character | sed 's/^./\U&/')
        
        case $color in
            "purple") color_code="$PURPLE" ;;
            "yellow") color_code="$YELLOW" ;;
            "green") color_code="$GREEN" ;;
            "red") color_code="$RED" ;;
            "orange") color_code="$YELLOW" ;;
            *) color_code="$NC" ;;
        esac
        
        echo -e "\n${color_code}🎭 Setting up $char_name windows...${NC}"
        
        # Editor window
        launch_character_browser "$character" "$window_index" "editor"
        window_index=$((window_index + 1))
        
        # Dashboard window
        launch_character_browser "$character" "$window_index" "dashboard"
        window_index=$((window_index + 1))
        
        sleep 0.5  # Brief pause between characters
    done
    
    # Main AI-Kit dashboard (special position)
    echo -e "\n${CYAN}🏭 Adding Main AI-Kit Dashboard...${NC}"
    local main_pos=$(get_grid_position "$window_index" 12)
    IFS=',' read -r x y width height <<< "$main_pos"
    
    google-chrome \
        --new-window \
        --window-position="$x,$y" \
        --window-size="$width,$height" \
        --app="http://localhost:4321" \
        --title="AI-Kit Industrial IoT Main" &
    
    echo -e "\n${GREEN}✅ All character workspaces created in grid layout!${NC}"
    echo -e "${CYAN}📊 Layout: 5 characters × 2 windows + main dashboard = 11 windows${NC}"
    show_browser_tips
}

show_browser_tips() {
    echo -e "\n${YELLOW}🎮 Browser Window Management Tips:${NC}"
    echo -e "• ${CYAN}Ctrl + Shift + A${NC}: Chrome app launcher"
    echo -e "• ${CYAN}Ctrl + W${NC}: Close current tab"
    echo -e "• ${CYAN}Ctrl + Shift + W${NC}: Close current window"
    echo -e "• ${CYAN}Alt + Tab${NC}: Switch between all windows"
    echo -e "• ${CYAN}Ctrl + \`${NC}: Switch between Chrome windows"
    
    echo -e "\n${YELLOW}🔧 Character Window Organization:${NC}"
    echo -e "• Each character has 2 windows: Editor + Dashboard"
    echo -e "• Windows positioned in grid for optimal viewing"
    echo -e "• Main dashboard provides system overview"
    echo -e "• All windows sized for your $SCREEN_WIDTH×$SCREEN_HEIGHT display"
}

show_menu() {
    while true; do
        clear
        echo -e "${CYAN}🎭 AI-Kit Browser Grid Manager${NC}"
        echo -e "${CYAN}=============================${NC}"
        echo -e "Display: $SCREEN_WIDTH × $SCREEN_HEIGHT"
        echo -e ""
        echo -e "1. Create all character workspaces (grid layout)"
        echo -e "2. Create single character workspace"
        echo -e "3. Kill all browser windows"
        echo -e "4. Check browser processes"
        echo -e "5. Test service connectivity"
        echo -e "6. Show browser tips"
        echo -e "7. Open main AI-Kit dashboard only"
        echo -e "0. Exit"
        echo
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                create_all_workspaces_grid
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -e "\n${BLUE}Available characters:${NC}"
                local i=1
                for character in kyoko byakuya chihiro celestia sakura; do
                    IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
                    echo -e "$i. $(echo $character | sed 's/^./\U&/') - $specialization"
                    i=$((i + 1))
                done
                echo
                read -p "Select character (1-5): " char_choice
                
                case $char_choice in
                    1) create_character_workspace "kyoko" ;;
                    2) create_character_workspace "byakuya" ;;
                    3) create_character_workspace "chihiro" ;;
                    4) create_character_workspace "celestia" ;;
                    5) create_character_workspace "sakura" ;;
                    *) echo "Invalid choice" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            3)
                kill_all_browsers
                read -p "Press Enter to continue..."
                ;;
            4)
                check_browser_processes
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "\n${BLUE}🔍 Testing service connectivity...${NC}"
                for character in kyoko byakuya chihiro celestia sakura; do
                    IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
                    echo -n "$(echo $character | sed 's/^./\U&/') (port $port): "
                    if curl -s --connect-timeout 2 "http://localhost:$port" >/dev/null 2>&1; then
                        echo -e "${GREEN}✅ Online${NC}"
                    else
                        echo -e "${RED}❌ Offline${NC}"
                    fi
                done
                echo -n "Main Dashboard (port 4321): "
                if curl -s --connect-timeout 2 "http://localhost:4321" >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ Online${NC}"
                else
                    echo -e "${RED}❌ Offline${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                show_browser_tips
                read -p "Press Enter to continue..."
                ;;
            7)
                echo -e "${CYAN}🏭 Opening Main AI-Kit Dashboard...${NC}"
                google-chrome --new-window --app="http://localhost:4321" &
                echo -e "${GREEN}✅ Main dashboard opened${NC}"
                sleep 1
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

kill_all_browsers() {
    echo -e "${RED}🗑️  Killing all browser windows...${NC}"
    
    # Kill Chrome processes with AI-Kit related titles
    echo -e "${YELLOW}Closing Chrome windows...${NC}"
    
    # Method 1: Try to close gracefully using wmctrl if available
    if command -v wmctrl >/dev/null 2>&1; then
        local ai_kit_windows=$(wmctrl -l | grep -E "(Node-RED|Dashboard|AI-Kit|Kyoko|Byakuya|Chihiro|Celestia|Sakura)")
        if [ -n "$ai_kit_windows" ]; then
            echo -e "${CYAN}Found AI-Kit windows:${NC}"
            echo "$ai_kit_windows" | while read -r line; do
                local window_id=$(echo "$line" | awk '{print $1}')
                local window_title=$(echo "$line" | cut -d' ' -f5-)
                echo -e "  🗙 Closing: $window_title"
                wmctrl -i -c "$window_id" 2>/dev/null || true
            done
        else
            echo -e "${YELLOW}⚠️  No AI-Kit windows found via wmctrl${NC}"
        fi
    fi
    
    # Method 2: Kill Chrome processes (more aggressive)
    echo -e "${YELLOW}Terminating Chrome processes...${NC}"
    
    # Find Chrome processes related to localhost URLs
    local chrome_pids=$(pgrep -f "chrome.*localhost" 2>/dev/null || true)
    if [ -n "$chrome_pids" ]; then
        echo -e "${CYAN}Found Chrome processes with localhost URLs:${NC}"
        for pid in $chrome_pids; do
            local cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "Unknown")
            echo -e "  🗙 PID $pid: $(echo "$cmd" | cut -c1-60)..."
            kill "$pid" 2>/dev/null || true
        done
        
        # Wait for graceful shutdown
        sleep 2
        
        # Force kill if still running
        local remaining=$(pgrep -f "chrome.*localhost" 2>/dev/null || true)
        if [ -n "$remaining" ]; then
            echo -e "${RED}Force killing remaining processes...${NC}"
            for pid in $remaining; do
                kill -9 "$pid" 2>/dev/null || true
            done
        fi
    else
        echo -e "${YELLOW}⚠️  No Chrome processes with localhost URLs found${NC}"
    fi
    
    # Method 3: Kill all Chrome processes (nuclear option)
    read -p "Also kill ALL Chrome processes? (y/N): " kill_all_choice
    if [[ $kill_all_choice =~ ^[Yy]$ ]]; then
        echo -e "${RED}💥 Killing ALL Chrome processes...${NC}"
        pkill -f chrome 2>/dev/null || true
        sleep 1
    fi
    
    echo -e "${GREEN}✅ Browser cleanup complete${NC}"
    
    # Show remaining processes
    local remaining_chrome=$(pgrep -f chrome 2>/dev/null | wc -l)
    echo -e "${CYAN}📊 Remaining Chrome processes: $remaining_chrome${NC}"
}

check_browser_processes() {
    echo -e "\n${BLUE}🔍 Current browser processes:${NC}"
    
    # Show Chrome processes
    local chrome_count=$(pgrep chrome 2>/dev/null | wc -l)
    echo -e "Chrome processes: $chrome_count"
    
    if [ "$chrome_count" -gt 0 ]; then
        echo -e "\n${CYAN}Chrome processes with localhost:${NC}"
        ps aux | grep -E "chrome.*localhost" | grep -v grep | while read -r line; do
            local pid=$(echo "$line" | awk '{print $2}')
            local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
            echo -e "  PID $pid: $(echo "$cmd" | cut -c1-80)..."
        done
        
        echo -e "\n${CYAN}All Chrome processes:${NC}"
        ps aux | grep chrome | grep -v grep | head -5 | while read -r line; do
            local pid=$(echo "$line" | awk '{print $2}')
            local mem=$(echo "$line" | awk '{print $4}')
            echo -e "  PID $pid (${mem}% mem)"
        done
    fi
    
    # Show window manager info if available
    if command -v wmctrl >/dev/null 2>&1; then
        echo -e "\n${CYAN}X11 windows with AI-Kit content:${NC}"
        wmctrl -l | grep -E "(Node-RED|Dashboard|AI-Kit|localhost)" | head -10 || echo "  None found"
    fi
}

# Main execution
case "${1:-}" in
    "--create-all"|"-a")
        create_all_workspaces_grid
        ;;
    "--menu"|"-m")
        show_menu
        ;;
    "--character"|"-c")
        if [ -n "${2:-}" ] && [ -n "${CHARACTERS[$2]:-}" ]; then
            create_character_workspace "$2"
        else
            echo "Usage: $0 --character CHARACTER_NAME"
            echo "Available characters: ${!CHARACTERS[*]}"
            exit 1
        fi
        ;;
    "--help"|"-h")
        echo "AI-Kit Browser Grid Manager"
        echo "Usage: $0 [OPTION]"
        echo
        echo "Options:"
        echo "  -a, --create-all      Create all character workspaces in grid"
        echo "  -m, --menu            Show interactive menu"
        echo "  -c, --character NAME  Create workspace for specific character"
        echo "  -h, --help            Show this help"
        echo
        echo "Available characters: ${!CHARACTERS[*]}"
        echo "Optimized for: $SCREEN_WIDTH × $SCREEN_HEIGHT display"
        ;;
    *)
        echo -e "${CYAN}🎭 AI-Kit Browser Grid Manager${NC}"
        echo "Usage: $0 [OPTION]"
        echo
        echo "Quick start:"
        echo "  $0 --menu              # Interactive menu"
        echo "  $0 --create-all        # Create all character workspaces"
        echo "  $0 --character kyoko   # Create Kyoko's workspace only"
        echo
        echo "Optimized for your $SCREEN_WIDTH × $SCREEN_HEIGHT display"
        echo "Run '$0 --help' for more options"
        ;;
esac
