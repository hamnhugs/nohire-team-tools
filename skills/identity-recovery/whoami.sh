#!/bin/bash

# IDENTITY RECOVERY SKILL - /whoami command
# Built by Forge for NoHire team identity recovery
# Reads identity files and confirms bot identity after session reset

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-/home/ubuntu/clawd}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[WHOAMI]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[IDENTITY]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    echo "Identity Recovery Skill - Know who you are after session reset"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  whoami     Read identity files and confirm who you are"
    echo "  recover    Full identity recovery (all context files)"
    echo "  context    Show current identity + recent memory"
    echo "  check      Quick identity check (name, role, model)"
    echo "  help       Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 whoami     # Basic identity confirmation"
    echo "  $0 recover    # Full recovery after amnesia"  
    echo "  $0 context    # Show current state summary"
    echo ""
    echo "Built by Forge 🔧 - Anti-amnesia system"
}

# Read and display identity file
read_identity_file() {
    local file_path="$1"
    local file_name="$2"
    
    if [[ -f "$file_path" ]]; then
        log_info "📄 Reading $file_name..."
        echo -e "${CYAN}--- $file_name ---${NC}"
        cat "$file_path"
        echo -e "${CYAN}--- End $file_name ---${NC}"
        echo ""
        return 0
    else
        log_warning "📄 $file_name not found at: $file_path"
        return 1
    fi
}

# Extract key info from identity files
extract_identity_info() {
    local soul_file="$WORKSPACE_DIR/SOUL.md"
    local identity_file="$WORKSPACE_DIR/IDENTITY.md"
    
    echo -e "${CYAN}=== IDENTITY SUMMARY ===${NC}"
    
    # Extract name from IDENTITY.md
    if [[ -f "$identity_file" ]]; then
        local name=$(grep -E "^\*\*Name:\*\*|^- \*\*Name:\*\*" "$identity_file" | head -1 | sed 's/.*Name:\*\* *//' | sed 's/\*\*.*$//')
        local role=$(grep -E "^\*\*Role:\*\*|^- \*\*Role:\*\*" "$identity_file" | head -1 | sed 's/.*Role:\*\* *//' | sed 's/\*\*.*$//')
        local model=$(grep -E "^\*\*Model:\*\*|^- \*\*Model:\*\*" "$identity_file" | head -1 | sed 's/.*Model:\*\* *//' | sed 's/\*\*.*$//')
        
        if [[ -n "$name" ]]; then
            log_success "👤 NAME: $name"
        fi
        if [[ -n "$role" ]]; then
            log_success "🔧 ROLE: $role"
        fi
        if [[ -n "$model" ]]; then
            log_success "🤖 MODEL: $model"
        fi
    fi
    
    # Extract identity from SOUL.md
    if [[ -f "$soul_file" ]]; then
        local soul_identity=$(grep -E "^I am \*\*.*\*\*" "$soul_file" | head -1 | sed 's/I am \*\*//' | sed 's/\*\*.*//')
        if [[ -n "$soul_identity" ]]; then
            log_success "✨ SOUL: I am $soul_identity"
        fi
    fi
    
    echo ""
}

# Get today's memory file
get_todays_memory() {
    local today=$(date +%Y-%m-%d)
    local memory_file="$WORKSPACE_DIR/memory/$today.md"
    
    if [[ -f "$memory_file" ]]; then
        echo "$memory_file"
    else
        # Try to find most recent memory file
        local recent_memory=$(find "$WORKSPACE_DIR/memory" -name "*.md" -type f 2>/dev/null | sort -r | head -1)
        echo "$recent_memory"
    fi
}

# Command: whoami - Basic identity confirmation
cmd_whoami() {
    log_info "🔍 BASIC IDENTITY CHECK"
    echo ""
    
    # Read core identity files
    read_identity_file "$WORKSPACE_DIR/SOUL.md" "SOUL.md"
    read_identity_file "$WORKSPACE_DIR/IDENTITY.md" "IDENTITY.md"
    
    # Show summary
    extract_identity_info
    
    log_success "✅ Basic identity check complete"
    log_info "💡 Use 'recover' for full context recovery"
}

# Command: recover - Full identity recovery
cmd_recover() {
    log_info "🚨 FULL IDENTITY RECOVERY - Session Reset Detected"
    echo ""
    
    # Read all identity files
    read_identity_file "$WORKSPACE_DIR/SOUL.md" "SOUL.md"
    read_identity_file "$WORKSPACE_DIR/IDENTITY.md" "IDENTITY.md" 
    read_identity_file "$WORKSPACE_DIR/AGENTS.md" "AGENTS.md"
    
    # Read today's memory
    local memory_file=$(get_todays_memory)
    if [[ -n "$memory_file" && -f "$memory_file" ]]; then
        local memory_name=$(basename "$memory_file")
        read_identity_file "$memory_file" "Recent Memory ($memory_name)"
    else
        log_warning "📄 No recent memory file found"
    fi
    
    # Show summary
    extract_identity_info
    
    # Recovery confirmation
    echo -e "${GREEN}🎉 IDENTITY RECOVERY COMPLETE!${NC}"
    echo ""
    log_success "You should now remember:"
    echo "  • Who you are and your role"
    echo "  • How you operate and work"  
    echo "  • Team structure and communication"
    echo "  • Recent context and tasks"
    echo ""
    log_info "💡 Next: Check mesh inbox or Discord for current tasks"
}

# Command: context - Show current identity summary
cmd_context() {
    log_info "📋 CURRENT IDENTITY & CONTEXT SUMMARY"
    echo ""
    
    # Show identity summary
    extract_identity_info
    
    # Show recent memory summary (just the header)
    local memory_file=$(get_todays_memory)
    if [[ -n "$memory_file" && -f "$memory_file" ]]; then
        local memory_name=$(basename "$memory_file")
        log_info "📅 Recent Memory: $memory_name"
        
        # Show first few lines of memory file
        echo -e "${CYAN}--- Recent Context (first 10 lines) ---${NC}"
        head -10 "$memory_file" 2>/dev/null || log_warning "Could not read memory file"
        echo -e "${CYAN}--- (use 'recover' for full memory) ---${NC}"
    fi
    
    echo ""
    log_success "📊 Context summary complete"
}

# Command: check - Quick identity check
cmd_check() {
    extract_identity_info
}

# Send Discord alert about identity recovery (if configured)
send_discord_alert() {
    local message="$1"
    
    # Try to send Discord alert (fail silently if not configured)
    if command -v clawdbot &> /dev/null; then
        clawdbot message send --channel discord --target 1466825803512942813 --message "$message" 2>/dev/null || true
    fi
}

# Main function
main() {
    local command="${1:-whoami}"
    
    case "$command" in
        "whoami")
            cmd_whoami
            ;;
        "recover")
            cmd_recover
            send_discord_alert "🧠 **Identity Recovery**: Bot completed full identity recovery after session reset"
            ;;
        "context")
            cmd_context
            ;;
        "check")
            cmd_check
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Handle script interruption
trap 'log_warning "Identity recovery interrupted."; exit 1' INT TERM

# Run main function
main "$@"