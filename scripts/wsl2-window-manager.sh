#!/bin/bash

# AI-Kit Industrial IoT - WSL2 X11 Window Manager
# Optimized for WSL2 + X11 forwarding to Windows host

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

check_x11_connection() {
    echo -e "${BLUE}🔍 Checking X11 connection...${NC}"
    
    if [ -z "$DISPLAY" ]; then
        echo -e "${RED}❌ DISPLAY variable not set${NC}"
        echo -e "${YELLOW}💡 Set DISPLAY with: export DISPLAY=:0${NC}"
        return 1
    fi
    
    if ! command -v xdpyinfo >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Installing X11 utilities...${NC}"
        sudo apt-get update -qq && sudo apt-get install -y x11-utils
    fi
    
    if xdpyinfo >/dev/null 2>&1; then
        echo -e "${GREEN}✅ X11 connection working on $DISPLAY${NC}"
        return 0
    else
        echo -e "${RED}❌ Cannot connect to X11 display${NC}"
        echo -e "${YELLOW}💡 Make sure X11 forwarding is enabled in your X server${NC}"
        return 1
    fi
}

install_browser() {
    echo -e "${BLUE}🌐 Checking browser availability...${NC}"
    
    if command -v google-chrome >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Google Chrome found${NC}"
        return 0
    fi
    
    if command -v chromium-browser >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Chromium found${NC}"
        return 0
    fi
    
    if command -v firefox >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Firefox found${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}⚠️  No browser found in WSL2 environment${NC}"
    echo -e "${CYAN}💡 WSL2 Browser Installation Options:${NC}"
    echo -e "   1. Install via Windows Package Manager: ${YELLOW}winget install Google.Chrome${NC}"
    echo -e "   2. Use Windows browser with WSL2: Browser will open on Windows host"
    echo -e "   3. Manual install: Download and install browser in Windows"
    echo -e "   4. Alternative: ${YELLOW}wget + dpkg method${NC} (if sudo works)"
    
    # Try non-sudo installation methods
    echo -e "${BLUE}🔧 Attempting alternative browser setup...${NC}"
    
    # Check if we can use Windows browser through WSL integration
    if command -v cmd.exe >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Windows integration available - will use Windows browser${NC}"
        return 0
    fi
    
    echo -e "${RED}❌ No browser available. Please install a browser manually.${NC}"
    return 1
}

get_browser_command() {
    # Priority order for WSL2 environment
    if command -v google-chrome >/dev/null 2>&1; then
        echo "google-chrome"
    elif command -v chromium-browser >/dev/null 2>&1; then
        echo "chromium-browser"
    elif command -v firefox >/dev/null 2>&1; then
        echo "firefox"
    elif command -v cmd.exe >/dev/null 2>&1; then
        # WSL2 fallback - use Windows browser
        echo "cmd.exe /c start"
    else
        # Last resort
        echo "xdg-open"
    fi
}

launch_url_wsl2() {
    local url="$1"
    local window_title="$2"
    local browser_cmd=$(get_browser_command)
    
    echo -e "${CYAN}🌐 Opening: $url${NC}"
    echo -e "${BLUE}   Using: $browser_cmd${NC}"
    
    case "$browser_cmd" in
        "cmd.exe /c start")
            # Use Windows browser via WSL2 integration
            cmd.exe /c start "$url" &
            ;;
        "google-chrome"|"chromium-browser")
            # Linux browser with X11 forwarding
            $browser_cmd --new-window \
                         --window-position=50,50 \
                         --window-size=1200,800 \
                         --title="$window_title" \
                         "$url" &
            ;;
        "firefox")
            # Firefox with X11 forwarding
            firefox --new-window "$url" &
            ;;
        *)
            # Fallback
            xdg-open "$url" &
            ;;
    esac
    
    sleep 2
}

