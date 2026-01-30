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
SUBNET_ID="subnet-0123456789abcdef0"  # Update with actual subnet

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
    watchdog-bot.js package.json watchdog.service \
    ubuntu@$PUBLIC_IP:~/

# Configure and start Watchdog
echo "🔧 Configuring Watchdog service..."

# Discord token (must be set in environment)
if [ -z "$DISCORD_TOKEN" ]; then
    echo "❌ ERROR: DISCORD_TOKEN environment variable required"
    echo "Set with: export DISCORD_TOKEN='your_discord_token'"
    exit 1
fi

ssh -i ~/.ssh/$KEY_NAME.pem -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP << EOF
    # Create watchdog directory
    mkdir -p ~/watchdog
    mv watchdog-bot.js package.json ~/watchdog/
    
    # Configure Discord token in Clawdbot config
    sed -i 's/DISCORD_TOKEN_PLACEHOLDER/${DISCORD_TOKEN}/' ~/.clawdbot/clawdbot.json
    
    # Install as systemd service
    sudo mv watchdog.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable watchdog
    sudo systemctl start watchdog
    
    # Check status
    sleep 5
    sudo systemctl status watchdog
EOF

echo "🐕 WATCHDOG BOT DEPLOYMENT COMPLETE!"
echo ""
echo "📊 Instance Details:"
echo "   Instance ID: $INSTANCE_ID"
echo "   Public IP: $PUBLIC_IP"
echo "   SSH Access: ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo ""
echo "🔧 Management Commands:"
echo "   Status: ssh ubuntu@$PUBLIC_IP 'sudo systemctl status watchdog'"
echo "   Logs: ssh ubuntu@$PUBLIC_IP 'sudo journalctl -u watchdog -f'"
echo "   Restart: ssh ubuntu@$PUBLIC_IP 'sudo systemctl restart watchdog'"
echo ""
echo "✅ Watchdog is now monitoring the team bot fleet!"