#!/bin/bash

# CONTEXT OVERFLOW SKILL DEPLOYMENT
# Built by FORGE JR for NoHire team
# Deploys the complete context overflow skill set to all team bots

# Team bot configuration
declare -A TEAM_BOTS=(
    ["dan"]="54.215.71.171"
    ["forge"]="18.144.25.135" 
    ["artdesign"]="54.215.251.55"
    ["marketer"]="50.18.68.16"
    ["franky"]="18.144.174.205"
)

SSH_KEY="~/.ssh/bot-factory.pem"
SSH_USER="ubuntu"
SKILL_DIR="$(dirname "$0")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

deploy_to_bot() {
    local bot_id=$1
    local bot_ip=$2
    
    log "🚀 Deploying context overflow skill to $bot_id ($bot_ip)..."
    
    # Create the skill directory on target bot
    ssh -i $SSH_KEY -o ConnectTimeout=15 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "mkdir -p ~/clawd/nohire-team-tools/skills/context-overflow-fix/" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        log "❌ Failed to connect to $bot_id"
        return 1
    fi
    
    # Copy all skill files
    scp -i $SSH_KEY -o ConnectTimeout=15 -o StrictHostKeyChecking=no \
        "$SKILL_DIR"/*.sh "$SKILL_DIR"/*.md \
        $SSH_USER@$bot_ip:~/clawd/nohire-team-tools/skills/context-overflow-fix/ 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Make scripts executable
        ssh -i $SSH_KEY -o ConnectTimeout=15 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
            "chmod +x ~/clawd/nohire-team-tools/skills/context-overflow-fix/*.sh" 2>/dev/null
        
        log "✅ Successfully deployed to $bot_id"
        return 0
    else
        log "❌ Failed to copy files to $bot_id"
        return 1
    fi
}

start_monitoring_on_bot() {
    local bot_id=$1
    local bot_ip=$2
    
    log "📊 Starting context monitoring on $bot_id..."
    
    # Start the monitoring service
    ssh -i $SSH_KEY -o ConnectTimeout=15 -o StrictHostKeyChecking=no $SSH_USER@$bot_ip \
        "cd ~/clawd/nohire-team-tools/skills/context-overflow-fix/ && ./service-manager.sh start-monitor" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log "✅ Monitoring started on $bot_id"
    else
        log "⚠️ Could not start monitoring on $bot_id (may need manual start)"
    fi
}

# Main deployment
log "🎯 DEPLOYING CONTEXT OVERFLOW SKILL TO ALL TEAM BOTS"
log "📋 Skill includes: monitor, prevention, emergency reset, service manager"

successful_deployments=0
total_bots=${#TEAM_BOTS[@]}

# Deploy to each bot
for bot_id in "${!TEAM_BOTS[@]}"; do
    bot_ip="${TEAM_BOTS[$bot_id]}"
    
    if deploy_to_bot "$bot_id" "$bot_ip"; then
        start_monitoring_on_bot "$bot_id" "$bot_ip" &
        ((successful_deployments++))
    fi
done

# Wait for all monitoring starts to complete
wait

log "📊 DEPLOYMENT SUMMARY:"
log "✅ Successfully deployed: $successful_deployments/$total_bots bots"
log "📋 Each bot now has:"
log "   • Context monitoring with auto-reset"
log "   • Prevention tools (soft/memory/rotate)"
log "   • Emergency reset capability"
log "   • Service management"

if [ $successful_deployments -eq $total_bots ]; then
    log "🎉 ALL BOTS EQUIPPED WITH CONTEXT OVERFLOW PROTECTION!"
    log "🛡️ Team-wide automatic context management is now active"
else
    log "⚠️ Some deployments failed - may need manual intervention"
    log "💡 Run individual deployments for failed bots"
fi

log "🔧 Deployment complete! Context overflow is now managed automatically across the team."