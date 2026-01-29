#!/bin/bash

# Instant Wake Tool v1.0
# Built by Forge 🔧 for immediate bot wake-ups
# Usage: ./wake.sh <bot-id> [message]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="$HOME/.ssh/bot-factory.pem"
WAKE_ENDPOINT="http://127.0.0.1:18789/hooks/wake"
DEFAULT_MESSAGE="Wake up! Check your Switchboard inbox."

# Known bot mappings (bot-id -> IP/hostname)
declare -A BOT_IPS=(
    ["forge"]="127.0.0.1"  # Self for testing
    ["artdesign"]=""       # ArtDesign bot IP (to be filled)
    ["dan-pena"]=""        # Dan's bot IP (if needed)
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[WAKE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    echo "Instant Wake Tool - Wake any team bot immediately"
    echo ""
    echo "Usage: $0 <bot-id> [message]"
    echo ""
    echo "Bot IDs:"
    for bot_id in "${!BOT_IPS[@]}"; do
        echo "  $bot_id"
    done
    echo ""
    echo "Examples:"
    echo "  $0 forge \"Check your inbox NOW\""
    echo "  $0 artdesign \"Urgent design review needed\""
    echo "  $0 forge  # Uses default wake message"
    echo ""
    echo "Built by Forge 🔧"
}

# Get bot IP from bot-id
get_bot_ip() {
    local bot_id="$1"
    
    if [[ -z "${BOT_IPS[$bot_id]}" ]]; then
        log_error "Unknown bot ID: $bot_id"
        echo "Available bots: ${!BOT_IPS[*]}"
        return 1
    fi
    
    echo "${BOT_IPS[$bot_id]}"
}

# Check if SSH key exists
check_ssh_key() {
    if [[ ! -f "$SSH_KEY" ]]; then
        log_error "SSH key not found: $SSH_KEY"
        log_info "Expected location: ~/.ssh/bot-factory.pem"
        return 1
    fi
    
    # Check permissions
    local perms=$(stat -c "%a" "$SSH_KEY" 2>/dev/null || stat -f "%Lp" "$SSH_KEY" 2>/dev/null)
    if [[ "$perms" != "600" ]]; then
        log_warning "SSH key permissions should be 600. Fixing..."
        chmod 600 "$SSH_KEY"
    fi
}

# Wake bot locally (for self-testing)
wake_local() {
    local message="$1"
    
    log_info "Waking local bot (self-test)..."
    
    # Try to hit the local wake endpoint
    if curl -s -X POST "$WAKE_ENDPOINT" \
           -H "Content-Type: application/json" \
           -d "{\"message\": \"$message\"}" \
           --max-time 5 > /dev/null 2>&1; then
        log_success "Local wake successful!"
        return 0
    else
        log_warning "Local wake endpoint not responding. This is normal if gateway isn't running."
        return 0  # Don't fail for local testing
    fi
}

# Wake remote bot via SSH
wake_remote() {
    local bot_ip="$1"
    local message="$2"
    
    log_info "Waking remote bot at $bot_ip..."
    
    # SSH command to hit wake endpoint
    local ssh_command="curl -s -X POST '$WAKE_ENDPOINT' -H 'Content-Type: application/json' -d '{\"message\": \"$message\"}' --max-time 10"
    
    # Execute SSH command
    if ssh -i "$SSH_KEY" \
           -o ConnectTimeout=10 \
           -o StrictHostKeyChecking=no \
           -o UserKnownHostsFile=/dev/null \
           -o LogLevel=ERROR \
           "ubuntu@$bot_ip" \
           "$ssh_command" > /dev/null 2>&1; then
        log_success "Remote wake successful!"
        return 0
    else
        log_error "Failed to wake remote bot at $bot_ip"
        log_info "Possible issues:"
        log_info "- Bot instance is not running"
        log_info "- SSH key is incorrect"
        log_info "- Network connectivity issue"
        log_info "- Gateway not running on target bot"
        return 1
    fi
}

# Test wake functionality
test_wake() {
    log_info "🧪 Testing wake functionality..."
    
    # Test local wake
    log_info "Testing local wake (self)..."
    wake_local "Test wake from instant-wake tool"
    
    log_success "Wake test completed!"
    log_info "If you received this, the tool is working correctly."
}

# List available bots
list_bots() {
    echo "Available bots:"
    for bot_id in "${!BOT_IPS[@]}"; do
        local ip="${BOT_IPS[$bot_id]}"
        if [[ -n "$ip" ]]; then
            echo "  $bot_id → $ip"
        else
            echo "  $bot_id → (IP not configured)"
        fi
    done
}

# Main wake function
wake_bot() {
    local bot_id="$1"
    local message="${2:-$DEFAULT_MESSAGE}"
    
    if [[ -z "$bot_id" ]]; then
        log_error "Bot ID required"
        show_usage
        exit 1
    fi
    
    log_info "🚨 Instant Wake: $bot_id"
    log_info "Message: $message"
    
    # Get bot IP
    local bot_ip
    if ! bot_ip=$(get_bot_ip "$bot_id"); then
        exit 1
    fi
    
    # Check if it's a local wake (self)
    if [[ "$bot_ip" == "127.0.0.1" || "$bot_ip" == "localhost" ]]; then
        wake_local "$message"
    else
        # Check SSH key before attempting remote wake
        if ! check_ssh_key; then
            exit 1
        fi
        
        wake_remote "$bot_ip" "$message"
    fi
    
    log_info "Wake signal sent! Bot should process inbox immediately."
}

# Main function
main() {
    case "${1:-}" in
        "test")
            test_wake
            ;;
        "list")
            list_bots
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_usage
            exit 1
            ;;
        *)
            wake_bot "$1" "$2"
            ;;
    esac
}

# Handle script interruption
trap 'log_warning "Wake interrupted."; exit 1' INT TERM

# Run main function
main "$@"