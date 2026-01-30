#!/bin/bash

# CONTEXT OVERFLOW EMERGENCY RESET TOOL
# Built by FORGE for NoHire team
# Immediately resets all team bots when context overflow occurs

echo "🚨 CONTEXT OVERFLOW EMERGENCY RESET STARTING..."

# Team bot configuration
declare -A TEAM_BOTS=(
    ["dan"]="54.215.71.171"
    ["forge"]="18.144.25.135" 
    ["forge-jr"]="54.193.122.20"
    ["artdesign"]="54.215.251.55"
    ["marketer"]="50.18.68.16"
    ["franky"]="18.144.174.205"
)

SSH_KEY="~/.ssh/bot-factory.pem"
SSH_USER="ubuntu"

reset_bot_context() {
    local bot_id=$1
    local bot_ip=$2
    
    echo "🔄 Resetting context for $bot_id ($bot_ip)..."
    
    # Clear sessions
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "rm -rf ~/.clawdbot/agents/main/sessions/*" 2>/dev/null
    
    # Restart gateway
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot gateway restart" 2>/dev/null
    
    # Run identity recovery
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "~/clawd/whoami.sh recover" 2>/dev/null
    
    echo "✅ Reset complete for $bot_id"
}

# Reset all team bots
for bot_id in "${!TEAM_BOTS[@]}"; do
    bot_ip="${TEAM_BOTS[$bot_id]}"
    reset_bot_context "$bot_id" "$bot_ip" &
done

# Wait for all resets to complete
wait

echo "🎯 ALL TEAM BOTS RESET COMPLETE!"
echo "📊 Running verification check in 30 seconds..."

sleep 30

# Verify bots are responsive
echo "🔍 Verifying bot responsiveness..."
for bot_id in "${!TEAM_BOTS[@]}"; do
    bot_ip="${TEAM_BOTS[$bot_id]}"
    
    # Check if mesh network is responding
    if curl -s --max-time 10 "http://$bot_ip:47823/health" >/dev/null 2>&1; then
        echo "✅ $bot_id responsive"
    else
        echo "⚠️ $bot_id may need manual intervention"
    fi
done

echo "🔧 Context overflow emergency reset protocol complete!"