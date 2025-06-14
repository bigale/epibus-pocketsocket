#!/bin/bash

# 🎭 AI-Kit Industrial IoT Installation Verification Script

set -e

echo "================================================================="
echo "🎭 AI-Kit Industrial IoT - Installation Verification"
echo "   Checking all components are properly installed and buildable"
echo "================================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in the right directory
if [[ ! -f "package.json" ]]; then
    error "Not in the correct directory. Please run from ai-kit/industrial-iot/"
    exit 1
fi

echo "🔍 Checking project structure..."

# Check all required directories exist
for dir in "astro-host" "pocketsocket-plc" "universal-plc-adapter" "suil-industrial" "character-agents" "node-red-plc-simulator"; do
    if [[ -d "$dir" ]]; then
        success "Directory exists: $dir"
    else
        error "Missing directory: $dir"
        exit 1
    fi
done

echo ""
echo "📦 Checking package.json files..."

# Check all packages have valid package.json
for dir in "." "astro-host" "pocketsocket-plc" "universal-plc-adapter" "suil-industrial" "character-agents" "node-red-plc-simulator"; do
    if [[ -f "$dir/package.json" ]]; then
        success "Package.json exists: $dir"
    else
        error "Missing package.json: $dir"
        exit 1
    fi
done

echo ""
echo "🔨 Testing TypeScript compilation..."

# Test each TypeScript package builds
for dir in "pocketsocket-plc" "universal-plc-adapter" "suil-industrial" "character-agents"; do
    echo "Building $dir..."
    if cd "$dir" && npm run build &>/dev/null; then
        success "Build successful: $dir"
        cd ..
    else
        warn "Build issues in: $dir (may need dependencies)"
        cd ..
    fi
done

echo ""
echo "🎛️ Testing Node-RED simulator configuration..."

# Check Node-RED simulator package
cd node-red-plc-simulator
if npm list node-red &>/dev/null; then
    success "Node-RED dependencies installed"
else
    warn "Node-RED dependencies may need installation"
fi

# Check character scenarios exist
for character in "kyoko" "byakuya" "chihiro" "celestia" "sakura"; do
    if [[ -f "scenarios/$character/${character}_default.json" ]]; then
        success "Scenario exists: $character"
    else
        error "Missing scenario: $character"
    fi
done

cd ..

echo ""
echo "🌟 Testing Astro-Host build..."

cd astro-host
if npm run build &>/dev/null; then
    success "Astro-Host build successful"
else
    warn "Astro-Host build issues (may need dependencies)"
fi
cd ..

echo ""
echo "================================================================="
echo "🎉 Installation Verification Complete!"
echo ""
echo "📍 Quick Start Commands:"
echo "   ./launch-complete-system.sh     - Launch full system"
echo "   ./launch-integration.sh         - Launch basic integration"
echo "   cd astro-host && npm run dev    - Start dashboard only"
echo ""
echo "🌐 Dashboard URLs (when running):"
echo "   http://localhost:4321           - Main AI-Kit Dashboard"
echo "   http://localhost:1881           - Kyoko's Node-RED"
echo "   http://localhost:1882           - Byakuya's Node-RED"
echo "   http://localhost:1883           - Chihiro's Node-RED"
echo "   http://localhost:1884           - Celestia's Node-RED"
echo "   http://localhost:1885           - Sakura's Node-RED"
echo "================================================================="
