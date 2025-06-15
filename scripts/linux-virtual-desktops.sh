#!/bin/bash

# AI-Kit Industrial IoT - Linux Virtual Desktop Manager for WSL2/X11
# Creates character-specific virtual desktops using Linux window managers

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
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

# Desktop environment detection
detect_desktop_environment() {
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        echo "$XDG_CURRENT_DESKTOP"
    elif [ -n "$DESKTOP_SESSION" ]; then
        echo "$DESKTOP_SESSION"
    elif [ -n "$GNOME_DESKTOP_SESSION_ID" ]; then
        echo "GNOME"
    elif [ -n "$KDE_SESSION_VERSION" ]; then
        echo "KDE"
    else
        echo "UNKNOWN"
    fi
}

# Check and install required tools
install_dependencies() {
    echo -e "${BLUE}🔧 Checking X11 window management dependencies...${NC}"
    
    local missing_tools=()
    
    # Check for essential tools
    command -v wmctrl >/dev/null 2>&1 || missing_tools+=("wmctrl")
    command -v xdotool >/dev/null 2>&1 || missing_tools+=("xdotool")
    command -v xwininfo >/dev/null 2>&1 || missing_tools+=("x11-utils")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Missing required tools: ${missing_tools[*]}${NC}"
        echo -e "${BLUE}Installing dependencies...${NC}"
        
        # Update package list
        sudo apt-get update -qq
        
        # Install missing tools
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "wmctrl")
                    sudo apt-get install -y wmctrl
                    ;;
                "xdotool")
                    sudo apt-get install -y xdotool
                    ;;
                "x11-utils")
                    sudo apt-get install -y x11-utils
                    ;;
            esac
        done
        
        echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
    else
        echo -e "${GREEN}✅ All dependencies are available${NC}"
    fi
}

# Virtual desktop management functions
create_virtual_desktop() {
    local desktop_name="$1"
    local desktop_method="$2"
    
    case "$desktop_method" in
        "gnome")
            # GNOME uses workspaces
            echo -e "${BLUE}🖥️  Creating GNOME workspace for $desktop_name...${NC}"
            # Note: GNOME workspace creation requires dconf/gsettings
            gsettings set org.gnome.desktop.wm.preferences num-workspaces $(($(gsettings get org.gnome.desktop.wm.preferences num-workspaces) + 1)) 2>/dev/null || true
            ;;
        "kde")
            # KDE Plasma virtual desktops
            echo -e "${BLUE}🖥️  Creating KDE virtual desktop for $desktop_name...${NC}"
            qdbus org.kde.KWin /VirtualDesktopManager createDesktop 0 "$desktop_name" 2>/dev/null || true
            ;;
        "i3"|"sway")
            # i3/sway workspaces
            echo -e "${BLUE}🖥️  Creating i3/sway workspace for $desktop_name...${NC}"
            i3-msg "workspace $desktop_name" 2>/dev/null || swaymsg "workspace $desktop_name" 2>/dev/null || true
            ;;
        "generic")
            # Generic X11 approach using wmctrl
            echo -e "${BLUE}🖥️  Creating virtual desktop for $desktop_name (generic X11)...${NC}"
            wmctrl -n 6 2>/dev/null || true  # Create 6 desktops total
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown desktop environment, using generic X11 approach${NC}"
            wmctrl -n 6 2>/dev/null || true
            ;;
    esac
}

switch_to_desktop() {
    local desktop_number="$1"
    local desktop_method="$2"
    
    case "$desktop_method" in
        "gnome")
            # Switch GNOME workspace
            wmctrl -s $((desktop_number - 1)) 2>/dev/null || true
            ;;
        "kde")
            # Switch KDE virtual desktop
            qdbus org.kde.KWin /VirtualDesktopManager setCurrent "$desktop_number" 2>/dev/null || \
            wmctrl -s $((desktop_number - 1)) 2>/dev/null || true
            ;;
        "i3"|"sway")
            # Switch i3/sway workspace
            local workspace_name="$3"
            i3-msg "workspace $workspace_name" 2>/dev/null || swaymsg "workspace $workspace_name" 2>/dev/null || true
            ;;
        *)
            # Generic X11 desktop switching
            wmctrl -s $((desktop_number - 1)) 2>/dev/null || true
            ;;
    esac
    
    sleep 1
}

open_browser_window() {
    local url="$1"
    local window_title="$2"
    
    echo -e "${CYAN}🌐 Opening: $url${NC}"
    
    # Try different browser commands
    if command -v google-chrome >/dev/null 2>&1; then
        google-chrome --new-window --title="$window_title" "$url" &
    elif command -v chromium-browser >/dev/null 2>&1; then
        chromium-browser --new-window --title="$window_title" "$url" &
    elif command -v firefox >/dev/null 2>&1; then
        firefox --new-window "$url" &
    else
        # Fallback to xdg-open
        xdg-open "$url" &
    fi
    
    sleep 2
}

