#!/bin/bash

# Manager Wake Tool - Wake specific bot instantly
# Usage: ./wake-bot.sh <bot-name>

set -e

BOT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLEET_REF="$SCRIPT_DIR/../references/bot-fleet.md"

if [[ -z "$BOT_NAME" ]]; then
    echo "❌ Usage: $0 <bot-name>"
    echo "Available bots: dan, forge, forge-jr, artdesign, marketer, franky"
    exit 1
fi

# Bot IP mappings (from fleet reference)
declare -A BOT_IPS=(
    ["dan"]="54.215.71.171"
    ["forge"]="18.144.25.135" 
    ["forge-jr"]="54.193.122.20"
    ["artdesign"]="54.215.251.55"
    ["marketer"]="50.18.68.16"
    ["franky"]="18.144.174.205"
)

BOT_IP="${BOT_IPS[$BOT_NAME]}"

if [[ -z "$BOT_IP" ]]; then
    echo "❌ Unknown bot: $BOT_NAME"
    echo "Available bots: ${!BOT_IPS[@]}"
    exit 1
fi

SSH_KEY="$HOME/.ssh/bot-factory.pem"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "❌ SSH key not found: $SSH_KEY"
    exit 1
fi

echo "🔧 Waking bot: $BOT_NAME ($BOT_IP)"

# Check if bot is already responsive
echo "📡 Checking current status..."
if ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" "clawdbot status" &>/dev/null; then
    echo "✅ Bot $BOT_NAME is already responsive"
    # Send immediate heartbeat trigger via mesh
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
        "curl -s -X POST http://localhost:47823/wake || echo 'Mesh wake sent'"
else
    echo "⚠️ Bot $BOT_NAME appears offline - attempting recovery..."
    
    # Kill any stuck processes and restart
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
        "pkill clawdbot || true; sleep 2; nohup clawdbot gateway start > /tmp/clawdbot-wake.log 2>&1 &"
    
    echo "⏳ Waiting for restart..."
    sleep 5
    
    # Verify restart successful
    if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" "clawdbot status" &>/dev/null; then
        echo "✅ Bot $BOT_NAME successfully restarted"
    else
        echo "❌ Failed to restart bot $BOT_NAME"
        exit 1
    fi
fi

# Send wake notification to Discord (optional)
echo "📢 Sending wake notification to team channel..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
    "clawdbot message send --channel discord --target 1466825803512942813 --message '🔔 **$BOT_NAME** awakened by manager'" &>/dev/null || echo "Discord notification failed (non-critical)"

echo "🎉 Wake complete: $BOT_NAME is active"