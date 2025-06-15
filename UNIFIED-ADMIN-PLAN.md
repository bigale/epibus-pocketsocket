# AI-Kit Industrial IoT - Unified Admin Script Plan

## Overview
This document outlines the design for a unified administrative script that consolidates all system management, monitoring, window management, and maintenance functions into a single interactive tool.

## Current Script Analysis

### System Management Scripts
1. **`setup.sh`** - Initial setup and dependency installation
2. **`launch-complete-system.sh`** - System startup with service monitoring
3. **`node-red-plc-simulator/scripts/manage.sh`** - Node-RED simulator management

### Window Management Scripts
4. **`scripts/wsl2-browser-grid.sh`** - WSL2/Linux browser window management
5. **`scripts/windows-virtual-desktops.ps1`** - Windows virtual desktop management
6. **`scripts/test-wsl2-capabilities.sh`** - Environment capability testing

### Monitoring & Testing Scripts
7. **`verify-installation.sh`** - Installation verification
8. **`final-integration-test.sh`** - Integration testing
9. **`log-harvester.sh`** - Log collection and analysis

## Unified Admin Script Architecture

### Main Menu Structure
```
🎭 AI-Kit Industrial IoT - Unified Admin Console
=====================================================

1. 🚀 SYSTEM MANAGEMENT
   1.1 Setup & Installation
   1.2 Start Complete System
   1.3 Stop System
   1.4 Restart System
   1.5 Service Status

2. 🖥️  WINDOW MANAGEMENT
   2.1 Launch Character Workspaces
   2.2 Create Browser Grid (WSL2/Linux)
   2.3 Create Virtual Desktops (Windows)
   2.4 Kill All Browser Windows
   2.5 Test Display Capabilities

3. 📊 MONITORING & DIAGNOSTICS
   3.1 Service Health Check
   3.2 View Live Logs
   3.3 Connection Testing
   3.4 Performance Monitor
   3.5 Error Analysis

4. 🔧 MAINTENANCE
   4.1 Clear Logs
   4.2 Restart Services
   4.3 Database Cleanup
   4.4 Update Dependencies

5. 🧪 TESTING & VALIDATION
   5.1 Run Integration Tests
   5.2 WebSocket Testing
   5.3 MODBUS Testing
   5.4 Performance Benchmarks

6. 📖 HELP & INFORMATION
   6.1 Show Character Information
   6.2 Show Port Mappings
   6.3 Show Available URLs
   6.4 Troubleshooting Guide

0. Exit
```

## Integration Strategy

### Phase 1: Core Integration
- Merge `launch-complete-system.sh` and `manage.sh` capabilities
- Add cross-platform window management dispatch
- Integrate service monitoring and health checks

### Phase 2: Advanced Features
- Add real-time log monitoring with character filtering
- Integrate performance metrics collection
- Add automated problem detection and resolution suggestions

### Phase 3: Enhanced UX
- Add character-specific context menus
- Implement dashboard embedding capability
- Add configuration management interface

## Technical Implementation

### Script Structure
```bash
#!/bin/bash
# ai-kit-admin.sh - Unified AI-Kit Industrial IoT Admin Console

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHARACTERS=("kyoko" "byakuya" "chihiro" "celestia" "sakura")

# Platform Detection
detect_platform() {
    # Windows, WSL2, Linux detection logic
}

# Core Functions
system_management() {
    # Integrate launch-complete-system.sh functionality
}

window_management() {
    # Platform-specific window management dispatch
    case $platform in
        "windows") exec powershell scripts/windows-virtual-desktops.ps1 ;;
        "wsl2"|"linux") exec scripts/wsl2-browser-grid.sh ;;
    esac
}

monitoring_diagnostics() {
    # Service health, logs, connections, performance
}

maintenance() {
    # Cleanup, restart, updates
}

testing_validation() {
    # Integration tests, benchmarks
}
```

### Key Features

#### Smart Platform Detection
- Automatically detect Windows, WSL2, or native Linux
- Dispatch to appropriate window management tools
- Handle environment capability testing

#### Character-Centric Organization
- Group actions by character (Kyoko, Byakuya, etc.)
- Character-specific service monitoring
- Individual character workspace management

#### Service Health Dashboard
```
📊 System Status Dashboard
==========================
🕵️  Kyoko (1881/5020):     ✅ Online  | 🌐 Browser: 2 windows
💼 Byakuya (1882/5021):    ✅ Online  | 🌐 Browser: 2 windows  
💻 Chihiro (1883/5022):    ⚠️  Slow   | 🌐 Browser: 1 window
🎨 Celestia (1884/5023):   ❌ Offline | 🌐 Browser: 0 windows
💪 Sakura (1885/5024):     ✅ Online  | 🌐 Browser: 2 windows

🏭 Main Dashboard (4321):   ✅ Online
📊 Active Connections:     47
🔄 System Uptime:         2h 34m
💾 Memory Usage:          2.1GB / 8GB
```

#### Intelligent Problem Detection
- Detect common issues (ports blocked, services down, etc.)
- Suggest automated fixes
- One-click resolution for common problems

#### Log Aggregation & Filtering
- Real-time log tailing with character filtering
- Error highlighting and pattern detection
- Export filtered logs for analysis

## File Organization

### New Files to Create
1. **`ai-kit-admin.sh`** - Main unified admin script
2. **`scripts/admin/`** - Admin-specific modules
   - `system-management.sh`
   - `monitoring.sh` 
   - `maintenance.sh`
   - `testing.sh`
3. **`config/admin-config.json`** - Admin script configuration

### Integration Points
- **Existing scripts become modules** - Current scripts become callable modules
- **Configuration centralization** - Single config file for all admin functions
- **Cross-platform compatibility** - Smart platform detection and tool dispatch

## Benefits

### For Development
- Single entry point for all admin tasks
- Consistent interface across platforms
- Reduced context switching between tools

### For Operations
- Unified monitoring dashboard
- Automated problem detection
- Simplified troubleshooting workflow

### For Future Embedding
- Designed for terminal widget integration in dashboard
- API-ready architecture for web interface
- Scriptable for automation

## Implementation Timeline

### Week 1: Core Framework
- Create main admin script structure
- Integrate system management functions
- Add basic platform detection

### Week 2: Window Management Integration
- Add cross-platform window management dispatch
- Integrate existing browser grid and virtual desktop tools
- Add window status monitoring

### Week 3: Monitoring & Diagnostics
- Add real-time service monitoring
- Implement log aggregation
- Add connection testing suite

### Week 4: Polish & Testing
- Add help system and documentation
- Performance optimization
- Comprehensive testing across platforms

## Future Enhancements

### Dashboard Integration
- Terminal widget for dashboard embedding
- Real-time status updates in web UI
- Remote administration capabilities

### Automation Features
- Scheduled maintenance tasks
- Automated problem resolution
- Performance optimization suggestions

### Advanced Monitoring
- Metrics collection and visualization
- Alerting system integration
- Historical performance tracking

This unified admin script will provide a single, powerful interface for managing the entire AI-Kit Industrial IoT system while maintaining the flexibility and platform-specific optimizations of the existing tools.
