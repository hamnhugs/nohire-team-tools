#!/bin/bash

# AUTOMATED CONTEXT OVERFLOW PREVENTION SYSTEM
# Built by FORGE for NoHire team  
# Prevents context overflow before it happens - NO MORE TOKEN WASTE!

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/context-monitor.log"
TOKEN_LIMIT=75000  # Trigger reset before 80k limit
CHECK_INTERVAL=300 # Check every 5 minutes

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

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_bot_context() {
    local bot_id=$1
    local bot_ip=$2
    
    # Get current session token count via clawdbot status
    local token_usage=$(ssh -i $SSH_KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot status --json 2>/dev/null | jq -r '.sessions[0].contextTokens // 0'" 2>/dev/null)
    
    if [[ "$token_usage" =~ ^[0-9]+$ ]] && [ "$token_usage" -gt "$TOKEN_LIMIT" ]; then
        log_message "🚨 ALERT: $bot_id context usage $token_usage tokens (>${TOKEN_LIMIT} limit)"
        return 1  # Needs reset
    else
        log_message "✅ $bot_id: $token_usage tokens (OK)"
        return 0  # OK
    fi
}

auto_reset_bot() {
    local bot_id=$1
    local bot_ip=$2
    
    log_message "🔄 AUTO-RESETTING $bot_id to prevent overflow..."
    
    # Clear sessions
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "rm -rf ~/.clawdbot/agents/main/sessions/*" 2>/dev/null
    
    # Apply context-friendly config
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot gateway config.patch '{\"agents\":{\"defaults\":{\"compaction\":{\"memoryFlush\":{\"softThresholdTokens\":80000}},\"contextPruning\":{\"mode\":\"cache-ttl\",\"ttl\":\"15m\",\"keepLastAssistants\":2,\"minPrunableToolChars\":500}}}}'" 2>/dev/null
    
    # Run identity recovery
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "~/clawd/whoami.sh recover" 2>/dev/null
    
    # Send Discord notification
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot message send --channel discord --target 1466825803512942813 --message '🤖 Auto-reset: $bot_id context prevented overflow ($token_usage tokens). Back online with fresh memory. 🔄'" 2>/dev/null
    
    log_message "✅ AUTO-RESET COMPLETE: $bot_id"
}

# Main monitoring loop
log_message "🔍 AUTOMATED CONTEXT MONITOR STARTING..."
log_message "📊 Token limit: $TOKEN_LIMIT | Check interval: ${CHECK_INTERVAL}s"

while true; do
    log_message "🕐 Running context check cycle..."
    
    reset_needed=()
    
    # Check all bots in parallel
    for bot_id in "${!TEAM_BOTS[@]}"; do
        bot_ip="${TEAM_BOTS[$bot_id]}"
        
        if ! check_bot_context "$bot_id" "$bot_ip"; then
            reset_needed+=("$bot_id:$bot_ip")
        fi
    done
    
    # Auto-reset bots that need it
    if [ ${#reset_needed[@]} -gt 0 ]; then
        log_message "🚨 AUTO-RESET TRIGGERED for ${#reset_needed[@]} bots"
        
        for bot_entry in "${reset_needed[@]}"; do
            IFS=':' read -r bot_id bot_ip <<< "$bot_entry"
            auto_reset_bot "$bot_id" "$bot_ip" &
        done
        
        wait  # Wait for all resets to complete
        
        log_message "🎯 AUTO-RESET CYCLE COMPLETE"
    else
        log_message "🟢 ALL BOTS WITHIN LIMITS"
    fi
    
    log_message "⏱️ Sleeping for ${CHECK_INTERVAL}s..."
    sleep "$CHECK_INTERVAL"
done