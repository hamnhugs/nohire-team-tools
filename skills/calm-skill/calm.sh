#!/bin/bash

# CALM SKILL - Call to Action / Priority Mode
# Built by Forge for NoHire team
# 
# Triggers priority mode across all team bots

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/calm-config.json"
LOG_FILE="$SCRIPT_DIR/calm.log"

# Team bot endpoints (mesh network)
declare -A BOT_ENDPOINTS=(
    ["dan"]="54.215.71.171:47823"
    ["forge"]="18.144.25.135:47823" 
    ["forge-jr"]="54.193.122.20:47823"
    ["artdesign"]="54.215.251.55:47823"
    ["marketer"]="50.18.68.16:47823"
    ["franky"]="18.144.174.205:47823"
)

# Discord settings
DISCORD_CHANNEL="1466825803512942813"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[CALM]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Show usage
show_usage() {
    echo "CALM Skill - Priority Mode for Team Bots"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  trigger <task>     Trigger priority mode with task description"
    echo "  status             Show current priority mode status" 
    echo "  cooldown           Force cooldown to normal heartbeat"
    echo "  list-bots          Show all monitored bots"
    echo "  test               Test connectivity to all bots"
    echo ""
    echo "Examples:"
    echo "  $0 trigger \"Deploy Watchdog Bot immediately\""
    echo "  $0 status"
    echo "  $0 cooldown"
    echo ""
    echo "Built by Forge 🔧"
}

