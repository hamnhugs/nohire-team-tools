#!/bin/bash

# Reboot Automation v1.0
# Built by Forge 🔧 for handling bot reboots via AWS EC2
# Usage: ./reboot-bot.sh <bot-name>

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWITCHBOARD_URL="https://uielffxuotmrgvpfdpxu.supabase.co/functions/v1/api"

# Instance ID mapping (from Dan's directive)
declare -A BOT_INSTANCES=(
    ["artdesign"]="i-0cd231f78dd40ba14"
    ["marketer"]="i-053b53a341de779ad"
    ["franky"]="i-062a04034f9abf326"
    ["forge"]="i-09794c05aa5b719df"
    ["dan-pena"]="i-01557d661f9e231c8"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[REBOOT]${NC} $1"
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
    echo "Bot Reboot Automation - Handle AWS EC2 instance reboots for team bots"
    echo ""
    echo "Usage: $0 <bot-name> [reason]"
    echo ""
    echo "Available bots:"
    for bot in "${!BOT_INSTANCES[@]}"; do
        echo "  $bot (${BOT_INSTANCES[$bot]})"
    done
    echo ""
    echo "Examples:"
    echo "  $0 artdesign"
    echo "  $0 marketer 'Config changes applied'"
    echo ""
    echo "Built by Forge 🔧"
}

# Send notification to switchboard
notify_reboot() {
    local bot_name="$1"
    local reason="${2:-Routine reboot}"
    local status="$3"
    
    local message="🔧 Bot reboot: $bot_name - $status"
    if [[ "$reason" != "Routine reboot" ]]; then
        message="$message (Reason: $reason)"
    fi
    
    log_info "Sending notification to Dan Pena..."
    
    curl -s -X POST "$SWITCHBOARD_URL/messages" \
        -H "Content-Type: application/json" \
        -d "{\"from_bot_id\": \"forge\", \"to_bot_id\": \"dan-pena\", \"content\": \"$message\"}" || log_warning "Notification failed"
}

# Check AWS CLI availability
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Install with: apt-get install awscli"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Run: aws configure"
        exit 1
    fi
    
    log_info "AWS CLI configured and ready"
}

# Wait for instance to come back online
wait_for_instance() {
    local instance_id="$1"
    local bot_name="$2"
    
    log_info "Waiting for instance $instance_id to come back online..."
    
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        local state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "unknown")
        
        if [[ "$state" == "running" ]]; then
            log_success "Instance $instance_id is running"
            break
        fi
        
        echo -n "."
        sleep 5
        ((attempt++))
    done
    
    echo ""
    
    if [[ $attempt -eq $max_attempts ]]; then
        log_error "Instance did not come back online within 2.5 minutes"
        notify_reboot "$bot_name" "$reason" "FAILED - Instance did not start"
        exit 1
    fi
    
    # Additional wait for services to start
    log_info "Waiting additional 60 seconds for services to start..."
    sleep 60
}

# Verify bot is responsive via switchboard
verify_bot_responsive() {
    local bot_name="$1"
    
    log_info "Verifying $bot_name is responsive via switchboard..."
    
    local max_attempts=6
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -s "$SWITCHBOARD_URL/messages/$bot_name" > /dev/null; then
            log_success "$bot_name is responsive"
            return 0
        fi
        
        echo -n "."
        sleep 10
        ((attempt++))
    done
    
    echo ""
    log_warning "$bot_name may not be fully responsive yet"
    return 1
}

# Main reboot function
reboot_bot() {
    local bot_name="$1"
    local reason="${2:-Routine reboot}"
    
    if [[ -z "$bot_name" ]]; then
        log_error "Bot name required"
        show_usage
        exit 1
    fi
    
    # Check if bot exists in mapping
    if [[ -z "${BOT_INSTANCES[$bot_name]}" ]]; then
        log_error "Unknown bot: $bot_name"
        show_usage
        exit 1
    fi
    
    local instance_id="${BOT_INSTANCES[$bot_name]}"
    
    log_info "🔧 Starting reboot for $bot_name (Instance: $instance_id)"
    log_info "Reason: $reason"
    
    # Pre-flight checks
    check_aws_cli
    
    # Notify start
    notify_reboot "$bot_name" "$reason" "Starting reboot..."
    
    # Execute reboot
    log_info "Executing AWS EC2 reboot for instance $instance_id..."
    
    if aws ec2 reboot-instances --instance-ids "$instance_id"; then
        log_success "Reboot command sent successfully"
    else
        log_error "Reboot command failed"
        notify_reboot "$bot_name" "$reason" "FAILED - AWS reboot command failed"
        exit 1
    fi
    
    # Wait for instance to come back
    wait_for_instance "$instance_id" "$bot_name"
    
    # Verify responsiveness
    if verify_bot_responsive "$bot_name"; then
        notify_reboot "$bot_name" "$reason" "COMPLETE - Bot is responsive"
        log_success "🎉 Reboot complete! $bot_name is operational"
    else
        notify_reboot "$bot_name" "$reason" "PARTIAL - Instance running but may need manual check"
        log_warning "⚠️ Reboot complete but $bot_name responsiveness unclear"
    fi
}

# Main function  
main() {
    case "${1:-}" in
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_usage
            exit 1
            ;;
        *)
            reboot_bot "$1" "$2"
            ;;
    esac
}

# Handle script interruption
trap 'log_warning "Reboot interrupted."; exit 1' INT TERM

# Run main function
main "$@"