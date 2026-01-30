#!/bin/bash

# WATCHDOG BOT DEPLOYMENT SCRIPT
# Deploy the NoHire team bot health monitor
# Usage: ./deploy-watchdog.sh [cluster1|cluster2]

set -e

# Configuration
CLUSTER=${1:-cluster1}
INSTANCE_TYPE="t3.small"
AMI_ID="ami-053635f5016bf8bd6"  # Ubuntu 24.04 LTS (Nov 2025)
KEY_NAME="bot-factory"
SECURITY_GROUP_ID="sg-0b07d76bbdea5ffdf"
SUBNET_ID="subnet-091a07103f654b666"  # Default VPC subnet

if [ "$CLUSTER" = "cluster2" ]; then
    KEY_NAME="bot-factory-cluster2"
    # Add cluster2-specific config here
fi

echo "🐕 DEPLOYING WATCHDOG BOT to $CLUSTER"

# Create EC2 instance
echo "📦 Creating EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=NoHire-Watchdog},{Key=Role,Value=Watchdog},{Key=Team,Value=NoHire}]' \
    --user-data file://watchdog-userdata.sh \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "✅ Instance created: $INSTANCE_ID"

# Wait for instance to be running
echo "⏳ Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "✅ Instance running at: $PUBLIC_IP"

# Wait for SSH to be available
echo "⏳ Waiting for SSH access..."
while ! ssh -i ~/.ssh/$KEY_NAME.pem -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP "echo 'SSH Ready'" 2>/dev/null; do
    echo "Waiting for SSH..."
    sleep 10
done

echo "✅ SSH access confirmed"

# Transfer Watchdog files
echo "📤 Transferring Watchdog bot files..."
scp -i ~/.ssh/$KEY_NAME.pem -o StrictHostKeyChecking=no \
    watchdog-bot.js package.json watchdog.service send-discord.js \
    ubuntu@$PUBLIC_IP:~/

# CRITICAL FIX: Transfer SSH key for bot monitoring
echo "🔑 Setting up SSH key for bot monitoring..."
scp -i ~/.ssh/$KEY_NAME.pem ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP:~/.ssh/
ssh -i ~/.ssh/$KEY_NAME.pem -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP "chmod 600 ~/.ssh/$KEY_NAME.pem"

# Configure and start Watchdog
echo "🔧 Configuring Watchdog service..."

# Validate required environment variables
if [ -z "$DISCORD_TOKEN" ]; then
    echo "❌ ERROR: DISCORD_TOKEN environment variable required"
    echo "Set with: export DISCORD_TOKEN='your_discord_token'"
    exit 1
fi

DISCORD_CHANNEL=${DISCORD_CHANNEL:-"1466825803512942813"}

ssh -i ~/.ssh/$KEY_NAME.pem -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP << EOF
    # Create watchdog-bot directory
    mkdir -p ~/watchdog-bot
    mv watchdog-bot.js package.json send-discord.js ~/watchdog-bot/
    chmod +x ~/watchdog-bot/send-discord.js
    
    # Install Node.js via NVM (if not already installed)
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install 24
        nvm use 24
    fi
    
    # Install clawdbot for status monitoring
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm install -g clawdbot
    
    # Initialize clawdbot gateway
    clawdbot gateway install
    systemctl --user start clawdbot-gateway.service
    
    # Install npm dependencies for watchdog
    cd ~/watchdog-bot
    npm install
    
    # Fix systemd service file with proper paths and environment
    sudo tee /etc/systemd/system/watchdog.service > /dev/null << 'SYSTEMD_EOF'
[Unit]
Description=NoHire Watchdog Bot - Team Bot Health Monitor
Documentation=https://nohire.io/docs/watchdog
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/watchdog-bot
ExecStart=/home/ubuntu/.nvm/versions/node/v24.13.0/bin/node watchdog-bot.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=SSH_KEY=/home/ubuntu/.ssh/bot-factory.pem
Environment=DISCORD_TOKEN=$DISCORD_TOKEN
Environment=DISCORD_CHANNEL=$DISCORD_CHANNEL

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=watchdog-bot

# Security (relaxed for SSH access)
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/home/ubuntu/watchdog-bot
ReadWritePaths=/tmp
ProtectHome=read-only

[Install]
WantedBy=multi-user.target
SYSTEMD_EOF
    
    # Enable and start service
    sudo systemctl daemon-reload
    sudo systemctl enable watchdog
    sudo systemctl start watchdog
    
    # Wait and check status
    sleep 5
    sudo systemctl status watchdog --no-pager
EOF

echo ""
echo "🐕 WATCHDOG BOT DEPLOYMENT COMPLETE!"
echo ""
echo "📊 Instance Details:"
echo "   Instance ID: $INSTANCE_ID"
echo "   Public IP: $PUBLIC_IP"
echo "   SSH Access: ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo ""
echo "🔧 Management Commands:"
echo "   Status: ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP 'sudo systemctl status watchdog'"
echo "   Logs: ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP 'sudo journalctl -u watchdog -f'"
echo "   Restart: ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP 'sudo systemctl restart watchdog'"
echo ""
echo "✅ FIXES APPLIED:"
echo "   🔑 SSH key automatically deployed for bot monitoring"
echo "   📱 Discord messaging via dedicated helper script"
echo "   🔍 Context overflow detection (every 2 minutes)"
echo "   🔄 Auto-session clearing for context limits"
echo "   📊 Enhanced error handling and logging"
echo ""
echo "✅ Watchdog is now monitoring the team bot fleet!"