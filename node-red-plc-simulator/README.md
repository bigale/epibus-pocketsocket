# 🎭 Node-RED PLC Simulator - AI-Kit Character-Driven Edition

A revolutionary Node-RED based PLC simulation system that brings industrial automation to life through AI-Kit's character-driven personalities. Each character provides unique simulation capabilities, analytical approaches, and visual themes.

## 🌟 Features

### 🎭 Character-Driven Simulation
- **Kyoko Kirigiri** 🕵️ - Detective & Anomaly Investigation Lab
- **Byakuya Togami** 💼 - Efficiency & Performance Optimization Center  
- **Chihiro Fujisaki** 💻 - Technical Integration & Innovation Lab
- **Celestia Ludenberg** 🎨 - UI/UX & Aesthetic Design Studio
- **Sakura Ogami** 💪 - Stress Testing & Reliability Analysis

### 🔧 Technical Capabilities
- **Multiple Node-RED Instances**: Each character runs their own isolated Node-RED environment
- **MODBUS/TCP Simulation**: Character-specific MODBUS servers with unique port configurations
- **Real-time Dashboards**: Personality-themed UI dashboards for each character
- **WebSocket Integration**: Real-time communication with AI-Kit universal framework
- **Collaborative Scenarios**: Multi-character simulation orchestration
- **RESTful APIs**: Programmatic control and monitoring of all simulators

### 🏭 Industrial Applications
- PLC behavior simulation and testing
- MODBUS protocol validation and development
- Industrial IoT system prototyping
- HMI/SCADA interface development
- Process automation algorithm testing
- Multi-vendor system integration testing

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Python 3.8+ (for some industrial nodes)
- Git

### Installation

```bash
# Clone and navigate to the project
git clone https://github.com/bigale/epibus-pocketsocket.git
cd epibus-pocketsocket/ai-kit/industrial-iot/node-red-plc-simulator

# Install dependencies
npm install

# Install Node-RED global dependencies (optional but recommended)
npm run install:nodes

# Build the TypeScript project
npm run build
```

### Running Simulators

#### Start All Character Simulators
```bash
npm start
# or
./scripts/manage-simulators.sh start
```

#### Start Individual Characters
```bash
npm run start:kyoko     # Detective lab on port 1881
npm run start:byakuya   # Efficiency center on port 1882
npm run start:chihiro   # Tech lab on port 1883
npm run start:celestia  # Design studio on port 1884
npm run start:sakura    # Testing lab on port 1885
```

#### Check Status
```bash
npm run status
# Shows running status, ports, and resource usage
```

#### Stop Simulators
```bash
npm run stop           # Stop all
npm run stop:kyoko     # Stop specific character
```

## 🎭 Character Simulator Details

### 🕵️ Kyoko Kirigiri - Detective Investigation Lab
**Port**: 1881 | **MODBUS**: 5020 | **Theme**: Detective Purple

**Specializations**:
- Anomaly detection and pattern analysis
- Evidence collection and systematic investigation
- Root cause analysis and mystery solving
- Statistical deviation monitoring

**Key Features**:
- Advanced anomaly detection algorithms
- Evidence cataloging and case management
- Pattern recognition across sensor data
- Investigation workflow automation

**Dashboard**: http://localhost:1881/ui

### 💼 Byakuya Togami - Efficiency Optimization Center
**Port**: 1882 | **MODBUS**: 5021 | **Theme**: Efficiency Blue

**Specializations**:
- Overall Equipment Effectiveness (OEE) calculation
- Performance optimization and cost analysis
- KPI monitoring and reporting
- Lean manufacturing principles

**Key Features**:
- Real-time efficiency scoring
- Cost-benefit analysis tools
- Performance benchmarking
- Resource utilization optimization

**Dashboard**: http://localhost:1882/ui

### 💻 Chihiro Fujisaki - Technical Integration Lab
**Port**: 1883 | **MODBUS**: 5022 | **Theme**: Tech Green

**Specializations**:
- Protocol bridging and system integration
- Algorithm development and testing
- IoT device communication
- Data format transformation

**Key Features**:
- Multi-protocol support and translation
- Custom algorithm sandbox
- System integration testing
- Innovation and experimentation tools

**Dashboard**: http://localhost:1883/ui

### 🎨 Celestia Ludenberg - Aesthetic Design Studio
**Port**: 1884 | **MODBUS**: 5023 | **Theme**: Elegant Red

**Specializations**:
- UI/UX design and visualization
- Aesthetic optimization and theming
- User experience enhancement
- Visual data presentation

**Key Features**:
- Beautiful visualization components
- Theme customization tools
- User interface optimization
- Aesthetic analysis and scoring