open_character_windows() {
    local character="$1"
    local window_offset="$2"
    
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
    echo -e "\n${color_code}🎭 Opening windows for $char_name - $specialization${NC}"
    
    local browser=$(get_browser_command)
    local base_x=$((window_offset * 50))
    local base_y=$((window_offset * 50))
    
    # URLs for this character
    local node_red_editor="http://localhost:$port"
    local node_red_dashboard="http://localhost:$port/api/ui"
    
    echo -e "${CYAN}🌐 Opening Node-RED Editor: $node_red_editor${NC}"
    launch_url_wsl2 "$node_red_editor" "$char_name Node-RED Editor"
    
    echo -e "${CYAN}📊 Opening Dashboard: $node_red_dashboard${NC}"
    launch_url_wsl2 "$node_red_dashboard" "$char_name Dashboard"
    
    # Open main dashboard for Kyoko
    if [ "$character" = "kyoko" ]; then
        echo -e "${CYAN}🏭 Opening Main AI-Kit Dashboard${NC}"
        launch_url_wsl2 "http://localhost:4321" "AI-Kit Industrial IoT"
    fi
    
    # Open terminal for character
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal --title="$char_name Terminal" \
                      --geometry=80x24+$((base_x + 300))+$((base_y + 300)) \
                      --working-directory="$PROJECT_ROOT" &
    elif command -v xterm >/dev/null 2>&1; then
        xterm -title "$char_name Terminal" \
              -geometry 80x24+$((base_x + 300))+$((base_y + 300)) \
              -e "cd '$PROJECT_ROOT'; echo 'Character: $char_name'; echo 'Port: $port'; echo 'Specialization: $specialization'; bash" &
    fi
    
    echo -e "${GREEN}✅ $char_name windows opened${NC}"
    echo -e "   🌐 Editor: $node_red_editor"
    echo -e "   📊 Dashboard: $node_red_dashboard"
    echo -e "   🔧 MODBUS: $modbus_port"
}

organize_windows_grid() {
    echo -e "${BLUE}🔲 Organizing windows in grid layout...${NC}"
    
    # Check if wmctrl is available
    if ! command -v wmctrl >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  wmctrl not found. Grid organization requires wmctrl.${NC}"
        echo -e "${YELLOW}💡 To install: apt-get install wmctrl (may require different WSL2 setup)${NC}"
        echo -e "${CYAN}🔧 Using alternative window positioning...${NC}"
        
        # Alternative: Use xdotool if available
        if command -v xdotool >/dev/null 2>&1; then
            organize_windows_xdotool
        else
            echo -e "${RED}❌ No window management tools available${NC}"
            echo -e "${YELLOW}💡 Windows should already be positioned from browser launch${NC}"
        fi
        return
    fi
    
    sleep 2  # Wait for windows to settle
    
    # Get current screen dimensions dynamically
    local screen_info
    if command -v xdpyinfo >/dev/null 2>&1; then
        screen_info=$(xdpyinfo | grep dimensions | awk '{print $2}')
        local screen_width=$(echo $screen_info | cut -d'x' -f1)
        local screen_height=$(echo $screen_info | cut -d'x' -f2)
    else
        # Fallback dimensions
        local screen_width=1920
        local screen_height=1080
    fi
    
    echo -e "${CYAN}📏 Screen size: ${screen_width}x${screen_height}${NC}"
    
    # Calculate grid positions (3 columns, 2 rows)
    local cols=3
    local rows=2
    local win_width=$((screen_width / cols))
    local win_height=$((screen_height / rows))
    
    echo -e "${CYAN}📐 Grid: ${cols}x${rows}, Window size: ${win_width}x${win_height}${NC}"
    
    # Find AI-Kit related windows
    local window_list=$(wmctrl -l 2>/dev/null | grep -E "(Node-RED|Dashboard|AI-Kit|Chrome|Chromium)" | head -6)
    
    if [ -z "$window_list" ]; then
        echo -e "${YELLOW}⚠️  No AI-Kit windows found to organize${NC}"
        echo -e "${BLUE}📋 Current windows:${NC}"
        wmctrl -l 2>/dev/null || echo "Cannot list windows"
        return
    fi
    
    local position=0
    echo -e "${CYAN}🎯 Organizing windows:${NC}"
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local window_id=$(echo "$line" | awk '{print $1}')
            local window_title=$(echo "$line" | cut -d' ' -f5-)
            
            local col=$((position % cols))
            local row=$((position / cols))
            local x=$((col * win_width))
            local y=$((row * win_height))
            
            echo -e "${CYAN}📐 [$((position + 1))] $window_title → Position ($x,$y) Size (${win_width}x${win_height})${NC}"
            
            # Move and resize window
            if wmctrl -i -r "$window_id" -e "0,$x,$y,$win_width,$win_height" 2>/dev/null; then
                echo -e "${GREEN}  ✅ Positioned successfully${NC}"
            else
                echo -e "${YELLOW}  ⚠️  Positioning failed (window may not support resizing)${NC}"
            fi
            
            position=$((position + 1))
            sleep 0.5  # Small delay between window operations
        fi
    done <<< "$window_list"
    
    echo -e "${GREEN}✅ Grid organization complete! Positioned $position windows${NC}"
}

