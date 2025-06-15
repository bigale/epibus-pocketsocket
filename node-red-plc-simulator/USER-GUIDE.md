# 🎭 AI-Kit Industrial IoT Character Simulators - User Guide

Welcome to the AI-Kit Industrial IoT Node-RED Character Simulators! This guide will help you get started with using the Danganronpa character-driven industrial automation system.

## 🚀 Quick Start

### 1. Start All Simulators
```bash
cd /home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator
./scripts/manage.sh start
```

### 2. Check Status
```bash
./scripts/manage.sh status
```

### 3. Access Character Dashboards
- 🎯 **Kyoko Kirigiri** (Detective): http://localhost:1881
- 💰 **Byakuya Togami** (Heir): http://localhost:1882
- 💻 **Chihiro Fujisaki** (Programmer): http://localhost:1883
- 👑 **Celestia Ludenberg** (Gambler): http://localhost:1884
- 💪 **Sakura Ogami** (Fighter): http://localhost:1885

### 4. **🎯 View Live Character Dashboards** ⭐ **MOST IMPORTANT!**
**Add `/api/ui` to any character URL to see their live dashboard:**
- 🔍 **Kyoko's Live Dashboard**: http://localhost:1881**/api/ui**
- 💰 **Byakuya's Live Dashboard**: http://localhost:1882**/api/ui**
- 💻 **Chihiro's Live Dashboard**: http://localhost:1883**/api/ui**
- 👑 **Celestia's Live Dashboard**: http://localhost:1884**/api/ui**
- 💪 **Sakura's Live Dashboard**: http://localhost:1885**/api/ui**

### 5. Import Example Flows
1. Go to any character editor (URLs above without `/api/ui`)
2. Import flows from: `examples/` folder
3. Deploy and view results on live dashboard (`/api/ui`)

## 🎭 Character Personalities & Specialties

### 🎯 Kyoko Kirigiri - The Detective
**Personality**: Analytical detective with keen investigation skills
**Expertise**: Anomaly detection, root cause analysis, mystery solving
**Best For**: 
- Debugging complex industrial processes
- Monitoring for unusual patterns
- Root cause analysis of failures
- Security and anomaly detection

**Special Nodes**:
- `anomaly-detector` - Detects unusual patterns in data streams
- `evidence-collector` - Gathers diagnostic information
- `investigation-flow` - Systematic problem-solving workflows
- `mystery-generator` - Creates test scenarios for debugging

### 💰 Byakuya Togami - The Efficiency Expert
**Personality**: Efficiency-focused perfectionist with strategic mind
**Expertise**: Process optimization, performance analysis, cost reduction
**Best For**:
- Optimizing manufacturing processes
- Performance monitoring and improvement
- Cost analysis and reduction
- Quality control systems

**Special Nodes**:
- `efficiency-optimizer` - Analyzes and improves process efficiency
- `performance-monitor` - Tracks KPIs and performance metrics
- `cost-analyzer` - Calculates operational costs
- `quality-controller` - Implements quality assurance workflows

### 💻 Chihiro Fujisaki - The Programmer
**Personality**: Gentle programmer with exceptional technical skills
**Expertise**: System integration, data processing, automation logic
**Best For**:
- Complex data processing workflows
- System integrations and APIs
- Custom automation logic
- Database operations and analytics

**Special Nodes**:
- `data-processor` - Advanced data transformation and analysis
- `system-integrator` - Connects different industrial systems
- `logic-builder` - Creates complex conditional workflows
- `database-connector` - Interfaces with various databases

### 👑 Celestia Ludenberg - The Risk Manager
**Personality**: Sophisticated gambler with risk assessment expertise
**Expertise**: Risk analysis, predictive modeling, strategic planning
**Best For**:
- Predictive maintenance systems
- Risk assessment and mitigation
- Strategic resource allocation
- Probability-based decision making

**Special Nodes**:
- `risk-assessor` - Evaluates operational risks
- `predictor` - Forecasts equipment failures and trends
- `strategy-planner` - Optimizes resource allocation
- `probability-calculator` - Statistical analysis and modeling

### 💪 Sakura Ogami - The Reliability Engineer
**Personality**: Strong and dependable with focus on durability
**Expertise**: System reliability, stress testing, endurance monitoring
**Best For**:
- Stress testing industrial equipment
- Reliability and durability monitoring
- Load balancing and capacity planning
- Endurance testing workflows

**Special Nodes**:
- `stress-tester` - Performs system stress tests
- `endurance-monitor` - Tracks long-term system performance
- `load-generator` - Simulates various load conditions
- `reliability-analyzer` - Analyzes system reliability metrics

## 🛠️ How to Use Each Character

### Getting Started with a Character

