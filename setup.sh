#!/bin/bash

# 🏭⚡ EpiBus-PocketSocket Industrial IoT Setup Script
# Sets up all packages and dependencies for the AI-Kit Industrial IoT Platform

set -e

echo "🏭⚡ Setting up EpiBus-PocketSocket Industrial IoT Platform..."
echo ""

# Function to install packages in a directory
install_package() {
    local dir=$1
    local name=$2
    
    echo "📦 Installing $name..."
    cd "$dir"
    npm install
    cd - > /dev/null
    echo "✅ $name installed successfully"
    echo ""
}

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install
echo "✅ Root dependencies installed successfully"
echo ""

# Install each subpackage
install_package "pocketsocket-plc" "PocketSocket PLC Engine"
install_package "universal-plc-adapter" "Universal PLC Adapter"
install_package "suil-industrial" "SUIL Industrial AI"
install_package "character-agents" "Character Agents"
install_package "astro-host" "Astro-Host Dashboard"

echo "🎉 All packages installed successfully!"
echo ""
echo "🚀 To start the development environment:"
echo "   npm run dev"
echo ""
echo "🎭 To start with a specific character:"
echo "   npm run start:kyoko"
echo "   npm run start:byakuya" 
echo "   npm run start:chihiro"
echo "   npm run start:celestia"
echo "   npm run start:sakura"
echo ""
echo "📖 See README.md for more details"
