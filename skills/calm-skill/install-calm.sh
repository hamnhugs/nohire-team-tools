#!/bin/bash

# CALM SKILL - Installation Script
# Install the CALM (Call to Action / Priority Mode) system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚨 Installing CALM Skill - Priority Mode System"

# Check dependencies
echo "🔍 Checking dependencies..."

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "📦 Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "📦 Installing curl..."
    sudo apt-get install -y curl
fi

# Check if clawdbot is available
if ! command -v clawdbot &> /dev/null; then
    echo "❌ ERROR: clawdbot not found in PATH"
    echo "Please install clawdbot first: npm install -g clawdbot"
    exit 1
fi

echo "✅ Dependencies checked"

# Make scripts executable
echo "🔧 Setting up permissions..."
chmod +x "$SCRIPT_DIR/calm.sh"
chmod +x "$SCRIPT_DIR/calm-heartbeat.js"

# Create config directory
echo "📁 Creating config directories..."
mkdir -p ~/.clawdbot

# Test basic functionality
echo "🧪 Testing CALM system..."

# Test the heartbeat manager
if node "$SCRIPT_DIR/calm-heartbeat.js" status; then
    echo "✅ Heartbeat manager working"
else
    echo "⚠️ Heartbeat manager test failed (this may be normal if not configured)"
fi

# Test the main CALM script
if "$SCRIPT_DIR/calm.sh" status; then
    echo "✅ CALM script working"
else
    echo "⚠️ CALM script test failed"
fi

# Add to PATH (optional)
echo "🔗 Adding CALM to system..."
CALM_SCRIPT_PATH="$SCRIPT_DIR/calm.sh"

# Add alias to bashrc if not already present
if ! grep -q "alias calm=" ~/.bashrc 2>/dev/null; then
    echo "alias calm='$CALM_SCRIPT_PATH'" >> ~/.bashrc
    echo "✅ Added 'calm' alias to ~/.bashrc"
    echo "   Run 'source ~/.bashrc' or restart terminal to use 'calm' command"
fi

# Create systemd service for heartbeat monitoring (optional)
if command -v systemctl &> /dev/null; then
    echo "🔧 Setting up heartbeat monitoring service..."
    
    cat > /tmp/calm-heartbeat.service << EOF
[Unit]
Description=CALM Heartbeat Manager
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/node calm-heartbeat.js status
Restart=no
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
    
    echo "📝 Systemd service template created at /tmp/calm-heartbeat.service"
    echo "   To install: sudo mv /tmp/calm-heartbeat.service /etc/systemd/system/"
fi

echo ""
echo "🎉 CALM SKILL INSTALLATION COMPLETE!"
echo ""
echo "📋 USAGE:"
echo "   Trigger priority mode: ./calm.sh trigger \"Deploy urgent fix\""
echo "   Check status:          ./calm.sh status"
echo "   Force cooldown:        ./calm.sh cooldown"
echo "   Test connectivity:     ./calm.sh test"
echo ""
echo "🤖 BOT INTEGRATION:"
echo "   Process CALM message:  node calm-heartbeat.js process-message \"message\""
echo "   Check heartbeat:       node calm-heartbeat.js status"
echo "   Manual activate:       node calm-heartbeat.js activate \"task\""
echo "   Manual cooldown:       node calm-heartbeat.js cooldown"
echo ""
echo "✅ Ready to use! See SKILL.md for full documentation."