1. **Choose Your Character** based on your industrial automation needs
2. **Access Their Dashboard** using the URLs above
3. **Explore the Node-RED Interface** - each character has a customized environment
4. **Use Character-Specific Nodes** available in the node palette
5. **Build Workflows** that match the character's expertise

### Example Workflows

#### 🎯 Kyoko's Anomaly Detection Flow
```
[inject] → [anomaly-detector] → [switch] → [debug]
                                    ↓
                               [evidence-collector] → [email alert]
```

#### 💰 Byakuya's Efficiency Monitoring
```
[modbus read] → [efficiency-optimizer] → [performance-monitor] → [dashboard chart]
                                                  ↓
                                            [cost-analyzer] → [report generator]
```

#### 💻 Chihiro's Data Processing Pipeline
```
[mqtt in] → [data-processor] → [database-connector] → [api response]
                    ↓
             [logic-builder] → [system-integrator] → [external system]
```

## 🔧 Advanced Usage

### Custom Node Development
Each character can have custom nodes developed for specific use cases:

1. **Navigate to Character's Node Directory**:
   ```bash
   cd node-red-plc-simulator/nodes/[character-id]/
   ```

2. **Create Custom Node**: Follow Node-RED node development patterns
3. **Restart Character**: Use management scripts to reload

### MODBUS Integration
Each character has a dedicated MODBUS server:
- **Kyoko**: localhost:5020
- **Byakuya**: localhost:5021
- **Chihiro**: localhost:5022
- **Celestia**: localhost:5023
- **Sakura**: localhost:5024

### Character-Specific WebSockets
Real-time communication endpoints:
- **Kyoko**: ws://localhost:1881/character-ws
- **Byakuya**: ws://localhost:1882/character-ws
- **Chihiro**: ws://localhost:1883/character-ws
- **Celestia**: ws://localhost:1884/character-ws
- **Sakura**: ws://localhost:1885/character-ws

## 🎯 Use Case Examples

### 1. Manufacturing Quality Control (Byakuya + Kyoko)
- **Byakuya**: Monitors production efficiency and quality metrics
- **Kyoko**: Investigates quality issues and anomalies
- **Integration**: Share data between characters via MQTT or HTTP

### 2. Predictive Maintenance (Celestia + Sakura)
- **Celestia**: Analyzes risk patterns and predicts failures
- **Sakura**: Performs stress tests and monitors equipment reliability
- **Integration**: Combined dashboard showing risk scores and stress test results

### 3. Smart Factory Automation (Chihiro + All Others)
- **Chihiro**: Central data processing and system integration hub
- **Others**: Specialized analysis and monitoring roles
- **Integration**: Chihiro orchestrates workflows across all characters

## 📊 Monitoring and Management

### Real-Time Status
```bash
./scripts/manage.sh status
```

### View Logs
```bash
./scripts/manage.sh logs
```

### Test Connections
```bash
./scripts/manage.sh test-ws
```

### Character URLs Quick Access
```bash
./scripts/manage.sh urls
```

## � Dashboard System Architecture

### Understanding the Three Dashboard Systems

Your AI-Kit Character Simulators use **three interconnected dashboard systems**:

#### 1. 🔧 **Node-RED Flow Editor** (Primary Development Interface)
- **URL**: http://localhost:188X (where X = 1-5 for each character)
- **Purpose**: Build flows, import examples, see debug output
- **What You Do**: Create nodes, edit functions, import JSON flows

#### 2. 📊 **Node-RED UI Dashboard** (Live Character Interface) ⭐ **MAIN DASHBOARD**
- **URL**: http://localhost:188X/api/ui 
- **Purpose**: **Real-time character dashboards with live data visualization**
- **What You See**: 
  - Live gauges showing character analysis
  - Real-time charts and sensor data
  - Character-specific themed interfaces
  - Interactive controls and status displays

#### 3. 🎭 **AI-Kit Control Panel** (System Management)
- **Purpose**: Start/stop system controls, character switching
- **Integration**: Works with the Node-RED systems above

### 🎯 **How to Access Character Dashboards**

