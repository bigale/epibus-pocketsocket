# 🏗️ AI-Kit Industrial IoT - Cross-Platform Virtual Desktop Architecture

## 🎯 Overview

This document describes the **dual-platform virtual desktop solution** for the AI-Kit Industrial IoT system, supporting both **Windows native virtual desktops** and **Linux/WSL2 X11 window management**.

## 🏭 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI-Kit Industrial IoT                        │
│                   Character-Based Automation                    │
└─────────────────────┬───────────────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
        ▼                           ▼
┌───────────────┐            ┌──────────────┐
│ Windows Host  │            │ WSL2 + X11   │
│ Environment   │            │ Environment  │
└───────────────┘            └──────────────┘
        │                           │
        ▼                           ▼
┌───────────────┐            ┌──────────────┐
│ PowerShell    │            │ Bash Scripts │
│ Virtual       │            │ X11 Window   │
│ Desktop API   │            │ Management   │
└───────────────┘            └──────────────┘
```

## 🎭 Character Desktop Layout

### Common Layout Pattern
Each character gets a dedicated workspace with:

1. **Node-RED Editor** - Main flow development interface
2. **Node-RED Dashboard** - Real-time monitoring UI  
3. **Character Terminal** - Command-line access
4. **Main AI-Kit Dashboard** - System overview (Kyoko only)

### Character Specializations

| Character | Port | MODBUS | Specialization | Focus Area |
|-----------|------|--------|----------------|------------|
| **Kyoko** | 1881 | 5020 | Investigation & Analysis | Pattern detection, anomaly investigation |
| **Byakuya** | 1882 | 5021 | Quality Control | Statistical process control, excellence |
| **Chihiro** | 1883 | 5022 | System Integration | Programming, system connectivity |
| **Celestia** | 1884 | 5023 | UI/UX Design | Interface design, user experience |
| **Sakura** | 1885 | 5024 | Reliability Testing | Stress testing, system robustness |

## 🖥️ Platform-Specific Implementations

### Windows Implementation

**Files:**
- `scripts/windows-virtual-desktops.ps1` - Full PowerShell implementation
- `scripts/windows-virtual-desktops-simple.ps1` - Keyboard shortcut approach
- `scripts/setup-character-desktops.bat` - Easy launcher

**Features:**
- Native Windows Virtual Desktop API integration
- Task View (Win+Tab) automation
- Character-specific browser window positioning
- Automatic desktop switching with Ctrl+Win+Left/Right

**Workflow:**
```powershell
# Create all character desktops
.\windows-virtual-desktops-simple.ps1 -CreateAll

# Interactive menu
.\windows-virtual-desktops-simple.ps1 -Menu

# Single character
.\windows-virtual-desktops-simple.ps1 -Character "Kyoko"
```

### Linux/WSL2 Implementation

**Files:**
- `scripts/linux-virtual-desktops.sh` - Full Linux window manager support
- `scripts/wsl2-window-manager.sh` - WSL2-optimized implementation

**Features:**
- Multi-desktop environment support (GNOME, KDE, i3, sway)
- X11 window management with wmctrl/xdotool
- Browser window positioning and organization
- Terminal window integration

**Workflow:**
```bash
# Create all character workspaces
./scripts/wsl2-window-manager.sh --create-all

# Interactive menu
./scripts/wsl2-window-manager.sh --menu

# Single character
./scripts/wsl2-window-manager.sh --character kyoko
```

## 🔧 Technical Architecture

### Windows Virtual Desktop Management

```
PowerShell Script
       │
       ├── Windows.System.VirtualDesktop API
       ├── Task View Automation (Win+Tab)
       ├── Keyboard Shortcuts (Ctrl+Win+D)
       └── Browser Window Management
               │
               ├── Chrome/Edge --new-window
               ├── Window positioning parameters
               └── Character-specific URLs
```

### Linux X11 Window Management

```
Bash Script
       │
       ├── Desktop Environment Detection
       │   ├── GNOME (gsettings/wmctrl)
       │   ├── KDE (qdbus/wmctrl)
       │   ├── i3/sway (i3-msg/swaymsg)
       │   └── Generic (wmctrl)
       │
       ├── X11 Window Management
       │   ├── wmctrl (desktop/window control)
       │   ├── xdotool (window positioning)
       │   └── xwininfo (window information)
       │
       └── Browser Integration
           ├── Chrome/Chromium --window-position
           ├── Firefox --new-window
           └── Terminal integration
```

## 🌐 URL Management Strategy

### Character URL Patterns
```
Base Pattern: http://localhost:PORT[/path]

Editor URLs:
- Kyoko:    http://localhost:1881
- Byakuya:  http://localhost:1882  
- Chihiro:  http://localhost:1883
- Celestia: http://localhost:1884
- Sakura:   http://localhost:1885

Dashboard URLs:
- Pattern: http://localhost:PORT/api/ui
- Example: http://localhost:1881/api/ui

Main Dashboard:
- AI-Kit:   http://localhost:4321
```

### Service Discovery Integration
Both implementations integrate with the existing `useNodeRedServices` hook for dynamic URL discovery:

```typescript
const { getDashboardUrl, getEditorUrl } = useNodeRedServices();
const dashboardUrl = getDashboardUrl(character);
const editorUrl = getEditorUrl(character);
```

## 🎮 Navigation Patterns

### Windows Navigation
```
Ctrl + Win + Left/Right  → Switch virtual desktops
Win + Tab               → Open Task View (see all desktops)
Ctrl + Win + D          → Create new virtual desktop
Ctrl + Win + F4         → Close current virtual desktop
Alt + Tab               → Switch between windows on current desktop
```

### Linux Navigation
```
# GNOME
Super + Page Up/Down     → Switch workspaces
Ctrl + Alt + Left/Right  → Switch workspaces
Super + A                → Activities overview