organize_windows_xdotool() {
    echo -e "${CYAN}🔧 Using xdotool for window organization...${NC}"
    
    # Find windows by searching for AI-Kit related titles
    local search_terms=("Node-RED" "Dashboard" "AI-Kit" "Kyoko" "Byakuya" "Chihiro" "Celestia" "Sakura")
    local position=0
    
    for term in "${search_terms[@]}"; do
        local window_ids=$(xdotool search --name "$term" 2>/dev/null)
        
        for window_id in $window_ids; do
            if [ -n "$window_id" ] && [ $position -lt 6 ]; then
                local col=$((position % 3))
                local row=$((position / 3))
                local x=$((col * 640))
                local y=$((row * 360))
                
                local window_name=$(xdotool getwindowname "$window_id" 2>/dev/null || echo "Unknown")
                echo -e "${CYAN}📐 [$((position + 1))] $window_name → ($x,$y)${NC}"
                
                xdotool windowmove "$window_id" "$x" "$y" 2>/dev/null
                xdotool windowsize "$window_id" 640 360 2>/dev/null
                
                position=$((position + 1))
                sleep 0.3
            fi
        done
    done
    
    echo -e "${GREEN}✅ Alternative positioning complete!${NC}"
}

create_character_workspace() {
    local character="$1"
    
    if [ -z "${CHARACTERS[$character]:-}" ]; then
        echo -e "${RED}❌ Unknown character: $character${NC}"
        echo -e "${YELLOW}Available characters: ${!CHARACTERS[*]}${NC}"
        return 1
    fi
    
    # Check prerequisites
    check_x11_connection || return 1
    install_browser || return 1
    
    # Open character windows
    open_character_windows "$character" 0
    
    echo -e "\n${GREEN}✅ $character workspace ready!${NC}"
}

create_all_workspaces() {
    echo -e "${CYAN}🏭 AI-Kit Industrial IoT - WSL2 Window Manager${NC}"
    echo -e "${CYAN}Creating character workspaces...${NC}"
    
    # Check prerequisites
    check_x11_connection || return 1
    install_browser || return 1
    
    # Create workspace for each character
    local offset=0
    for character in kyoko byakuya chihiro celestia sakura; do
        open_character_windows "$character" "$offset"
        offset=$((offset + 1))
        sleep 1
    done
    
    # Optional: Organize in grid
    read -p "Organize windows in grid layout? (y/N): " organize
    if [[ $organize =~ ^[Yy]$ ]]; then
        organize_windows_grid
    fi
    
    echo -e "\n${GREEN}✅ All character workspaces created!${NC}"
    show_usage_tips
}

show_usage_tips() {
    echo -e "\n${YELLOW}🎮 WSL2 Window Management Tips:${NC}"
    echo -e "• ${CYAN}Alt + Tab${NC}: Switch between application windows"
    echo -e "• ${CYAN}Win + Left/Right${NC}: Snap windows to sides (Windows host)"
    echo -e "• ${CYAN}Win + Up/Down${NC}: Maximize/minimize windows (Windows host)"
    echo -e "• ${CYAN}wmctrl -l${NC}: List all X11 windows"
    echo -e "• ${CYAN}wmctrl -c \"Window Title\"${NC}: Close specific window"
    
    echo -e "\n${YELLOW}🔧 Character Management:${NC}"
    echo -e "• Each character has dedicated browser windows"
    echo -e "• Terminal windows for command-line access"
    echo -e "• Windows positioned with character-specific offsets"
    
    echo -e "\n${YELLOW}🌐 Quick Access URLs:${NC}"
    for character in kyoko byakuya chihiro celestia sakura; do
        IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
        echo -e "• $(echo $character | sed 's/^./\U&/'): http://localhost:$port (Editor) | http://localhost:$port/api/ui (Dashboard)"
    done
}

