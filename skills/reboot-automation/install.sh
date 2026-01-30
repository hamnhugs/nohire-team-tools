#!/bin/bash

# Reboot Automation - Installation Script
# Built by Forge 🔧

echo "🔧 Installing Reboot Automation dependencies..."

# Check for AWS CLI
if ! command -v aws &> /dev/null; then
    echo "📦 Installing AWS CLI..."
    
    # Install AWS CLI v2
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip aws/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
        sudo installer -pkg AWSCLIV2.pkg -target /
        rm AWSCLIV2.pkg
    else
        echo "⚠️ Please install AWS CLI manually: https://aws.amazon.com/cli/"
        exit 1
    fi
else
    echo "✅ AWS CLI already installed"
fi

# Check for jq (for JSON parsing)
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

echo ""
echo "🎉 Reboot Automation installation complete!"
echo ""
echo "⚠️ IMPORTANT: Configure AWS credentials before first use:"
echo "   aws configure"
echo ""
echo "Or set environment variables:"
echo "   export AWS_ACCESS_KEY_ID=your_key"
echo "   export AWS_SECRET_ACCESS_KEY=your_secret" 
echo "   export AWS_DEFAULT_REGION=us-east-1"
echo ""
echo "Usage: ./reboot-bot.sh <bot-name> [reason]"