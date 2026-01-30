#!/bin/bash

# Manager Wake Tool - Check bot status and responsiveness
# Usage: ./check-status.sh <bot-name|team-name|all>

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
    BOTS="${TEAMS[$TARGET]}"
    echo "🔍 Checking team $TARGET status"
elif [[ -n "${BOT_IPS[$TARGET]}" ]]; then
    BOTS="$TARGET"
    echo "🔍 Checking bot $TARGET status"
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

echo "🎯 Target bots: $BOTS"
echo "=================================================="

HEALTHY_COUNT=0
TOTAL_COUNT=0

for BOT in $BOTS; do
    BOT_IP="${BOT_IPS[$BOT]}"
    
    if [[ -z "$BOT_IP" ]]; then
        echo "⚠️ $BOT: No IP configured"
        continue
    fi
    
    ((TOTAL_COUNT++))
    
    echo -n "📡 $BOT ($BOT_IP): "
    
    # Test SSH connectivity
    if ! ssh -i "$SSH_KEY" -o ConnectTimeout=3 -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" "echo 'SSH OK'" &>/dev/null; then
        echo "❌ SSH FAILED"
        continue
    fi
    
    # Test clawdbot status
    if ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" "clawdbot status" &>/dev/null; then
        # Get heartbeat info
        HEARTBEAT=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
            "clawdbot gateway config.get | grep -A2 heartbeat | grep intervalMs | awk '{print \$2}' | tr -d ',' || echo 'unknown'")
        
        # Convert to human readable
        if [[ "$HEARTBEAT" == "60000" ]]; then
            HEARTBEAT_STR="1min (PRIORITY)"
        elif [[ "$HEARTBEAT" == "1800000" ]]; then
            HEARTBEAT_STR="30min (normal)"
        elif [[ "$HEARTBEAT" =~ ^[0-9]+$ ]]; then
            HEARTBEAT_MIN=$((HEARTBEAT / 60000))
            HEARTBEAT_STR="${HEARTBEAT_MIN}min"
        else
            HEARTBEAT_STR="unknown"
        fi
        
        echo "✅ ONLINE - Heartbeat: $HEARTBEAT_STR"
        ((HEALTHY_COUNT++))
        
        # Test mesh network
        MESH_STATUS=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
            "curl -s --connect-timeout 2 http://localhost:47823/inbox | jq -r '.count // \"error\"' 2>/dev/null || echo 'unavailable'")
        
        if [[ "$MESH_STATUS" =~ ^[0-9]+$ ]]; then
            echo "   📬 Mesh: $MESH_STATUS messages in inbox"
        else
            echo "   ⚠️ Mesh: $MESH_STATUS"
        fi
        
    else
        echo "❌ CLAWDBOT OFFLINE"
        
        # Check if process exists
        PROCESS_COUNT=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@"$BOT_IP" \
            "ps aux | grep clawdbot | grep -v grep | wc -l || echo 0")
        
        if [[ "$PROCESS_COUNT" -gt 0 ]]; then
            echo "   🔄 Process exists but not responding"
        else
            echo "   💀 No clawdbot process running"
        fi
    fi
done

echo "=================================================="
echo "📊 SUMMARY: $HEALTHY_COUNT/$TOTAL_COUNT bots healthy"

if [[ $HEALTHY_COUNT -eq $TOTAL_COUNT ]]; then
    echo "✅ All bots are operational"
    exit 0
elif [[ $HEALTHY_COUNT -eq 0 ]]; then
    echo "❌ All bots are offline - escalate immediately"
    exit 2
else
    echo "⚠️ Some bots need attention"
    exit 1
fi