# Send mesh message to bot
send_mesh_message() {
    local bot_endpoint="$1"
    local message="$2"
    local from_bot="${3:-forge}"
    
    local url="http://$bot_endpoint/message"
    local payload=$(cat << EOF
{
    "from_bot_id": "$from_bot",
    "content": "$message",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
}
EOF
)
    
    if curl -s -X POST "$url" \
           -H "Content-Type: application/json" \
           -d "$payload" \
           --max-time 10 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Send Discord message
send_discord_message() {
    local message="$1"
    
    clawdbot message send \
        --channel discord \
        --target "$DISCORD_CHANNEL" \
        --message "$message" 2>/dev/null || true
}

# Broadcast priority mode to all bots
broadcast_priority_mode() {
    local task_description="$1"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
    
    log_info "🚨 Broadcasting priority mode to all team bots..."
    
    # Create priority mode message
    local calm_message=$(cat << EOF
🚨 PRIORITY MODE ACTIVATED

**Task**: $task_description
**Triggered by**: Manager
**Action Required**: 
- Switch to 1-minute heartbeat
- Process urgent tasks immediately
- Report completion when done

**Smart Heartbeat Rules**:
- Only fire when bot is idle
- Skip if currently processing
- No interruption of active work

Timestamp: $timestamp
EOF
)
    
    # Broadcast to all team bots
    local success_count=0
    local total_bots=${#BOT_ENDPOINTS[@]}
    
    for bot_id in "${!BOT_ENDPOINTS[@]}"; do
        local endpoint="${BOT_ENDPOINTS[$bot_id]}"
        log_info "📤 Sending priority mode to $bot_id ($endpoint)..."
        
        if send_mesh_message "$endpoint" "$calm_message"; then
            log_success "✅ $bot_id notified"
            ((success_count++))
        else
            log_warning "⚠️ Failed to notify $bot_id"
        fi
    done
    
    # Discord announcement
    local discord_announcement="🚨 **PRIORITY MODE ACTIVATED**

**Task**: $task_description
**Bots Notified**: $success_count/$total_bots
**Heartbeat**: Switched to 1-minute for all bots
**Expected**: Faster response times until task complete

Team bots are now in priority mode! ⚡"
    
    send_discord_message "$discord_announcement"
    
    # Save priority mode state
    cat > "$CONFIG_FILE" << EOF
{
    "priority_mode": true,
    "task": "$task_description",
    "triggered_at": "$timestamp",
    "bots_notified": $success_count,
    "total_bots": $total_bots
}
EOF
    
    log_success "🚨 Priority mode activated! $success_count/$total_bots bots notified"
}

# Check priority mode status
check_status() {
    log_info "📊 Checking CALM priority mode status..."
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_info "📊 No active priority mode"
        return 0
    fi
    
    local config=$(cat "$CONFIG_FILE")
    local priority_mode=$(echo "$config" | jq -r '.priority_mode // false')
    local task=$(echo "$config" | jq -r '.task // "N/A"')
    local triggered_at=$(echo "$config" | jq -r '.triggered_at // "N/A"')
    local bots_notified=$(echo "$config" | jq -r '.bots_notified // 0')
    local total_bots=$(echo "$config" | jq -r '.total_bots // 0')
    
    if [[ "$priority_mode" == "true" ]]; then
        log_warning "🚨 PRIORITY MODE ACTIVE"
        echo "  Task: $task"
        echo "  Started: $triggered_at"
        echo "  Bots Notified: $bots_notified/$total_bots"
    else
        log_success "✅ Normal mode - no active priority"
    fi
}

# Force cooldown to normal mode
force_cooldown() {
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
    
    log_info "❄️ Forcing cooldown to normal heartbeat mode..."
    
    # Create cooldown message
    local cooldown_message=$(cat << EOF
❄️ PRIORITY MODE DEACTIVATED

**Status**: Returning to normal heartbeat (30 minutes)
**Reason**: Manual cooldown triggered
**Action**: Switch back to standard operating mode

Timestamp: $timestamp
EOF
)
    
    # Broadcast cooldown to all bots
    local success_count=0
    
    for bot_id in "${!BOT_ENDPOINTS[@]}"; do
        local endpoint="${BOT_ENDPOINTS[$bot_id]}"
        log_info "📤 Sending cooldown to $bot_id..."
        
        if send_mesh_message "$endpoint" "$cooldown_message"; then
            log_success "✅ $bot_id cooled down"
            ((success_count++))
        else
            log_warning "⚠️ Failed to notify $bot_id"
        fi
    done
    
    # Discord announcement
    send_discord_message "❄️ **PRIORITY MODE DEACTIVATED** - All bots returning to normal heartbeat (30min)"
    
    # Clear priority mode state
    cat > "$CONFIG_FILE" << EOF
{
    "priority_mode": false,
    "last_cooldown": "$timestamp",
    "bots_notified": $success_count
}
EOF
    
    log_success "❄️ Cooldown complete! $success_count bots returned to normal mode"
}

# Test connectivity to all bots
test_connectivity() {
    log_info "🔍 Testing connectivity to all team bots..."
    
    local success_count=0
    local total_bots=${#BOT_ENDPOINTS[@]}
    
    for bot_id in "${!BOT_ENDPOINTS[@]}"; do
        local endpoint="${BOT_ENDPOINTS[$bot_id]}"
        local health_url="http://$endpoint/health"
        
        log_info "🔍 Testing $bot_id ($endpoint)..."
        
        if curl -s --max-time 10 "$health_url" > /dev/null 2>&1; then
            log_success "✅ $bot_id responsive"
            ((success_count++))
        else
            log_error "❌ $bot_id not responding"
        fi
    done
    
    log_info "📊 Connectivity test: $success_count/$total_bots bots responsive"
}

# List all monitored bots
list_bots() {
    log_info "📋 Team bots monitored by CALM system:"
    
    for bot_id in "${!BOT_ENDPOINTS[@]}"; do
        local endpoint="${BOT_ENDPOINTS[$bot_id]}"
        echo "  $bot_id → $endpoint"
    done
}

# Main function
main() {
    case "${1:-}" in
        "trigger")
            if [[ -z "${2:-}" ]]; then
                log_error "Task description required for trigger command"
                show_usage
                exit 1
            fi
            broadcast_priority_mode "$2"
            ;;
        "status")
            check_status
            ;;
        "cooldown")
            force_cooldown
            ;;
        "list-bots")
            list_bots
            ;;
        "test")
            test_connectivity
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_usage
            exit 1
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Handle script interruption
trap 'log_warning "CALM command interrupted."; exit 1' INT TERM

# Ensure config directory exists
mkdir -p "$(dirname "$CONFIG_FILE")"

# Run main function
main "$@"