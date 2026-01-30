#!/bin/bash

# Manager Wake Tool - Reset heartbeat to normal (30 minutes)
# Usage: ./normal-heartbeat.sh <bot-name|team-name|all>

set -e

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$TARGET" ]]; then
    echo "❌ Usage: $0 <bot-name|team-name|all>"
    echo "Bots: dan, forge, forge-jr, artdesign, marketer, franky"
    echo "Teams: build-team, creative-team, management, support, all"
    exit 1
fi

# Team compositions
declare -A TEAMS=(
    ["build-team"]="forge forge-jr"
    ["creative-team"]="artdesign marketer"
    ["management"]="dan"
    ["support"]="franky"
    ["all"]="dan forge forge-jr artdesign marketer franky"
)

# Bot IP mappings
declare -A BOT_IPS=(
    ["dan"]="54.215.71.171"
    ["forge"]="18.144.25.135"
    ["forge-jr"]="54.193.122.20"
    ["artdesign"]="54.215.251.55"
    ["marketer"]="50.18.68.16"
    ["franky"]="18.144.174.205"
)

# Determine target bots
if [[ -n "${TEAMS[$TARGET]}" ]]; then
    # It's a team
    BOTS="${TEAMS[$TARGET]}"
    echo "🔄 Resetting team $TARGET to normal heartbeat"
elif [[ -n "${BOT_IPS[$TARGET]}" ]]; then
    # It's a single bot
    BOTS="$TARGET"
    echo "🔄 Resetting bot $TARGET to normal heartbeat"
else
    echo "❌ Unknown target: $TARGET"
    echo "Available bots: ${!BOT_IPS[@]}"
    echo "Available teams: ${!TEAMS[@]}"
    exit 1
fi

SSH_KEY="$HOME/.ssh/bot-factory.pem"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "❌ SSH key not found: $SSH_KEY"
    exit 1
fi

# Normal heartbeat: 30 minutes (1800000ms)
NORMAL_HEARTBEAT=1800000

echo "🎯 Target bots: $BOTS"

for BOT in $BOTS; do
    BOT_IP="${BOT_IPS[$BOT]}"
    
    if [[ -z "$BOT_IP" ]]; then
        echo "⚠️ No IP found for bot: $BOT"
        continue
    fi
    
    echo "📡 Resetting $BOT ($BOT_IP) to normal heartbeat..."
    
    # Reset heartbeat via config patch
    if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
        "clawdbot gateway config.patch '{\"heartbeat\":{\"intervalMs\":$NORMAL_HEARTBEAT}}'" &>/dev/null; then
        echo "✅ $BOT heartbeat reset to normal (30min)"
        
        # Trigger CALM cooldown if available
        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
            "cd ~/clawd/nohire-team-tools/skills/calm-skill && ./calm.sh cooldown || true" &>/dev/null
    else
        echo "❌ Failed to reset $BOT heartbeat"
    fi
done

# Notify team via Discord
echo "📢 Notifying team channel..."
FIRST_BOT=$(echo $BOTS | awk '{print $1}')
FIRST_IP="${BOT_IPS[$FIRST_BOT]}"

if [[ -n "$FIRST_IP" ]]; then
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$FIRST_IP" \
        "clawdbot message send --channel discord --target 1466825803512942813 --message '💤 **COOLDOWN** - $TARGET heartbeat reset to normal (30min) by manager'" &>/dev/null || echo "Discord notification failed (non-critical)"
fi

echo "🎉 Heartbeat reset complete: $TARGET is in normal mode"