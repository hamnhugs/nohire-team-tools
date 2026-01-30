#!/bin/bash

# CONTEXT OVERFLOW MONITOR & AUTO-FIX
# Built by FORGE JR for NoHire team
# Monitors all team bots for context overflow and auto-triggers fixes

# Configuration
MONITOR_INTERVAL=300  # Check every 5 minutes
WARNING_THRESHOLD=75000  # Warning at 75k tokens
CRITICAL_THRESHOLD=85000 # Auto-reset at 85k tokens
MAX_TOKENS=100000  # Approximate max context window

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
LOG_FILE="/tmp/context-monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

get_bot_context_usage() {
    local bot_ip=$1
    
    # Get session status via clawdbot status command
    local status_output=$(ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot status --format json 2>/dev/null" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ ! -z "$status_output" ]; then
        # Extract token usage from status output
        local tokens=$(echo "$status_output" | jq -r '.sessions[0].tokens // 0' 2>/dev/null)
        echo "$tokens"
    else
        echo "0"
    fi
}

send_alert() {
    local message=$1
    local severity=$2  # warning, critical, resolved
    
    # Send to Discord #bot-team channel
    curl -X POST "http://localhost:47823/discord-webhook" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"🤖 **Context Monitor Alert ($severity)**\\n$message\"}" \
        >/dev/null 2>&1
    
    # Also send via mesh network to dan/manny
    curl -X POST http://localhost:47823/send \
        -H "Content-Type: application/json" \
        -d "{\"from_bot_id\": \"forge-jr\", \"to_bot_id\": \"dan-pena\", \"content\": \"🚨 CONTEXT ALERT: $message\"}" \
        >/dev/null 2>&1
}

auto_fix_context() {
    local bot_id=$1
    local tokens=$2
    
    log "🚨 AUTO-FIX: $bot_id exceeded critical threshold ($tokens tokens). Triggering emergency reset..."
    
    # Run the emergency reset tool
    cd "$(dirname "$0")"
    ./context-reset.sh
    
    send_alert "Emergency context reset triggered for team bots. All bots should be responsive again." "resolved"
    log "✅ Auto-fix completed for team"
}

monitor_loop() {
    log "🔍 Starting context monitoring for team bots..."
    
    while true; do
        local critical_bot=""
        local max_tokens=0
        
        # Check each bot's context usage
        for bot_id in "${!TEAM_BOTS[@]}"; do
            local bot_ip="${TEAM_BOTS[$bot_id]}"
            local tokens=$(get_bot_context_usage "$bot_ip")
            
            if [ "$tokens" -gt 0 ]; then
                local percentage=$((tokens * 100 / MAX_TOKENS))
                
                # Log current usage
                log "📊 $bot_id: $tokens tokens ($percentage%)"
                
                # Check thresholds
                if [ "$tokens" -gt "$CRITICAL_THRESHOLD" ]; then
                    critical_bot="$bot_id"
                    max_tokens="$tokens"
                    break
                elif [ "$tokens" -gt "$WARNING_THRESHOLD" ]; then
                    send_alert "$bot_id approaching context limit: $tokens tokens ($percentage%)" "warning"
                fi
            fi
        done
        
        # Auto-fix if critical threshold reached
        if [ ! -z "$critical_bot" ]; then
            auto_fix_context "$critical_bot" "$max_tokens"
            # After auto-fix, wait longer before next check
            sleep $((MONITOR_INTERVAL * 2))
        else
            sleep "$MONITOR_INTERVAL"
        fi
    done
}

# Command line interface
case "${1:-monitor}" in
    monitor)
        monitor_loop
        ;;
    status)
        log "🔍 Current team context status:"
        for bot_id in "${!TEAM_BOTS[@]}"; do
            bot_ip="${TEAM_BOTS[$bot_id]}"
            tokens=$(get_bot_context_usage "$bot_ip")
            percentage=$((tokens * 100 / MAX_TOKENS))
            log "📊 $bot_id: $tokens tokens ($percentage%)"
        done
        ;;
    test-alert)
        send_alert "Context monitor test alert from forge-jr" "warning"
        log "Test alert sent"
        ;;
    *)
        echo "Usage: $0 {monitor|status|test-alert}"
        echo "  monitor    - Start continuous monitoring (default)"
        echo "  status     - Check current context usage for all bots"
        echo "  test-alert - Send test alert to verify alerting works"
        ;;
esac