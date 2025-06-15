---
title: "Industrial Temperature Monitoring Flow"
character: "kyoko"
description: "A comprehensive flow for monitoring reactor temperatures with automatic alarm generation and data logging. This flow demonstrates Kyoko's analytical approach to industrial process control."
version: "2.1.0"
tags: ["temperature", "monitoring", "alarms", "modbus", "database"]
difficulty: "intermediate"
lastUpdated: "2025-06-14T19:00:00Z"
author: "Kyoko Kirigiri"
flowId: "temp-monitor-001"
nodes:
  - id: "modbus-read-1"
    type: "modbus-read"
    name: "Reactor Temp Reader"
    description: "Reads temperature from reactor sensor via Modbus TCP"
  - id: "function-1"
    type: "function"
    name: "Temperature Processor"
    description: "Processes raw temperature data and applies calibration"
  - id: "switch-1"
    type: "switch"
    name: "Alarm Logic"
    description: "Routes messages based on temperature thresholds"
  - id: "sqlite-1"
    type: "sqlite"
    name: "Data Logger"
    description: "Stores temperature readings in local database"
  - id: "ui-chart-1"
    type: "ui-chart"
    name: "Temperature Chart"
    description: "Real-time temperature visualization"
inputPorts:
  - name: "trigger"
    type: "inject"
    description: "Timer trigger for periodic temperature readings"
outputPorts:
  - name: "temperature-data"
    type: "object"
    description: "Processed temperature data with timestamp"
  - name: "alarm-output"
    type: "object"
    description: "Alarm messages when thresholds are exceeded"
configuration:
  modbusServer: "192.168.1.100"
  modbusPort: 502
  tempRegister: 100
  normalRange: [20, 80]
  warningRange: [80, 90]
  criticalThreshold: 90
  sampleInterval: 5000
---

# Industrial Temperature Monitoring Flow

This Node-RED flow implements a robust temperature monitoring system designed by **Kyoko Kirigiri** for industrial reactor control. The flow combines her analytical precision with practical industrial automation needs.

## Flow Overview

The temperature monitoring flow demonstrates several key industrial IoT concepts:

- **Real-time Data Acquisition**: Continuous polling of Modbus temperature sensors
- **Data Processing**: Calibration and validation of sensor readings
- **Intelligent Alarming**: Multi-level threshold monitoring with automated responses
- **Data Persistence**: Historical logging for trend analysis and compliance
- **Visualization**: Real-time dashboards for operators

## Character Implementation Notes

As befitting Kyoko's methodical nature, this flow prioritizes:

- **Accuracy**: Multiple validation steps ensure data integrity
- **Reliability**: Error handling and failover mechanisms
- **Analysis**: Historical data collection for pattern recognition
- **Documentation**: Comprehensive logging of all events

## Technical Details

### Modbus Configuration
```javascript
// Temperature sensor configuration
const sensorConfig = {
    server: "192.168.1.100",
    port: 502,
    register: 100,
    dataType: "int16",
    scaling: 0.1
};
```

### Alarm Logic
The flow implements a three-tier alarm system:

1. **Normal Operation** (20-80°C): Green status, regular logging
2. **Warning Level** (80-90°C): Yellow status, increased monitoring
3. **Critical Level** (>90°C): Red status, immediate operator notification

### Data Processing Function
```javascript
// Temperature calibration and validation
const processTemperature = (rawValue) => {
    // Apply calibration offset
    let temp = rawValue * 0.1 - 2.0;
    
    // Validate reading
    if (temp < -50 || temp > 200) {
        throw new Error("Temperature reading out of valid range");
    }
    
    return {
        timestamp: Date.now(),
        temperature: temp,
        unit: "°C",
        quality: "good",
        source: "reactor-001"
    };
};
```

## Installation and Usage

1. **Import the Flow**: Copy the flow JSON from the examples directory
2. **Configure Modbus**: Update the Modbus server settings for your environment
3. **Set Database Path**: Configure the SQLite database location
4. **Deploy**: Deploy the flow and verify connections
5. **Monitor**: Access the dashboard at `/ui` to view real-time data

## Dashboard Features

The temperature monitoring dashboard includes:

- **Real-time Temperature Chart**: Live trend display with configurable time ranges
- **Current Status**: Large display showing current temperature and status
- **Alarm History**: List of recent alarms with timestamps and severity
- **System Health**: Connection status and data quality indicators

## Integration with AI-Kit

This flow integrates seamlessly with the AI-Kit character system:

- **Character Context**: Kyoko's analytical personality influences alarm sensitivity
- **Theme Integration**: UI colors and styling match Kyoko's purple theme
- **Behavior Patterns**: Error handling reflects Kyoko's methodical approach
- **Documentation Style**: Technical precision with detective-like attention to detail

## Troubleshooting

### Common Issues

**Connection Errors**: Verify Modbus server IP and port configuration
**Data Quality Issues**: Check sensor wiring and calibration settings
**Missing Data**: Ensure database permissions and disk space
**UI Not Loading**: Verify Node-RED dashboard is properly configured

### Debug Mode

Enable debug mode by uncommenting the debug nodes in the flow. This provides detailed logging of:

- Raw Modbus readings
- Processed temperature values
- Alarm trigger events
- Database write operations

## Related Flows

- **Quality Control Integration**: Links with Byakuya's quality monitoring
- **Safety System**: Interfaces with Sakura's emergency response flows
- **Environmental Control**: Coordinates with Celestia's HVAC management

---

*This flow documentation is maintained by the AI-Kit Industrial IoT team and follows Kyoko's standards for technical precision and analytical rigor.*