position_window() {
    local window_title="$1"
    local x="$2"
    local y="$3"
    local width="$4"
    local height="$5"
    
    # Wait for window to appear
    sleep 1
    
    # Find and position the window
    local window_id=$(xdotool search --name "$window_title" | head -1)
    if [ -n "$window_id" ]; then
        xdotool windowsize "$window_id" "$width" "$height"
        xdotool windowmove "$window_id" "$x" "$y"
        echo -e "${GREEN}✅ Positioned window: $window_title${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not find window: $window_title${NC}"
    fi
}

setup_character_desktop() {
    local character="$1"
    local desktop_number="$2"
    local desktop_method="$3"
    
    # Parse character data
    IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
    
    # Color mapping for terminal output
    case $color in
        "purple") color_code="$PURPLE" ;;
        "yellow") color_code="$YELLOW" ;;
        "green") color_code="$GREEN" ;;
        "red") color_code="$RED" ;;
        "orange") color_code="$YELLOW" ;;
        *) color_code="$NC" ;;
    esac
    
    echo -e "\n${color_code}🎭 Setting up desktop for $(echo $character | sed 's/^./\U&/') - $specialization${NC}"
    
    # Switch to character's desktop
    local workspace_name="$character-workspace"
    switch_to_desktop "$desktop_number" "$desktop_method" "$workspace_name"
    
    # Define URLs for this character
    local node_red_editor="http://localhost:$port"
    local node_red_dashboard="http://localhost:$port/api/ui"
    local main_dashboard="http://localhost:4321"
    
    # Open Node-RED Editor (main window)
    open_browser_window "$node_red_editor" "$(echo $character | sed 's/^./\U&/') Node-RED Editor"
    
    # Position the editor window (left side)
    position_window "$(echo $character | sed 's/^./\U&/') Node-RED Editor" 0 0 960 1080
    
    # Open Node-RED Dashboard (secondary window)
    open_browser_window "$node_red_dashboard" "$(echo $character | sed 's/^./\U&/') Dashboard"
    
    # Position the dashboard window (right side)
    position_window "$(echo $character | sed 's/^./\U&/') Dashboard" 960 0 960 540
    
    # Open main AI-Kit dashboard for Kyoko only
    if [ "$character" = "kyoko" ]; then
        open_browser_window "$main_dashboard" "AI-Kit Industrial IoT"
        position_window "AI-Kit Industrial IoT" 960 540 960 540
    fi
    
    # Create a terminal window for character-specific commands
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal --title="$(echo $character | sed 's/^./\U&/') Terminal" \
                      --geometry=80x24+100+100 \
                      --working-directory="$PROJECT_ROOT" &
    elif command -v xterm >/dev/null 2>&1; then
        xterm -title "$(echo $character | sed 's/^./\U&/') Terminal" \
              -geometry 80x24+100+100 \
              -e "cd '$PROJECT_ROOT'; bash" &
    fi
    
    echo -e "${GREEN}✅ $(echo $character | sed 's/^./\U&/') desktop setup complete!${NC}"
    echo -e "   🌐 Node-RED Editor: $node_red_editor"
    echo -e "   📊 Dashboard: $node_red_dashboard"
    echo -e "   🔧 MODBUS Port: $modbus_port"
}

create_all_character_desktops() {
    echo -e "${CYAN}🏭 AI-Kit Industrial IoT - Linux Virtual Desktop Setup${NC}"
    echo -e "${CYAN}Creating character-specific virtual desktops...${NC}"
    
    # Detect desktop environment
    local desktop_env=$(detect_desktop_environment)
    local desktop_method="generic"
    
    case "$desktop_env" in
        *"GNOME"*|*"gnome"*) desktop_method="gnome" ;;
        *"KDE"*|*"kde"*|*"plasma"*) desktop_method="kde" ;;
        *"i3"*) desktop_method="i3" ;;
        *"sway"*) desktop_method="sway" ;;
    esac
    
    echo -e "${BLUE}🖥️  Detected desktop environment: $desktop_env (using $desktop_method method)${NC}"
    
    # Install dependencies
    install_dependencies
    
    # Create desktop for each character
    local desktop_number=2  # Start from desktop 2 (desktop 1 is main)
    
    for character in kyoko byakuya chihiro celestia sakura; do
        echo -e "\n${BLUE}🔨 Creating desktop $desktop_number for $character...${NC}"
        
        # Create the virtual desktop
        create_virtual_desktop "$character" "$desktop_method"
        
        # Set up the character's environment
        setup_character_desktop "$character" "$desktop_number" "$desktop_method"
        
        desktop_number=$((desktop_number + 1))
        sleep 2
    done
    
    # Return to main desktop
    echo -e "\n${BLUE}🏠 Returning to main desktop...${NC}"
    switch_to_desktop 1 "$desktop_method"
    
    echo -e "\n${GREEN}✅ All character desktops created successfully!${NC}"
    show_navigation_help "$desktop_method"
}