**Dashboard**: http://localhost:1884/ui

### 💪 Sakura Ogami - Reliability Testing Lab
**Port**: 1885 | **MODBUS**: 5024 | **Theme**: Strength Orange

**Specializations**:
- Stress testing and load simulation
- Endurance and reliability analysis
- Performance under pressure
- System robustness validation

**Key Features**:
- Load generation and stress testing
- Endurance monitoring tools
- Reliability scoring and analysis
- Performance degradation detection

**Dashboard**: http://localhost:1885/ui

## 🔧 Advanced Usage

### Collaborative Scenarios

Create scenarios involving multiple characters working together:

```bash
# Create a collaborative investigation scenario
npm run collaborate mystery_investigation

# Custom collaborative scenario
./scripts/manage-simulators.sh collaborate "multi_vendor_integration"
```

### Monitoring and Logs

```bash
# Monitor all simulator logs
npm run logs

# Monitor specific character logs
./scripts/manage-simulators.sh logs kyoko

# Health check all simulators
npm run health
```

### Programmatic Control

Each character simulator provides a RESTful API:

```javascript
// Get character status
const response = await fetch('http://localhost:1881/api/character');
const kyokoStatus = await response.json();

// Execute character-specific action
await fetch('http://localhost:1881/api/character-action', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    type: 'inject_anomaly',
    params: { sensor: 5, deviation: 0.3 }
  })
});

// Load scenario
await fetch('http://localhost:1881/api/scenario/investigation_scenario', {
  method: 'POST'
});
```

### WebSocket Real-time Communication

```javascript
// Connect to Kyoko's WebSocket
const ws = new WebSocket('ws://localhost:1981');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Kyoko update:', data);
};

// Send command
ws.send(JSON.stringify({
  type: 'start_investigation',
  params: { priority: 'high' }
}));
```

## 🏗️ Custom Scenarios

### Creating Character-Specific Scenarios

Scenarios are defined in JSON format in the `scenarios/[character]/` directories:

```json
{
  "id": "custom_scenario",
  "name": "Custom Scenario Name",
  "description": "Description of the scenario",
  "flows": [
    {
      "id": "main_flow",
      "nodes": [
        // Node-RED flow definition
      ]
    }
  ],
  "modbusConfig": {
    // MODBUS server configuration
  },
  "dashboardConfig": {
    // Dashboard theme and layout
  }
}
```

### Adding Custom Nodes

1. Create custom Node-RED nodes in `nodes/[character]/`
2. Register them in the character's Node-RED instance
3. Use them in scenario definitions

## 🔗 Integration with AI-Kit

The Node-RED simulators integrate seamlessly with the AI-Kit ecosystem:

### Universal Framework Integration
- Connects to the universal PLC adapter
- Shares data with SUIL industrial analysis
- Integrates with character agents for decision making

### Astro-Host Dashboard Integration
- Embedded in the main AI-Kit dashboard
- Character-specific panels and controls
- Real-time status updates and alerts

### PocketSocket Real-time Engine
- Real-time data streaming to PocketSocket
- Bi-directional communication for control
- Event-driven architecture integration

## 📊 Web Dashboard

Access the central management dashboard at:
- **File**: `dashboard.html` (open in browser)
- **Features**: Start/stop simulators, view status, monitor health
- **Real-time**: Auto-refreshing status and metrics

## 🛠️ Development

### Project Structure
```
node-red-plc-simulator/
├── src/                     # TypeScript source code
│   ├── character-simulator.ts   # Main character simulator class
│   ├── simulator-manager.ts     # Multi-simulator management
│   └── index.ts                # Entry points
├── scenarios/               # Character-specific scenarios
│   ├── kyoko/              # Kyoko's investigation scenarios
│   ├── byakuya/            # Byakuya's efficiency scenarios
│   └── ...                 # Other characters
├── scripts/                # Management and utility scripts
│   ├── manage-simulators.sh    # Main management script
│   └── ...                 # Other utility scripts
├── data/                   # Runtime data and logs
├── logs/                   # Character-specific log files
├── dashboard.html          # Web management dashboard
└── package.json            # Dependencies and scripts
```

### Building and Testing
```bash
# Development with auto-rebuild
npm run dev

# Build TypeScript
npm run build

# Run tests
npm test

# Lint and format
npm run lint
npm run format
```

### Adding New Characters

1. Add character configuration to `character-simulator.ts`
2. Create scenario directory: `scenarios/[character]/`
3. Add character-specific Node-RED nodes
4. Update management scripts with new character
5. Create character-specific dashboard theme

## 🤝 Integration Examples

