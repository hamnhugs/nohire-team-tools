#!/bin/bash

# IDENTITY STARTUP HOOK
# Detects session reset and triggers automatic identity recovery
# Built by Forge for NoHire team anti-amnesia system

set -e

# Configuration
WORKSPACE_DIR="${WORKSPACE_DIR:-/home/ubuntu/clawd}"
IDENTITY_RECOVERY_SCRIPT="$WORKSPACE_DIR/whoami.sh"
SESSION_STATE_FILE="$HOME/.clawdbot/session-state.json"
IDENTITY_LOG="$WORKSPACE_DIR/identity-recovery.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${CYAN}[IDENTITY-HOOK]${NC} $1" | tee -a "$IDENTITY_LOG"
}

log_success() {
    echo -e "${GREEN}[RECOVERED]${NC} $1" | tee -a "$IDENTITY_LOG"
}

log_warning() {
    echo -e "${YELLOW}[AMNESIA]${NC} $1" | tee -a "$IDENTITY_LOG"
}

# Check if this is a fresh session (potential reset)
detect_session_reset() {
    local current_time=$(date +%s)
    local reset_detected=false
    
    # Check if session state file exists
    if [[ ! -f "$SESSION_STATE_FILE" ]]; then
        log_warning "🔄 No session state found - potential fresh start"
        reset_detected=true
    else
        # Check last update time
        local last_update=$(jq -r '.last_update // 0' "$SESSION_STATE_FILE" 2>/dev/null || echo "0")
        local time_diff=$((current_time - last_update))
        
        # If more than 1 hour since last update, consider it a reset
        if [[ $time_diff -gt 3600 ]]; then
            log_warning "🕐 Session inactive for ${time_diff}s - potential reset"
            reset_detected=true
        fi
    fi
    
    # Update session state
    mkdir -p "$(dirname "$SESSION_STATE_FILE")"
    cat > "$SESSION_STATE_FILE" << EOF
{
    "last_update": $current_time,
    "startup_time": "$current_time",
    "reset_detected": $reset_detected,
    "recovery_triggered": false
}
EOF
    
    echo "$reset_detected"
}

# Trigger identity recovery
trigger_identity_recovery() {
    log_warning "🚨 SESSION RESET DETECTED - Triggering identity recovery..."
    
    if [[ -x "$IDENTITY_RECOVERY_SCRIPT" ]]; then
        log_info "🔧 Running identity recovery script..."
        
        # Run recovery script
        if "$IDENTITY_RECOVERY_SCRIPT" recover; then
            log_success "✅ Identity recovery completed successfully"
            
            # Update session state to mark recovery as complete
            local current_time=$(date +%s)
            local temp_state=$(mktemp)
            jq ".recovery_triggered = true | .recovery_time = $current_time" "$SESSION_STATE_FILE" > "$temp_state"
            mv "$temp_state" "$SESSION_STATE_FILE"
            
            return 0
        else
            log_warning "⚠️ Identity recovery script failed"
            return 1
        fi
    else
        log_warning "❌ Identity recovery script not found or not executable: $IDENTITY_RECOVERY_SCRIPT"
        
        # Fallback - show basic recovery prompt
        echo ""
        echo -e "${YELLOW}🧠 MANUAL IDENTITY RECOVERY NEEDED:${NC}"
        echo "  1. Read ~/clawd/SOUL.md (who you are)"
        echo "  2. Read ~/clawd/IDENTITY.md (name, role, model)" 
        echo "  3. Read ~/clawd/AGENTS.md (how to operate)"
        echo "  4. Read ~/clawd/memory/$(date +%Y-%m-%d).md (recent context)"
        echo ""
        return 1
    fi
}

# Check for required identity files
check_identity_files() {
    local missing_files=()
    
    local required_files=(
        "$WORKSPACE_DIR/SOUL.md"
        "$WORKSPACE_DIR/IDENTITY.md"
        "$WORKSPACE_DIR/AGENTS.md"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$(basename "$file")")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_warning "❌ Missing identity files: ${missing_files[*]}"
        return 1
    else
        log_info "✅ All identity files present"
        return 0
    fi
}

# Main startup hook logic
main() {
    log_info "🚀 Identity startup hook activated"
    
    # Check for required identity files
    if ! check_identity_files; then
        log_warning "⚠️ Identity files missing - recovery may be incomplete"
    fi
    
    # Detect if session was reset
    local reset_detected=$(detect_session_reset)
    
    if [[ "$reset_detected" == "true" ]]; then
        # Session reset detected - trigger recovery
        trigger_identity_recovery
    else
        log_info "✅ No session reset detected - identity should be intact"
        
        # Quick identity confirmation
        if [[ -x "$IDENTITY_RECOVERY_SCRIPT" ]]; then
            "$IDENTITY_RECOVERY_SCRIPT" check
        fi
    fi
    
    log_success "🎯 Identity startup hook complete"
}

# Run main function if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Export function for use by other scripts
export -f detect_session_reset trigger_identity_recovery check_identity_files