# KDE
Ctrl + F1-F6            → Switch to specific desktop
Ctrl + Alt + Left/Right → Switch desktops
Meta + Tab              → Desktop grid

# i3/sway
Super + 1-6             → Switch to workspace
Super + Shift + 1-6     → Move window to workspace

# Generic X11
Ctrl + Alt + Left/Right → Switch desktops
```

## 🔄 Integration with Launch Scripts

### Windows Integration
```batch
# In launch-complete-system.bat
call scripts\setup-character-desktops.bat

# Or PowerShell
powershell -ExecutionPolicy Bypass -File scripts\windows-virtual-desktops-simple.ps1 -CreateAll
```

### Linux Integration
```bash
# In launch-complete-system.sh
./scripts/wsl2-window-manager.sh --create-all

# Or with service check
if [ "$DISPLAY" ]; then
    ./scripts/wsl2-window-manager.sh --menu
fi
```

## 🛠️ Dependencies

### Windows Requirements
- Windows 10 version 1803+ (Virtual Desktop API)
- PowerShell 5.1+ or PowerShell Core
- Modern browser (Chrome, Edge, Firefox)

### Linux Requirements
```bash
# Essential tools
sudo apt-get install -y wmctrl xdotool x11-utils

# Browser (one of)
sudo apt-get install -y chromium-browser
# or google-chrome-stable
# or firefox

# Terminal (optional, usually pre-installed)
sudo apt-get install -y gnome-terminal
```

### WSL2 Specific
```bash
# X11 forwarding setup
export DISPLAY=localhost:10.0

# Windows X server (one of):
# - VcXsrv
# - Xming  
# - Windows Subsystem for Linux GUI (WSLg)
```

## 🎯 Use Cases

### Development Workflow
1. **Start AI-Kit system** with character simulators
2. **Create character desktops** using platform-specific script
3. **Switch between characters** using keyboard shortcuts
4. **Each character workspace** contains their specialized tools
5. **Focused development** without UI clutter

### Operational Monitoring
1. **Each character monitors** their specialty area
2. **Quick switching** between industrial domains
3. **Character-specific dashboards** for real-time data
4. **Coordinated responses** across character teams

### Demo and Training
1. **Character-specific presentations** on dedicated desktops
2. **Smooth transitions** between different automation aspects
3. **Professional appearance** with organized layouts
4. **Educational narrative** following character personalities

## 🚀 Advanced Features

### Window Organization
- **Grid layouts** for optimal screen utilization
- **Character-specific positioning** with offset patterns
- **Multi-monitor support** with screen-aware positioning
- **Window state management** (minimize/maximize automation)

### Integration Hooks
- **Launch script integration** for automatic setup
- **Service health checks** before window creation
- **Dynamic URL discovery** using existing service hooks
- **Error handling** for missing services or display issues

### Customization Options
- **Character-specific window sizes** based on specialization
- **Color-coded terminal themes** matching character personalities
- **Desktop wallpaper automation** (planned feature)
- **Keyboard shortcut customization** per platform

## 📊 Performance Considerations

### Resource Management
- **Staggered window opening** to prevent X11 overload
- **Service availability checks** before URL opening
- **Memory usage monitoring** for multiple browser instances
- **Graceful degradation** when services are unavailable

### Scalability
- **Character addition** through configuration arrays
- **Port range management** for service expansion
- **Desktop limit awareness** per platform
- **Cleanup procedures** for desktop/window management

## 🔮 Future Enhancements

### Advanced Virtual Desktop Features
- **Desktop wallpaper automation** per character theme
- **Window snapshot/restore** for session persistence
- **Cross-platform synchronization** between Windows/Linux
- **Character-specific keyboard shortcuts** and hotkeys

### Integration Improvements
- **Voice activation** for character switching
- **Gesture support** for touch-enabled displays
- **Multi-user support** with character assignment
- **Cloud desktop synchronization** for distributed teams

### Monitoring and Analytics
- **Character workspace usage tracking**
- **Performance metrics** per character environment
- **Automated optimization** based on usage patterns
- **Health monitoring** for desktop environment stability

---

## 🎉 Summary

This cross-platform virtual desktop architecture provides a **professional, character-driven workspace management solution** for the AI-Kit Industrial IoT system. Whether running on **Windows with native virtual desktops** or **Linux/WSL2 with X11 window management**, users get a consistent, organized, and efficient multi-character development and monitoring environment.

The solution scales from **single character focus** to **full multi-character orchestration**, supporting both development workflows and operational monitoring scenarios with equal effectiveness.

**Key Benefits:**
- 🎭 **Character-specific workspaces** for focused development
- ⚡ **Fast switching** between industrial automation domains  
- 🔧 **Professional organization** of development tools
- 🌐 **Cross-platform consistency** between Windows and Linux
- 🚀 **Integration-ready** with existing AI-Kit infrastructure

*Ready for immediate deployment in both Windows desktop and WSL2 environments!* 🎊