### Manufacturing Plant Simulation
```bash
# Start all simulators for a complete plant
npm start

# Create a collaborative manufacturing scenario
npm run collaborate "production_line_optimization"

# Monitor efficiency across all characters
curl http://localhost:1882/api/character  # Byakuya's efficiency data
```

### IoT Development Platform
```bash
# Start tech-focused characters
npm run start:chihiro
npm run start:sakura

# Test protocol integration
curl -X POST http://localhost:1883/api/character-action \
  -H "Content-Type: application/json" \
  -d '{"type": "integrate_system", "params": {"protocol": "mqtt"}}'
```

### Quality Assurance Testing
```bash
# Start investigation and testing characters
npm run start:kyoko
npm run start:sakura

# Run collaborative quality investigation
npm run collaborate "quality_assurance_protocol"
```

## 📝 Configuration

### Environment Variables
- `CHARACTER`: Character ID for single simulator mode
- `PORT`: Override default port for character
- `MODBUS_PORT`: Override default MODBUS port
- `THEME`: Override character theme
- `LOG_LEVEL`: Logging level (debug, info, warn, error)

### Character Customization
Each character's behavior can be customized by modifying:
- Scenario JSON files in `scenarios/[character]/`
- Character-specific Node-RED nodes
- Dashboard themes and layouts
- API endpoints and actions

## 🎯 Use Cases

### Industrial Automation Development
- Test PLC programming logic before deployment
- Validate MODBUS communication protocols
- Develop and test HMI interfaces
- Simulate multi-vendor equipment integration

### IoT System Prototyping
- Prototype sensor data processing workflows
- Test edge computing algorithms
- Validate cloud connectivity patterns
- Develop device management strategies

### Educational and Training
- Learn industrial automation concepts
- Practice with Node-RED and MODBUS
- Understand character-driven AI systems
- Explore industrial IoT architectures

### Research and Innovation
- Experiment with AI-driven automation
- Test novel industrial algorithms
- Prototype character-based interfaces
- Develop next-generation industrial systems

## 🚀 Performance and Scalability

### Resource Usage
- Each character simulator: ~50-100MB RAM
- CPU usage: <5% per simulator under normal load
- Network: Minimal bandwidth for MODBUS simulation
- Storage: <10MB per character for scenarios and logs

### Scaling Recommendations
- Run 1-3 characters on development machines
- Use dedicated servers for all 5 characters in production
- Monitor resource usage with `npm run health`
- Use load balancing for high-throughput scenarios

## 🔒 Security Considerations

### Network Security
- MODBUS servers bind to localhost by default
- Use firewall rules for external access
- Configure authentication for production use
- Monitor access logs for suspicious activity

### Development Security
- Characters run in isolated Node-RED instances
- Scenario files are sandboxed
- API endpoints have basic validation
- Use HTTPS in production deployments

## 📚 API Reference

### Character Simulator API

Each character provides a consistent API:

#### GET /api/character
Returns character information and status.

#### POST /api/character-action
Execute character-specific actions.

#### POST /api/scenario/:scenarioId
Load and activate a scenario.

#### WebSocket /ws
Real-time bidirectional communication.

See the full API documentation in the source code and example scenarios.

## 🛟 Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Check what's using the port
lsof -i :1881

# Kill the process or change the port
kill -9 <PID>
```

**Node-RED Module Not Found**
```bash
# Install missing Node-RED modules
npm run install:nodes
```

**Permission Denied (Linux/Mac)**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

**Character Won't Start**
```bash
# Check logs for specific character
npm run logs kyoko

# Verify all dependencies
npm install
npm run build
```

### Performance Issues

**High CPU Usage**
- Reduce polling rates in MODBUS nodes
- Optimize function node logic
- Check for infinite loops in flows

**Memory Leaks**
- Monitor with `npm run health`
- Restart characters periodically
- Check for unclosed connections

## 📞 Support and Contributing

### Getting Help
- Check the logs: `npm run logs`
- Review the scenarios for examples
- Use the health check: `npm run health`
- Open issues on GitHub for bugs

### Contributing
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

### Roadmap
- Additional character personalities
- Enhanced collaborative scenarios
- Integration with more industrial protocols
- Advanced AI-driven simulation features
- Cloud deployment capabilities

---

## 🏆 Conclusion

The AI-Kit Node-RED PLC Simulator represents a breakthrough in industrial automation development, combining the power of Node-RED with character-driven AI personalities. Each character brings unique perspectives and capabilities to your industrial IoT projects, making development more engaging, educational, and effective.

Whether you're developing PLCs, prototyping IoT systems, or learning industrial automation, our character-driven simulators provide the tools and personalities to bring your projects to life.

**Start your industrial automation journey with AI-Kit character-driven simulation today!** 🎭✨
