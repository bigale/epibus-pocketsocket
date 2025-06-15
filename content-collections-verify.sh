#!/bin/bash

# 🎯 Final Verification Script for Content Collections
# Validates that all components are working correctly

echo "🎯 AI-Kit Content Collections Final Verification"
echo "==============================================="
echo ""

# Check Astro server
echo "🌐 Testing Astro Server..."
if curl -s http://localhost:3000/ > /dev/null; then
    echo "   ✅ Main dashboard accessible"
else
    echo "   ❌ Main dashboard not accessible"
    exit 1
fi

# Check content showcase
echo "📊 Testing Content Showcase..."
if curl -s http://localhost:3000/content-showcase | grep -q "Content Collections"; then
    echo "   ✅ Content showcase page working"
else
    echo "   ❌ Content showcase page not working"
    exit 1
fi

# Check content files
echo "📁 Checking Content Files..."
CONTENT_DIR="/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/astro-host/src/content"

FLOWS=$(find "$CONTENT_DIR/node-red-flows" -name "*.md" | wc -l)
LOGS=$(find "$CONTENT_DIR/simulator-logs" -name "*.json" | wc -l)
ALERTS=$(find "$CONTENT_DIR/industrial-alerts" -name "*.json" | wc -l)
METRICS=$(find "$CONTENT_DIR/performance-metrics" -name "*.json" | wc -l)

echo "   📋 Node-RED Flows: $FLOWS files"
echo "   📊 Simulator Logs: $LOGS files"
echo "   🚨 Industrial Alerts: $ALERTS files"
echo "   ⚡ Performance Metrics: $METRICS files"

if [[ $FLOWS -gt 0 && $LOGS -gt 0 && $ALERTS -gt 0 && $METRICS -gt 0 ]]; then
    echo "   ✅ All content types have files"
else
    echo "   ⚠️  Some content types are missing files"
fi

# Validate JSON files
echo "🔍 Validating JSON Content..."
JSON_VALID=0
JSON_TOTAL=0

for json_file in "$CONTENT_DIR"/*/*.json; do
    if [[ -f "$json_file" ]]; then
        JSON_TOTAL=$((JSON_TOTAL + 1))
        if jq empty "$json_file" 2>/dev/null; then
            JSON_VALID=$((JSON_VALID + 1))
        else
            echo "   ❌ Invalid JSON: $json_file"
        fi
    fi
done

echo "   📊 JSON Files: $JSON_VALID/$JSON_TOTAL valid"

# Check markdown frontmatter
echo "📝 Checking Markdown Frontmatter..."
MD_VALID=0
MD_TOTAL=0

for md_file in "$CONTENT_DIR"/node-red-flows/*.md; do
    if [[ -f "$md_file" ]]; then
        MD_TOTAL=$((MD_TOTAL + 1))
        if grep -q "lastUpdated:" "$md_file" && grep -q "character:" "$md_file"; then
            MD_VALID=$((MD_VALID + 1))
        else
            echo "   ❌ Invalid frontmatter: $md_file"
        fi
    fi
done

echo "   📋 Markdown Files: $MD_VALID/$MD_TOTAL valid"

# Check simulator status
echo "🏭 Checking Simulators..."
cd "/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator"
STATUS=$(./scripts/status.sh 2>/dev/null | grep "Summary:" | head -1)
echo "   $STATUS"

# Final summary
echo ""
echo "🎉 Verification Complete!"
echo "========================="

if [[ $JSON_VALID -eq $JSON_TOTAL && $MD_VALID -eq $MD_TOTAL ]]; then
    echo "✅ All content collections are working perfectly!"
    echo "🌐 Content Showcase: http://localhost:3000/content-showcase"
    echo "📊 Main Dashboard: http://localhost:3000"
    echo ""
    echo "🚀 System Status: FULLY OPERATIONAL"
else
    echo "⚠️  Some content validation issues found"
    echo "🔧 System Status: NEEDS ATTENTION"
fi

echo ""
echo "📚 Available Features:"
echo "   • Real-time log harvesting from Node-RED simulators"
echo "   • Automated content generation with character theming"
echo "   • Beautiful web interface with tabbed content browsing"
echo "   • Individual flow documentation pages"
echo "   • Performance metrics and industrial alerts"
echo "   • Type-safe content collections with Astro"
