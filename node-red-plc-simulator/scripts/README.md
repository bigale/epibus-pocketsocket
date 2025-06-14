# AI-Kit Node-RED Character Simulators Management Scripts

This directory contains management scripts for the AI-Kit Node-RED Character Simulators.

## Quick Start

The easiest way to manage the simulators is with the main management script:

```bash
# Show all available commands
./scripts/manage.sh

# Start all simulators
./scripts/manage.sh start

# Check status
./scripts/manage.sh status

# Show dashboard URLs
./scripts/manage.sh urls

# Restart all simulators
./scripts/manage.sh restart

# Stop all simulators
./scripts/manage.sh stop
```

## Individual Scripts

### `manage.sh` - Main Management Script
The primary interface for all simulator operations. Provides a unified command interface.

### `start-all.sh` - Start All Simulators
Starts all 5 character simulators in the background with proper environment configuration.

### `stop-all.sh` - Stop All Simulators
Safely stops all running character simulators, with force-kill fallback for stubborn processes.

### `restart-all.sh` - Restart All Simulators
Combines stop and start operations for a clean restart of all simulators.

### `status.sh` - Status Check
Shows detailed status of all simulators including:
- Process status and PIDs
- Port listening status
- Health checks based on logs

## Character Simulators

| Character | Dashboard | MODBUS | WebSocket | Icon |
|-----------|-----------|---------|-----------|------|
| Kyoko Kirigiri | http://localhost:1881 | localhost:5020 | 1981 | 🎯 |
| Byakuya Togami | http://localhost:1882 | localhost:5021 | 1982 | 💰 |
| Chihiro Fujisaki | http://localhost:1883 | localhost:5022 | 1983 | 💻 |
| Celestia Ludenberg | http://localhost:1884 | localhost:5023 | 1984 | 👑 |
| Sakura Ogami | http://localhost:1885 | localhost:5024 | 1985 | 💪 |

## Prerequisites

1. **TypeScript Build**: Ensure the project is built before starting simulators:
   ```bash
   npm run build
   ```

2. **Dependencies**: All npm dependencies should be installed:
   ```bash
   npm install
   ```

## Troubleshooting

### Common Issues

1. **Port Conflicts**: If simulators fail to start due to port conflicts, use:
   ```bash
   ./scripts/stop-all.sh
   ./scripts/start-all.sh
   ```

2. **Build Errors**: If you've made TypeScript changes, rebuild and restart:
   ```bash
   ./scripts/manage.sh build
   ```

3. **Check Logs**: View recent log entries:
   ```bash
   ./scripts/manage.sh logs
   ```

4. **Individual Log Files**: Check specific character logs:
   ```bash
   cat kyoko.log
   cat byakuya.log
   # etc.
   ```

### Manual Process Management

If the scripts fail, you can manually manage processes:

```bash
# Find running simulators
ps aux | grep "node dist/character-simulator.js"

# Kill specific process
kill [PID]

# Check port usage
netstat -tulpn | grep "188[1-5]\|198[1-5]\|502[0-5]"
```

## Development Workflow

1. Make changes to TypeScript source files
2. Build and restart: `./scripts/manage.sh build`
3. Check status: `./scripts/manage.sh status`
4. Access dashboards: `./scripts/manage.sh urls`

## Features

- ✅ Automated process management
- ✅ Health monitoring
- ✅ Port conflict resolution
- ✅ Background process handling
- ✅ Log aggregation
- ✅ Character-specific configuration
- ✅ Graceful shutdown with force-kill fallback
