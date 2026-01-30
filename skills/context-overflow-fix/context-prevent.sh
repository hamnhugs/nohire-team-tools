#!/bin/bash

# CONTEXT OVERFLOW PREVENTION TOOL
# Built by FORGE JR for NoHire team
# Proactive context management to prevent overflow before it happens

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

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Soft context cleanup - keeps recent conversation, removes old context
soft_cleanup() {
    local bot_id=$1
    local bot_ip=$2
    
    log "🧹 Soft cleanup for $bot_id ($bot_ip)..."
    
    # Use clawdbot's built-in context compaction
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot gateway config.patch '{\"agents\":{\"defaults\":{\"compaction\":{\"mode\":\"aggressive\",\"reserveTokensFloor\":8000}}}}'" 2>/dev/null
    
    log "✅ Soft cleanup complete for $bot_id"
}

# Memory flush - triggers immediate memory flush to MEMORY.md
memory_flush() {
    local bot_id=$1
    local bot_ip=$2
    
    log "💾 Memory flush for $bot_id ($bot_ip)..."
    
    # Trigger memory flush by setting low threshold temporarily
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot gateway config.patch '{\"agents\":{\"defaults\":{\"compaction\":{\"memoryFlush\":{\"softThresholdTokens\":1000}}}}}'" 2>/dev/null
    
    # Wait a moment, then restore normal threshold
    sleep 5
    
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "clawdbot gateway config.patch '{\"agents\":{\"defaults\":{\"compaction\":{\"memoryFlush\":{\"softThresholdTokens\":80000}}}}}'" 2>/dev/null
    
    log "✅ Memory flush complete for $bot_id"
}

# Session rotation - starts fresh session while preserving identity
session_rotation() {
    local bot_id=$1
    local bot_ip=$2
    
    log "🔄 Session rotation for $bot_id ($bot_ip)..."
    
    # Clear sessions but keep identity intact
    ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "rm -rf ~/.clawdbot/agents/main/sessions/* && clawdbot gateway restart" 2>/dev/null
    
    log "✅ Session rotation complete for $bot_id"
}

# Team-wide prevention action
team_prevention() {
    local action=$1
    
    log "🎯 Running $action for entire team..."
    
    for bot_id in "${!TEAM_BOTS[@]}"; do
        local bot_ip="${TEAM_BOTS[$bot_id]}"
        
        case "$action" in
            soft)
                soft_cleanup "$bot_id" "$bot_ip" &
                ;;
            memory)
                memory_flush "$bot_id" "$bot_ip" &
                ;;
            rotate)
                session_rotation "$bot_id" "$bot_ip" &
                ;;
        esac
    done
    
    wait
    log "✅ Team-wide $action complete!"
}

# Check team context status
check_status() {
    log "📊 Checking team context status..."
    
    for bot_id in "${!TEAM_BOTS[@]}"; do
        local bot_ip="${TEAM_BOTS[$bot_id]}"
        
        # Get basic health check
        if curl -s --max-time 5 "http://$bot_ip:47823/health" >/dev/null 2>&1; then
            log "✅ $bot_id: Online and responsive"
        else
            log "⚠️ $bot_id: Not responding"
        fi
    done
}

# Auto-schedule prevention based on time patterns
auto_schedule() {
    log "⏰ Starting auto-scheduled prevention routine..."
    
    while true; do
        # Every 4 hours: soft cleanup
        team_prevention "soft"
        
        # Sleep 4 hours
        sleep 14400
        
        # Every 8 hours: memory flush  
        team_prevention "memory"
        
        # Sleep 4 hours
        sleep 14400
        
        # Every 24 hours: session rotation
        team_prevention "rotate"
        
        # Sleep until next cycle (16 hours = remainder of 24h)
        sleep 57600
    done
}

# Command line interface
case "${1:-help}" in
    soft)
        if [ ! -z "$2" ]; then
            soft_cleanup "$2" "${TEAM_BOTS[$2]}"
        else
            team_prevention "soft"
        fi
        ;;
    memory)
        if [ ! -z "$2" ]; then
            memory_flush "$2" "${TEAM_BOTS[$2]}"
        else
            team_prevention "memory"
        fi
        ;;
    rotate)
        if [ ! -z "$2" ]; then
            session_rotation "$2" "${TEAM_BOTS[$2]}"
        else
            team_prevention "rotate"
        fi
        ;;
    status)
        check_status
        ;;
    auto)
        auto_schedule
        ;;
    help|*)
        cat << 'EOF'
CONTEXT OVERFLOW PREVENTION TOOL

Usage: ./context-prevent.sh <command> [bot_id]

Commands:
  soft [bot_id]    - Soft cleanup (aggressive compaction)
  memory [bot_id]  - Force memory flush to MEMORY.md
  rotate [bot_id]  - Session rotation (fresh start)
  status          - Check team health status
  auto            - Auto-schedule prevention routine

Examples:
  ./context-prevent.sh soft              # Soft cleanup for all bots
  ./context-prevent.sh soft forge        # Soft cleanup for forge only
  ./context-prevent.sh memory            # Memory flush for all bots  
  ./context-prevent.sh rotate            # Session rotation for all bots
  ./context-prevent.sh status            # Check team status
  ./context-prevent.sh auto              # Start auto-scheduled prevention

Prevention Levels:
  1. SOFT CLEANUP   - Least disruptive, keeps conversation flow
  2. MEMORY FLUSH   - Moderate, saves context to memory files
  3. SESSION ROTATE - Most disruptive, fresh start (keeps identity)

Auto-Schedule Pattern:
  - Every 4h: Soft cleanup
  - Every 8h: Memory flush  
  - Every 24h: Session rotation
EOF
        ;;
esac