kill_character_windows() {
    local character="$1"
    local char_name=$(echo $character | sed 's/^./\U&/')
    
    echo -e "${RED}🗑️  Closing windows for $char_name...${NC}"
    
    if command -v wmctrl >/dev/null 2>&1; then
        wmctrl -c "$char_name Node-RED Editor" 2>/dev/null || true
        wmctrl -c "$char_name Dashboard" 2>/dev/null || true
        wmctrl -c "$char_name Terminal" 2>/dev/null || true
        
        if [ "$character" = "kyoko" ]; then
            wmctrl -c "AI-Kit Industrial IoT" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✅ $char_name windows closed${NC}"
    else
        echo -e "${YELLOW}⚠️  wmctrl not available. Close windows manually.${NC}"
    fi
}

show_menu() {
    while true; do
        clear
        echo -e "${CYAN}🎭 AI-Kit WSL2 Window Manager${NC}"
        echo -e "${CYAN}=============================${NC}"
        echo -e "1. Create all character workspaces"
        echo -e "2. Create single character workspace"
        echo -e "3. Organize windows in grid"
        echo -e "4. Kill character windows"
        echo -e "5. List current windows"
        echo -e "6. Check X11 connection"
        echo -e "7. Show usage tips"
        echo -e "0. Exit"
        echo
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                create_all_workspaces
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
                organize_windows_grid
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "\n${BLUE}Select character to close:${NC}"
                local i=1
                for character in kyoko byakuya chihiro celestia sakura; do
                    echo -e "$i. $(echo $character | sed 's/^./\U&/')"
                    i=$((i + 1))
                done
                echo -e "6. Close all character windows"
                echo
                read -p "Select option (1-6): " kill_choice
                
                case $kill_choice in
                    1) kill_character_windows "kyoko" ;;
                    2) kill_character_windows "byakuya" ;;
                    3) kill_character_windows "chihiro" ;;
                    4) kill_character_windows "celestia" ;;
                    5) kill_character_windows "sakura" ;;
                    6) 
                        for char in kyoko byakuya chihiro celestia sakura; do
                            kill_character_windows "$char"
                        done
                        ;;
                    *) echo "Invalid choice" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "\n${BLUE}Current X11 windows:${NC}"
                if command -v wmctrl >/dev/null 2>&1; then
                    wmctrl -l
                else
                    echo "wmctrl not available"
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                check_x11_connection
                read -p "Press Enter to continue..."
                ;;
            7)
                show_usage_tips
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

# Main execution
case "${1:-}" in
    "--create-all"|"-a")
        create_all_workspaces
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
    "--organize"|"-o")
        organize_windows_grid
        ;;
    "--kill"|"-k")
        if [ -n "${2:-}" ]; then
            kill_character_windows "$2"
        else
            echo "Usage: $0 --kill CHARACTER_NAME"
            exit 1
        fi
        ;;
    "--help"|"-h")
        echo "AI-Kit WSL2 Window Manager"
        echo "Usage: $0 [OPTION]"
        echo
        echo "Options:"
        echo "  -a, --create-all      Create all character workspaces"
        echo "  -m, --menu            Show interactive menu"
        echo "  -c, --character NAME  Create workspace for specific character"
        echo "  -o, --organize        Organize windows in grid layout"
        echo "  -k, --kill NAME       Close windows for specific character"
        echo "  -h, --help            Show this help"
        echo
        echo "Available characters: ${!CHARACTERS[*]}"
        ;;
    *)
        echo -e "${CYAN}🎭 AI-Kit WSL2 Window Manager${NC}"
        echo "Usage: $0 [OPTION]"
        echo
        echo "Quick start:"
        echo "  $0 --menu              # Interactive menu"
        echo "  $0 --create-all        # Create all character workspaces"
        echo "  $0 --character kyoko   # Create Kyoko's workspace only"
        echo
        echo "Run '$0 --help' for more options"
        ;;
esac
