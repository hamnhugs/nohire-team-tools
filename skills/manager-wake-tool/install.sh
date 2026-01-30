#!/bin/bash

# Manager Wake Tool - Installation script
echo "🔧 Installing Manager Wake Tool..."

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check dependencies
echo "🔍 Checking dependencies..."

if [[ ! -f "$HOME/.ssh/bot-factory.pem" ]]; then
    echo "❌ SSH key not found: $HOME/.ssh/bot-factory.pem"
    echo "   This tool requires access to bot fleet SSH key"
    exit 1
fi

# Set proper permissions on SSH key
chmod 600 "$HOME/.ssh/bot-factory.pem" 2>/dev/null || true

# Test SSH connectivity to one bot
echo "📡 Testing SSH connectivity..."
if ssh -i "$HOME/.ssh/bot-factory.pem" -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@54.215.71.171 "echo 'SSH test successful'" &>/dev/null; then
    echo "✅ SSH connectivity confirmed"
else
    echo "⚠️ SSH test failed - may need VPN or network access"
fi

# Create convenient aliases
echo "🔗 Setting up command aliases..."

ALIASES="
# Manager Wake Tool aliases
alias wake='$SKILL_DIR/scripts/wake-bot.sh'
alias speedup='$SKILL_DIR/scripts/speedup-team.sh'  
alias cooldown='$SKILL_DIR/scripts/normal-heartbeat.sh'
alias botstatus='$SKILL_DIR/scripts/check-status.sh'
"

# Add to bashrc if not already present
if ! grep -q "Manager Wake Tool aliases" ~/.bashrc 2>/dev/null; then
    echo "$ALIASES" >> ~/.bashrc
    echo "✅ Command aliases added to ~/.bashrc"
else
    echo "✅ Command aliases already configured"
fi

echo ""
echo "🎉 Manager Wake Tool installed successfully!"
echo ""
echo "📋 QUICK COMMANDS:"
echo "   wake forge              # Wake specific bot"
echo "   speedup build-team      # Speed up team for 2h"
echo "   cooldown all           # Reset all to normal"
echo "   botstatus all          # Check all bot health"
echo ""
echo "💡 Run 'source ~/.bashrc' to activate aliases"
echo "📖 See SKILL.md for full documentation"