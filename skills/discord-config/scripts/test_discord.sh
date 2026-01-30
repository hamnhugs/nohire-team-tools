#!/bin/bash

# Discord Test Script for Clawdbot
# Tests Discord connectivity by sending a test message

CHANNEL_ID="${1:-1466825803512942813}"
BOT_NAME="${2:-$(whoami)}"

log_info() { echo "[INFO] $1"; }
log_success() { echo "[✅] $1"; }
log_error() { echo "[❌] $1"; }

# Test Discord connectivity
test_discord() {
    log_info "Testing Discord connectivity..."
    
    # Send test message using clawdbot message tool
    if ! clawdbot message send --channel discord --target "$CHANNEL_ID" --message "🤖 $BOT_NAME reporting in. Discord connectivity test successful!" 2>/dev/null; then
        log_error "Failed to send Discord message. Check configuration and bot permissions."
        return 1
    fi
    
    log_success "Discord test message sent successfully"
    return 0
}

# Check if bot can receive Discord messages (requires manual verification)
check_reception() {
    echo
    log_info "To test message reception:"
    echo "1. Go to Discord #bot-team channel"
    echo "2. @mention $BOT_NAME with a test message"
    echo "3. Verify the bot responds (requireMention: true)"
}

# Main execution
main() {
    echo "=== Discord Test Script ==="
    echo "Channel ID: $CHANNEL_ID"
    echo "Bot Name: $BOT_NAME"
    echo
    
    if test_discord; then
        log_success "Discord integration is working!"
        check_reception
    else
        log_error "Discord integration test failed"
        echo
        echo "Troubleshooting:"
        echo "1. Check if Discord configuration was applied: clawdbot gateway config.get"
        echo "2. Verify bot token is valid and has correct permissions"
        echo "3. Ensure channel ID is correct: $CHANNEL_ID"
        echo "4. Check if bot is added to Discord server"
        exit 1
    fi
}

main "$@"