show_navigation_help() {
    local desktop_method="$1"
    
    echo -e "\n${YELLOW}🎮 Virtual Desktop Navigation:${NC}"
    
    case "$desktop_method" in
        "gnome")
            echo -e "• ${CYAN}Super + Page Up/Down${NC}: Switch workspaces"
            echo -e "• ${CYAN}Ctrl + Alt + Left/Right${NC}: Switch workspaces"
            echo -e "• ${CYAN}Super + A${NC}: Show activities overview"
            ;;
        "kde")
            echo -e "• ${CYAN}Ctrl + F1-F6${NC}: Switch to specific desktop"
            echo -e "• ${CYAN}Ctrl + Alt + Left/Right${NC}: Switch desktops"
            echo -e "• ${CYAN}Meta + Tab${NC}: Desktop grid"
            ;;
        "i3"|"sway")
            echo -e "• ${CYAN}Super + 1-6${NC}: Switch to workspace"
            echo -e "• ${CYAN}Super + Shift + 1-6${NC}: Move window to workspace"
            ;;
        *)
            echo -e "• ${CYAN}Ctrl + Alt + Left/Right${NC}: Switch desktops"
            echo -e "• ${CYAN}Alt + F2${NC}: Run command"
            ;;
    esac
    
    echo -e "\n${YELLOW}📋 Character Desktop Layout:${NC}"
    echo -e "Desktop 1: ${CYAN}Main/Overview${NC}"
    
    local desktop_number=2
    for character in kyoko byakuya chihiro celestia sakura; do
        IFS=',' read -r color port modbus_port specialization <<< "${CHARACTERS[$character]}"
        echo -e "Desktop $desktop_number: ${CYAN}$(echo $character | sed 's/^./\U&/') - $specialization${NC}"
        desktop_number=$((desktop_number + 1))
    done
    
    echo -e "\n${YELLOW}🛠️  Additional Commands:${NC}"
    echo -e "• ${CYAN}wmctrl -l${NC}: List all windows"
    echo -e "• ${CYAN}wmctrl -d${NC}: List all desktops"
    echo -e "• ${CYAN}xdotool search --name \"pattern\"${NC}: Find windows by name"
}

show_menu() {
    while true; do
        clear
        echo -e "${CYAN}🎭 AI-Kit Linux Virtual Desktop Manager${NC}"
        echo -e "${CYAN}=====================================\${NC}"
        echo -e "1. Create all character desktops"
        echo -e "2. Create single character desktop"
        echo -e "3. Switch to next desktop"
        echo -e "4. Switch to previous desktop"
        echo -e "5. List all windows"
        echo -e "6. Show navigation help"
        echo -e "7. Open main AI-Kit dashboard"
        echo -e "0. Exit"
        echo
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                create_all_character_desktops
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
                    1) setup_character_desktop "kyoko" 2 "generic" ;;
                    2) setup_character_desktop "byakuya" 3 "generic" ;;
                    3) setup_character_desktop "chihiro" 4 "generic" ;;
                    4) setup_character_desktop "celestia" 5 "generic" ;;
                    5) setup_character_desktop "sakura" 6 "generic" ;;
                    *) echo "Invalid choice" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            3)
                wmctrl -s +1 2>/dev/null || echo "Cannot switch desktop"
                echo "Switched to next desktop"
                sleep 1
                ;;
            4)
                wmctrl -s -1 2>/dev/null || echo "Cannot switch desktop"
                echo "Switched to previous desktop"
                sleep 1
                ;;
            5)
                echo -e "\n${BLUE}Current windows:${NC}"
                wmctrl -l 2>/dev/null || echo "Cannot list windows"
                read -p "Press Enter to continue..."
                ;;
            6)
                show_navigation_help "generic"
                read -p "Press Enter to continue..."
                ;;
            7)
                echo "Opening main AI-Kit dashboard..."
                open_browser_window "http://localhost:4321" "AI-Kit Industrial IoT"
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

# Main execution
case "${1:-}" in
    "--create-all"|"-a")
        create_all_character_desktops
        ;;
    "--menu"|"-m")
        show_menu
        ;;
    "--character"|"-c")
        if [ -n "${2:-}" ] && [ -n "${CHARACTERS[$2]:-}" ]; then
            setup_character_desktop "$2" 2 "generic"
        else
            echo "Usage: $0 --character CHARACTER_NAME"
            echo "Available characters: ${!CHARACTERS[*]}"
            exit 1
        fi
        ;;
    "--help"|"-h")
        echo "AI-Kit Linux Virtual Desktop Manager"
        echo "Usage: $0 [OPTION]"
        echo
        echo "Options:"
        echo "  -a, --create-all    Create all character desktops"
        echo "  -m, --menu          Show interactive menu"
        echo "  -c, --character     Create desktop for specific character"
        echo "  -h, --help          Show this help"
        echo
        echo "Available characters: ${!CHARACTERS[*]}"
        ;;
    *)
        echo -e "${CYAN}🎭 AI-Kit Linux Virtual Desktop Manager${NC}"
        echo "Usage: $0 [OPTION]"
        echo
        echo "Quick start:"
        echo "  $0 --menu              # Interactive menu"
        echo "  $0 --create-all        # Create all character desktops"
        echo "  $0 --character kyoko   # Create Kyoko's desktop only"
        echo
        echo "Run '$0 --help' for more options"
        ;;
esac
