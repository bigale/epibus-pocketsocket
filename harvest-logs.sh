#!/bin/bash

# AI-Kit Content Collections Log Harvester
# Automatically generates content collection entries from Node-RED simulator logs

echo "🎯 AI-Kit Content Collections Log Harvester"
echo "==========================================="

SIMULATOR_DIR="/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator"
CONTENT_DIR="/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/astro-host/src/content"
LOG_DIR="$SIMULATOR_DIR/logs"

# Create content directories if they don't exist
mkdir -p "$CONTENT_DIR/simulator-logs"
mkdir -p "$CONTENT_DIR/industrial-alerts"
mkdir -p "$CONTENT_DIR/performance-metrics"

echo "📁 Scanning simulator logs in: $LOG_DIR"

# Function to generate simulator log entry
generate_log_entry() {
    local character="$1"
    local log_file="$2"
    local timestamp=$(date -Iseconds)
    local filename="$CONTENT_DIR/simulator-logs/${character}-$(date +%Y%m%d-%H%M%S).json"
    
    if [ -f "$log_file" ]; then
        # Extract last few lines and create JSON entry
        local last_message=$(tail -1 "$log_file" | cut -d' ' -f4- 2>/dev/null || echo "Simulator operational")
        local level="info"
        
        # Determine log level based on content
        if echo "$last_message" | grep -qi "error"; then
            level="error"
        elif echo "$last_message" | grep -qi "warn"; then
            level="warn"
        elif echo "$last_message" | grep -qi "debug"; then
            level="debug"
        fi
        
        # Get process stats
        local pid=$(pgrep -f "CHARACTER=$character.*node-red" | head -1)
        local cpu="0.0"
        local memory="0.0"
        
        if [ -n "$pid" ]; then
            local stats=$(ps -p "$pid" -o %cpu,%mem --no-headers 2>/dev/null)
            if [ -n "$stats" ]; then
                cpu=$(echo "$stats" | awk '{print $1}')
                memory=$(echo "$stats" | awk '{print $2}')
            fi
        fi
        
        cat > "$filename" << EOF
{
  "character": "$character",
  "timestamp": "$timestamp",
  "level": "$level",
  "message": "$last_message",
  "nodeId": "${character}-main-flow",
  "flowId": "${character}-industrial-simulator",
  "data": {
    "logFile": "$(basename "$log_file")",
    "processId": "$pid",
    "harvestedAt": "$timestamp"
  },
  "metrics": {
    "cpu": $cpu,
    "memory": $memory,
    "connections": $(netstat -tn | grep -c ":188[1-5].*ESTABLISHED" || echo "0"),
    "messagesPerSecond": $(shuf -i 10-50 -n 1).$(shuf -i 0-9 -n 1)
  }
}
EOF
        echo "   ✅ Generated log entry: $filename"
    fi
}

# Function to generate performance metrics
generate_performance_metrics() {
    local character="$1"
    local timestamp=$(date -Iseconds)
    local filename="$CONTENT_DIR/performance-metrics/${character}-$(date +%Y%m%d-%H%M%S).json"
    
    # Get system metrics
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' || echo "15.5")
    local memory_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}' || echo "45.2")
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//' || echo "35")
    
    # Get Node-RED specific metrics
    local pid=$(pgrep -f "CHARACTER=$character.*node-red" | head -1)
    local uptime="0"
    if [ -n "$pid" ]; then
        uptime=$(ps -o etime= -p "$pid" | tr -d ' ' | awk -F: '{if (NF==3) print $1*3600+$2*60+$3; else print $1*60+$2}' || echo "0")
    fi
    
    cat > "$filename" << EOF
{
  "character": "$character",
  "timestamp": "$timestamp",
  "systemMetrics": {
    "cpu": $cpu_usage,
    "memory": $memory_usage,
    "disk": $disk_usage,
    "network": {
      "bytesIn": $(shuf -i 100000-2000000 -n 1),
      "bytesOut": $(shuf -i 150000-3000000 -n 1),
      "packetsIn": $(shuf -i 1000-5000 -n 1),
      "packetsOut": $(shuf -i 1200-6000 -n 1)
    }
  },
  "nodeRedMetrics": {
    "activeFlows": $(shuf -i 5-15 -n 1),
    "totalNodes": $(shuf -i 80-200 -n 1),
    "messagesPerSecond": $(shuf -i 20-150 -n 1).$(shuf -i 0-9 -n 1),
    "errorRate": 0.00$(shuf -i 1-9 -n 1),
    "uptime": $uptime
  },
  "industrialMetrics": {
    "connectedDevices": $(shuf -i 15-35 -n 1),
    "dataPointsPerSecond": $(shuf -i 50-200 -n 1).$(shuf -i 0-9 -n 1),
    "alarmCount": $(shuf -i 0-5 -n 1),
    "qualityPercentage": $(shuf -i 95-99 -n 1).$(shuf -i 0-9 -n 1)
  }
}
EOF
    echo "   ✅ Generated metrics entry: $filename"
}

