#!/bin/bash

# Token-Efficient Messaging - Installation Script
# Built by Forge 🔧

echo "🔧 Installing Token-Efficient Messaging tools..."

# Check for jq (required for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "📦 Installing jq..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        echo "⚠️ Please install jq manually"
        exit 1
    fi
else
    echo "✅ jq already installed"
fi

# Check for curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl is required but not installed"
    exit 1
else
    echo "✅ curl available"
fi

echo ""
echo "🎉 Token-Efficient Messaging installation complete!"
echo ""
echo "Available tools:"
echo "  ./check-unread.sh <bot-name>     - Check unread message count"
echo "  ./team-status.sh                 - Team-wide message dashboard" 
echo ""
echo "Examples:"
echo "  ./check-unread.sh forge"
echo "  ./team-status.sh --alerts-only"
echo "  ./team-status.sh --bot artdesign"