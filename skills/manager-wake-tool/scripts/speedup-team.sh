#!/bin/bash

# Manager Wake Tool - Speed up team heartbeat for priority mode
# Usage: ./speedup-team.sh <team-name> [duration-hours]

set -e

TEAM_NAME="$1"
DURATION="${2:-2}"  # Default 2 hours
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$TEAM_NAME" ]]; then
    echo "❌ Usage: $0 <team-name> [duration-hours]"
    echo "Available teams: build-team, creative-team, management, support, all"
    exit 1
fi

# Team compositions (from fleet reference)
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

BOTS="${TEAMS[$TEAM_NAME]}"

if [[ -z "$BOTS" ]]; then
    echo "❌ Unknown team: $TEAM_NAME"
    echo "Available teams: ${!TEAMS[@]}"
    exit 1
fi

SSH_KEY="$HOME/.ssh/bot-factory.pem"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "❌ SSH key not found: $SSH_KEY"
    exit 1
fi

echo "🚀 Speeding up $TEAM_NAME for $DURATION hours"
echo "🎯 Target bots: $BOTS"

# Priority heartbeat: 60 seconds
PRIORITY_HEARTBEAT=60000

for BOT in $BOTS; do
    BOT_IP="${BOT_IPS[$BOT]}"
    
    if [[ -z "$BOT_IP" ]]; then
        echo "⚠️ No IP found for bot: $BOT"
        continue
    fi
    
    echo "📡 Speeding up $BOT ($BOT_IP)..."
    
    # Update heartbeat via config patch
    if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
        "clawdbot gateway config.patch '{\"heartbeat\":{\"intervalMs\":$PRIORITY_HEARTBEAT}}'" &>/dev/null; then
        echo "✅ $BOT heartbeat set to priority mode"
        
        # Trigger CALM skill if available
        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
            "cd ~/clawd/nohire-team-tools/skills/calm-skill && ./calm.sh trigger 'Manager priority mode - $TEAM_NAME speedup' || true" &>/dev/null
    else
        echo "❌ Failed to update $BOT heartbeat"
    fi
done

# Schedule auto-cooldown (using at command if available)
COOLDOWN_TIME=$(date -d "+${DURATION} hours" '+%H:%M %Y-%m-%d')
echo "⏰ Scheduling cooldown for $COOLDOWN_TIME"

# Create cooldown script
COOLDOWN_SCRIPT="/tmp/cooldown-$TEAM_NAME-$(date +%s).sh"
cat > "$COOLDOWN_SCRIPT" << EOF
#!/bin/bash
# Auto-generated cooldown script for $TEAM_NAME
echo "🔄 Auto-cooldown: Resetting $TEAM_NAME to normal heartbeat"
$(dirname "$0")/normal-heartbeat.sh $TEAM_NAME
rm -f "$COOLDOWN_SCRIPT"
EOF

chmod +x "$COOLDOWN_SCRIPT"

# Try to schedule with at command
if command -v at &>/dev/null; then
    echo "$COOLDOWN_SCRIPT" | at "$COOLDOWN_TIME" 2>/dev/null && \
        echo "✅ Auto-cooldown scheduled for $COOLDOWN_TIME" || \
        echo "⚠️ Manual cooldown required - run: $COOLDOWN_SCRIPT"
else
    echo "⚠️ 'at' command not available - manual cooldown required"
    echo "📋 Run this command in $DURATION hours: $COOLDOWN_SCRIPT"
fi

# Notify team via Discord
echo "📢 Notifying team channel..."
FIRST_BOT=$(echo $BOTS | awk '{print $1}')
FIRST_IP="${BOT_IPS[$FIRST_BOT]}"

if [[ -n "$FIRST_IP" ]]; then
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$FIRST_IP" \
        "clawdbot message send --channel discord --target 1466825803512942813 --message '⚡ **PRIORITY MODE** - $TEAM_NAME heartbeat accelerated for ${DURATION}h by manager'" &>/dev/null || echo "Discord notification failed (non-critical)"
fi

echo "🎉 Team speedup complete: $TEAM_NAME is in priority mode"
echo "💡 Use './normal-heartbeat.sh $TEAM_NAME' to cooldown manually"