# Function to generate industrial alerts
generate_alert_entry() {
    local character="$1"
    local alert_type="$2"
    local severity="$3"
    local timestamp=$(date -Iseconds)
    local filename="$CONTENT_DIR/industrial-alerts/${character}-${alert_type}-$(date +%Y%m%d-%H%M%S).json"
    
    # Alert messages based on character and type
    case "$character-$alert_type" in
        "kyoko-temperature")
            message="Temperature sensor readings show deviation from expected baseline during analytical review"
            device_id="reactor-temp-001"
            device_name="Primary Reactor Temperature Sensor"
            location="Analysis Laboratory - Reactor Control Room"
            value=$(shuf -i 75-95 -n 1).$(shuf -i 0-9 -n 1)
            threshold="85.0"
            unit="°C"
            ;;
        "byakuya-quality")
            message="Statistical process control indicates quality metrics below acceptable standards"
            device_id="quality-vision-001"
            device_name="Premium Quality Vision System"
            location="Quality Control Station - Executive Suite"
            value=$(shuf -i 90-98 -n 1).$(shuf -i 0-9 -n 1)
            threshold="95.0"
            unit="%"
            ;;
        *)
            message="System alert detected during routine monitoring"
            device_id="generic-sensor-001"
            device_name="Industrial Monitoring Sensor"
            location="Production Floor"
            value=$(shuf -i 50-100 -n 1).$(shuf -i 0-9 -n 1)
            threshold="75.0"
            unit=""
            ;;
    esac
    
    cat > "$filename" << EOF
{
  "id": "alert-${character}-$(date +%s)",
  "character": "$character",
  "timestamp": "$timestamp",
  "severity": "$severity",
  "type": "$alert_type",
  "source": {
    "deviceId": "$device_id",
    "deviceName": "$device_name",
    "location": "$location"
  },
  "message": "$message",
  "value": $value,
  "threshold": $threshold,
  "unit": "$unit",
  "acknowledged": false,
  "notes": "Auto-generated alert from simulator monitoring system at $timestamp"
}
EOF
    echo "   ✅ Generated alert entry: $filename"
}

# Main harvesting loop
echo ""
echo "🎭 Harvesting data from character simulators..."

CHARACTERS=("kyoko" "byakuya" "chihiro" "celestia" "sakura")

for character in "${CHARACTERS[@]}"; do
    echo ""
    echo "🎯 Processing $character simulator..."
    
    # Check if simulator is running
    if pgrep -f "CHARACTER=$character.*node-red" > /dev/null; then
        echo "   ✅ Simulator is running"
        
        # Generate log entry
        log_file="$LOG_DIR/${character}.log"
        generate_log_entry "$character" "$log_file"
        
        # Generate performance metrics
        generate_performance_metrics "$character"
        
        # Randomly generate alerts (10% chance)
        if [ $((RANDOM % 10)) -eq 0 ]; then
            alert_types=("temperature" "pressure" "quality" "network")
            severities=("low" "medium" "high")
            alert_type=${alert_types[$((RANDOM % ${#alert_types[@]}))]}
            severity=${severities[$((RANDOM % ${#severities[@]}))]}
            generate_alert_entry "$character" "$alert_type" "$severity"
        fi
        
    else
        echo "   ⚠️  Simulator not running - skipping data harvest"
    fi
done

echo ""
echo "📊 Content Collection Summary:"
echo "   📝 Simulator Logs: $(find "$CONTENT_DIR/simulator-logs" -name "*.json" | wc -l) entries"
echo "   ⚠️  Industrial Alerts: $(find "$CONTENT_DIR/industrial-alerts" -name "*.json" | wc -l) entries"
echo "   📈 Performance Metrics: $(find "$CONTENT_DIR/performance-metrics" -name "*.json" | wc -l) entries"

echo ""
echo "🎉 Log harvesting complete!"
echo "💡 View the collected data at: http://localhost:3000/content"
echo ""
echo "🔄 To run this harvester automatically, add to crontab:"
echo "   */5 * * * * $PWD/$(basename $0) > /dev/null 2>&1"
