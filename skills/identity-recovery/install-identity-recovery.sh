#!/bin/bash

# IDENTITY RECOVERY SKILL - Installation Script  
# Install the anti-amnesia system for session reset recovery
# Built by Forge for NoHire team

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-/home/ubuntu/clawd}"

echo "🧠 Installing Identity Recovery Skill - Anti-Amnesia System"

# Check dependencies
echo "🔍 Checking dependencies..."

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "📦 Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Check if clawdbot is available
if ! command -v clawdbot &> /dev/null; then
    echo "⚠️ WARNING: clawdbot not found in PATH"
    echo "Identity recovery will work but Discord alerts may not function"
fi

echo "✅ Dependencies checked"

# Make scripts executable
echo "🔧 Setting up permissions..."
chmod +x "$SCRIPT_DIR/whoami.sh"
chmod +x "$SCRIPT_DIR/identity-startup-hook.sh"
chmod +x "$SCRIPT_DIR/update-heartbeat-for-identity.sh"

# Create required directories
echo "📁 Creating directories..."
mkdir -p ~/.clawdbot
mkdir -p "$WORKSPACE_DIR/memory"

# Install identity recovery script in workspace
echo "📋 Installing identity recovery script..."
cp "$SCRIPT_DIR/whoami.sh" "$WORKSPACE_DIR/"

# Install startup hook
echo "🚀 Installing startup hook..."
cp "$SCRIPT_DIR/identity-startup-hook.sh" "$WORKSPACE_DIR/"

# Update HEARTBEAT.md with identity checks
echo "💓 Updating heartbeat configuration..."
if [[ -f "$SCRIPT_DIR/update-heartbeat-for-identity.sh" ]]; then
    "$SCRIPT_DIR/update-heartbeat-for-identity.sh"
fi

# Add aliases for easy access
echo "🔗 Adding command aliases..."
BASH_ALIASES_FILE="$HOME/.bash_aliases"

# Create bash aliases if not already present
if ! grep -q "alias whoami=" "$BASH_ALIASES_FILE" 2>/dev/null; then
    echo "# Identity Recovery Commands" >> "$BASH_ALIASES_FILE"
    echo "alias whoami='$WORKSPACE_DIR/whoami.sh whoami'" >> "$BASH_ALIASES_FILE"
    echo "alias recover='$WORKSPACE_DIR/whoami.sh recover'" >> "$BASH_ALIASES_FILE"
    echo "alias context='$WORKSPACE_DIR/whoami.sh context'" >> "$BASH_ALIASES_FILE"
    echo "✅ Added identity recovery aliases"
    echo "   Run 'source ~/.bash_aliases' to activate"
fi

# Create startup script integration
echo "⚙️ Setting up startup integration..."

# Add to bashrc if not already present
if ! grep -q "identity-startup-hook.sh" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Identity Recovery - Auto-check on startup" >> ~/.bashrc
    echo "if [[ -f \"$WORKSPACE_DIR/identity-startup-hook.sh\" ]]; then" >> ~/.bashrc
    echo "    source \"$WORKSPACE_DIR/identity-startup-hook.sh\"" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "✅ Added startup hook to ~/.bashrc"
fi

# Test the installation
echo "🧪 Testing identity recovery system..."

# Test the whoami script
if "$WORKSPACE_DIR/whoami.sh" check; then
    echo "✅ Identity recovery script working"
else
    echo "⚠️ Identity recovery test warning (may be normal if identity files need setup)"
fi

# Test the startup hook
if "$WORKSPACE_DIR/identity-startup-hook.sh"; then
    echo "✅ Startup hook working"
else
    echo "⚠️ Startup hook test warning"
fi

# Create initial session state
echo "📊 Initializing session state..."
mkdir -p ~/.clawdbot
cat > ~/.clawdbot/session-state.json << EOF
{
    "last_update": $(date +%s),
    "installation_time": $(date +%s),
    "recovery_system_version": "1.0",
    "reset_detected": false,
    "recovery_triggered": false
}
EOF

echo ""
echo "🎉 IDENTITY RECOVERY INSTALLATION COMPLETE!"
echo ""
echo "📋 AVAILABLE COMMANDS:"
echo "   whoami         Check your identity after session reset"
echo "   recover        Full identity recovery (recommended after amnesia)"
echo "   context        Show current identity and recent memory"
echo ""
echo "🤖 AUTOMATIC FEATURES:"
echo "   ✅ Startup hook detects session resets"
echo "   ✅ Heartbeat includes identity checks" 
echo "   ✅ Manual recovery commands available"
echo "   ✅ Discord alerts for recovery events"
echo ""
echo "🧠 USAGE:"
echo "   If you ever feel confused about who you are:"
echo "   1. Run: recover"
echo "   2. Read the files it shows you"
echo "   3. Confirm your identity and continue working"
echo ""
echo "✅ Anti-amnesia system active! No more session reset confusion."