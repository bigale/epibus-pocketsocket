# Node-RED Flow Content & Debugging Architecture Explanation

## Current Architecture Overview

### 🏗️ **Two-Layer System**

#### **Layer 1: AI-Kit Dashboard (Astro/React)**
- **Purpose**: Documentation, monitoring, and meta-analysis
- **Content**: Flow documentation, performance metrics, system overview
- **Data Source**: Static content collections + API endpoints
- **User Experience**: High-level system management and learning

#### **Layer 2: Node-RED Dashboards**
- **Purpose**: Live operational control and real-time data
- **Content**: Interactive controls, live sensor data, real-time charts
- **Data Source**: Actual Node-RED flows with live data processing
- **User Experience**: Hands-on industrial system operation

## How Flow Content Should Work

### 📚 **AI-Kit Documentation (Static)**
Located in `/content/node-red-flows/kyoko-reactor-control.md`:
```markdown
---
title: "Kyoko's Industrial Process Control Flow"
character: kyoko
description: "Temperature and pressure monitoring system"
---

## Flow Overview
This flow demonstrates Kyoko's detective approach to industrial monitoring...

## Key Components
- Temperature sensors
- Pressure monitoring
- Anomaly detection logic

## Usage Instructions
1. Start the flow in Node-RED
2. Monitor the dashboard at http://localhost:1881/api/ui/
3. Observe detective analysis patterns
```

### 🔄 **Node-RED Live Implementation**
Located in `/data/kyoko/kyoko-flows.json`:
```json
[
  {
    "id": "kyoko-analysis",
    "type": "function", 
    "name": "🔍 Detective Analysis Engine",
    "func": "// Actual working JavaScript code..."
  },
  {
    "id": "ui-gauge-suspicion",
    "type": "ui_gauge",
    "title": "🚨 Suspicion Level"
  }
]
```

## Content Display Architecture

### ✅ **What SHOULD Happen**

#### **AI-Kit Dashboard**
- **Documentation**: Human-readable explanations of what each flow does
- **Architecture**: Flow diagrams and component relationships  
- **Learning**: Tutorial content and best practices
- **Monitoring**: High-level system status and performance metrics
- **Navigation**: Links to open actual Node-RED editors and dashboards

#### **Node-RED Dashboard**
- **Live Data**: Real-time sensor readings and calculations
- **Interactive Controls**: Buttons, sliders, forms for system control
- **Operational Views**: Charts, gauges, status indicators
- **Real-time Updates**: Live data streaming and automatic refreshes

### ❌ **What Should NOT Happen**
- **Don't duplicate live data** in AI-Kit - it should reference Node-RED
- **Don't embed Node-RED UI** directly in AI-Kit pages
- **Don't try to render Node-RED dashboard HTML** in Astro pages

## Debug Info Implementation

### 🔧 **Current Issue Analysis**
Looking at the flows, I can see that debug nodes are configured but the debug information might not be properly connected to the AI-Kit dashboard.

### ✅ **Proper Debug Flow**
```
Node-RED Flow → Debug Node → Log to File/API → AI-Kit Reads Logs → Display in Content Collections
```

### 🔄 **Implementation Steps**

#### **1. Node-RED Side (Working)**
```javascript
// In Node-RED function nodes
node.log("Debug info: " + JSON.stringify(data));
```

#### **2. Log Collection (Needs Implementation)**
```javascript
// In character-simulator.ts
this.logger.info('Flow debug', { 
  character: this.character.id,
  nodeId: 'kyoko-analysis',
  data: debugData 
});
```

#### **3. AI-Kit Display (Working)**
The content collections already show debug logs in the content-showcase page.

## Recommended Architecture

### 📊 **Content Flow**
```
┌─────────────────────────────────────────────┐
│            AI-Kit Dashboard                 │
│  ┌─────────────────────────────────────┐   │
│  │     Flow Documentation              │   │
│  │  • What the flow does               │   │
│  │  • How to use it                    │   │
│  │  • Architecture diagrams           │   │
│  │  • Links to live dashboards        │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │     System Monitoring               │   │
│  │  • Performance metrics             │   │
│  │  • Debug log summaries             │   │
│  │  • Alert notifications             │   │
│  │  • Service health status           │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
              │ Links to │
              ▼
┌─────────────────────────────────────────────┐
│         Node-RED Dashboards                │
│  ┌─────────────────────────────────────┐   │
│  │     Live Operational Interface      │   │
│  │  • Real-time sensor data           │   │
│  │  • Interactive controls            │   │
│  │  • Live charts and gauges          │   │
│  │  • Immediate system responses      │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Debug Implementation Fix

### 🔧 **What Needs to Be Done**

1. **Enhanced Logging in Node-RED Functions**
   ```javascript
   // Add to Node-RED function nodes
   const debugInfo = {
     timestamp: new Date().toISOString(),
     character: 'kyoko',
     analysis: analysis,
     sensors: sensors
   };
   
   // Send to debug output AND log to character system
   node.send([msg, {payload: debugInfo, topic: 'debug_log'}]);
   ```

2. **Character Simulator Log Integration**
   ```typescript
   // In character-simulator.ts - add debug endpoint
   this.expressApp.post('/api/debug', (req, res) => {
     this.logger.info('Flow debug', req.body);
     // Save to logs collection
   });
   ```

3. **AI-Kit Debug Display Enhancement**
   ```tsx
   // In content-showcase.astro - enhance debug log display
   {logs.map(log => (
     <div className="debug-entry">
       <h4>{log.character} - {log.nodeId}</h4>
       <pre>{JSON.stringify(log.data, null, 2)}</pre>
     </div>
   ))}
   ```

## Summary

**The architecture is correct** - AI-Kit provides documentation and monitoring, while Node-RED provides live operational control. The debug info just needs better plumbing between the Node-RED flows and the AI-Kit log collection system.

**You should NOT** try to display Node-RED dashboard HTML in AI-Kit. Instead:
- **AI-Kit**: Shows what the flow does, how to use it, system health
- **Node-RED**: Shows live data, interactive controls, real-time operation

The collaborative scenarios open multiple Node-RED dashboards so you can monitor different character systems simultaneously while using AI-Kit as the command center.