#### Step 1: Import Dashboard Flows
1. Go to any character editor (e.g., http://localhost:1881 for Kyoko)
2. Click the **hamburger menu** (☰) → **Import**
3. Import one of these dashboard flows:
   - `kyoko-dashboard-flow.json` - Kyoko's detective dashboard
   - `universal-character-dashboard.json` - Works for any character
   - `industrial-iot-demo.json` - Full industrial simulation

#### Step 2: Deploy the Flow
1. Click the red **"Deploy"** button
2. Wait for "Successfully deployed" message

#### Step 3: View Live Dashboard
1. **Go to**: http://localhost:188X**/api/ui** ⭐ **This is the key URL!**
2. You'll see the character's live dashboard with:
   - Real-time data visualization
   - Character-themed interface
   - Interactive controls
   - Live analysis updates

### 🔍 **Character Dashboard Features**

#### **Kyoko's Detective Dashboard** (`/api/ui`)
- 🚨 **Suspicion Level Gauge** - Real-time anomaly detection
- 📊 **Sensor Evidence Chart** - Timeline of industrial data
- 📋 **Evidence List** - Live anomaly reports  
- 🔍 **Investigation Status** - Detective conclusions
- 📝 **Case Notes** - Character-specific analysis

#### **All Character Dashboards Include**:
- **Character Profile Display** - Name, specialty, description
- **Real-time Data Visualization** - Charts, gauges, status indicators
- **Character-Specific Analysis** - Personality-driven insights
- **Interactive Controls** - Buttons to trigger analysis
- **Live Status Updates** - Continuous monitoring

### 🎨 **Dashboard vs Debug Output**

**❌ What You DON'T Want**: Debug HTML text in the editor
- This is just preview text for development
- Shows in the Node-RED editor debug panel
- Not the actual user interface

**✅ What You DO Want**: Live dashboard at `/api/ui`
- Interactive gauges, charts, and controls
- Real-time data updates
- Character-themed beautiful interface
- Production-ready industrial monitoring

### 🌐 **Character Dashboard URLs**

| Character | Editor | **Live Dashboard** |
|-----------|--------|--------------------|
| 🔍 Kyoko | http://localhost:1881 | **http://localhost:1881/api/ui** |
| 💰 Byakuya | http://localhost:1882 | **http://localhost:1882/api/ui** |
| 💻 Chihiro | http://localhost:1883 | **http://localhost:1883/api/ui** |
| 👑 Celestia | http://localhost:1884 | **http://localhost:1884/api/ui** |
| 💪 Sakura | http://localhost:1885 | **http://localhost:1885/api/ui** |

## �🚀 Best Practices

### 1. Character Selection Strategy
- **Single Character**: Choose based on primary use case
- **Multi-Character**: Combine complementary personalities
- **Full Team**: Use all characters for comprehensive industrial automation

### 2. Workflow Design
- **Keep Character Personality in Mind**: Design flows that match character expertise
- **Use Character-Specific Nodes**: Leverage specialized capabilities
- **Cross-Character Communication**: Share data between characters when beneficial

### 3. Performance Optimization
- **Monitor Resource Usage**: Each character uses ~118MB RAM
- **Optimize Node Flows**: Keep flows efficient for better performance
- **Use Background Processing**: Leverage character-specific optimizations

### 4. Debugging and Troubleshooting
- **Check Character Logs**: Use management scripts to view logs
- **Monitor WebSocket Connections**: Ensure real-time communication works
- **Test MODBUS Connectivity**: Verify industrial protocol connections

## 🎭 Character Switching
To work with different characters for different tasks:

1. **Access Multiple Dashboards**: Open multiple browser tabs
2. **Share Data**: Use MQTT, HTTP, or file-based data sharing
3. **Coordinate Workflows**: Design complementary processes
4. **Monitor All**: Use the status script to monitor all characters

## 🚨 Troubleshooting

### Dashboard Issues

#### **❌ "I only see debug text, no dashboard"**
**Solution**: You're looking at the wrong URL!
- ❌ Wrong: http://localhost:1881 (editor debug output)
- ✅ Correct: http://localhost:1881**/api/ui** (live dashboard)

#### **❌ "Dashboard shows 'No flows' or is empty"**
**Solution**: Import a dashboard flow first
1. Go to http://localhost:1881 (editor)
2. Import any flow from `examples/` folder
3. Click **Deploy**
4. Then view http://localhost:1881**/api/ui**

#### **❌ "Import gives 'Input Not A JSON Array' error"**
**Solution**: Use the fixed flow files
- ✅ Use: `simple-character-demo.json`
- ✅ Use: `kyoko-dashboard-flow.json`  
- ✅ Use: `industrial-iot-demo.json`
- ❌ Avoid: Old `character-demo-flow.json` (now fixed)

### Common Issues
1. **Character Won't Start**: Check logs and port conflicts
2. **WebSocket Errors**: Verify Node-RED is properly initialized
3. **MODBUS Connection Failed**: Check port availability
4. **Performance Issues**: Monitor system resources

### Quick Fixes
```bash
# Restart all characters
./scripts/manage.sh restart

# Check for port conflicts
netstat -tulpn | grep "188[1-5]\|502[0-5]"

# Force clean restart
./scripts/manage.sh stop && sleep 5 && ./scripts/manage.sh start
```

## 🎉 Ready to Start!
Your AI-Kit Industrial IoT Character Simulators are ready to use. Choose your character, access their dashboard, and start building industrial automation workflows with personality!
