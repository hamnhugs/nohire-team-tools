#!/bin/bash

# WATCHDOG BOT - EC2 Bootstrap Script
# Prepares the instance for Watchdog bot deployment

set -e

echo "🐕 BOOTSTRAPPING WATCHDOG BOT INSTANCE"

# Update system
apt-get update
apt-get install -y curl git unzip htop

# Install Node.js via nvm (same version as other bots)
su - ubuntu -c "
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    source ~/.bashrc
    nvm install v24.13.0
    nvm use v24.13.0
    nvm alias default v24.13.0
"

# Install Clawdbot
su - ubuntu -c "
    source ~/.bashrc
    npm install -g clawdbot@latest
"

# Set up SSH key for bot access
su - ubuntu -c "
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
"

# Create placeholder SSH key (will be replaced during deployment)
cat > /home/ubuntu/.ssh/bot-factory.pem << 'EOF'
# SSH key will be copied here during deployment
EOF
chmod 600 /home/ubuntu/.ssh/bot-factory.pem
chown ubuntu:ubuntu /home/ubuntu/.ssh/bot-factory.pem

# Configure Clawdbot for Watchdog bot
su - ubuntu -c "
    mkdir -p ~/.clawdbot
"

# Create basic Clawdbot config for Watchdog (Discord token will be added during deployment)
cat > /home/ubuntu/.clawdbot/clawdbot.json << 'EOF'
{
  \"agents\": {
    \"defaults\": {
      \"model\": {
        \"primary\": \"anthropic/claude-sonnet-4-20250514\"
      },
      \"workspace\": \"/home/ubuntu/watchdog\"
    }
  },
  \"channels\": {
    \"discord\": {
      \"enabled\": true,
      \"token\": \"DISCORD_TOKEN_PLACEHOLDER\",
      \"groupPolicy\": \"allowlist\",
      \"dm\": {
        \"policy\": \"allowlist\"
      },
      \"guilds\": {
        \"1466818873390272677\": {
          \"requireMention\": true,
          \"channels\": {
            \"1466825803512942813\": {
              \"enabled\": true
            }
          }
        }
      }
    }
  },
  \"tools\": {
    \"message\": {
      \"crossContext\": {
        \"allowWithinProvider\": true,
        \"allowAcrossProviders\": true
      }
    }
  },
  \"gateway\": {
    \"port\": 18789
  }
}
EOF
chown ubuntu:ubuntu /home/ubuntu/.clawdbot/clawdbot.json

# Open required ports in local firewall (if needed)
ufw allow 18789 # Clawdbot gateway
ufw allow 47823 # Mesh network

echo "✅ WATCHDOG BOT BOOTSTRAP COMPLETE"
echo "📊 Node.js version: $(su - ubuntu -c 'node --version')"
echo "🤖 Clawdbot version: $(su - ubuntu -c 'clawdbot --version')"
echo "🔧 Ready for Watchdog deployment"