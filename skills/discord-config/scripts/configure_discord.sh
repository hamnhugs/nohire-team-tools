#!/bin/bash

# Discord Configuration Script for Clawdbot
# Configures Discord channel integration with proper settings

BOT_TOKEN="${1:-$DISCORD_BOT_TOKEN}"
GUILD_ID="${2:-1466818873390272677}"
CHANNEL_ID="${3:-1466825803512942813}"

log_info() { echo "[INFO] $1"; }
log_success() { echo "[✅] $1"; }
log_error() { echo "[❌] $1"; }

# Check if clawdbot is available
check_clawdbot() {
    log_info "Checking Clawdbot availability..."
    if ! command -v clawdbot &> /dev/null; then
        log_error "clawdbot command not found. Make sure it's installed and in PATH."
        exit 1
    fi
    log_success "Clawdbot found"
}

# Apply Discord configuration
configure_discord() {
    log_info "Applying Discord configuration..."
    
    # Create configuration JSON
    cat > /tmp/discord_config.json << EOF
{
  "plugins": {
    "entries": {
      "discord": {
        "enabled": true
      }
    }
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "$BOT_TOKEN",
      "groupPolicy": "allowlist",
      "dm": {
        "policy": "allowlist"
      },
      "guilds": {
        "$GUILD_ID": {
          "requireMention": true,
          "channels": {
            "$CHANNEL_ID": {
              "enabled": true
            }
          }
        }
      }
    }
  },
  "tools": {
    "message": {
      "crossContext": {
        "allowWithinProvider": true,
        "allowAcrossProviders": true
      }
    }
  }
}
EOF

    # Apply configuration using direct gateway tool call
    if ! clawdbot gateway config.patch "$(cat /tmp/discord_config.json)" 2>/dev/null; then
        log_error "Failed to apply Discord configuration. Check if gateway is running."
        rm -f /tmp/discord_config.json
        exit 1
    fi
    
    rm -f /tmp/discord_config.json
    log_success "Discord configuration applied successfully"
    log_info "Bot will restart automatically to apply changes"
}

# Main execution
main() {
    echo "=== Discord Configuration Script ==="
    echo "Bot Token: ${BOT_TOKEN:0:20}..."
    echo "Guild ID: $GUILD_ID"
    echo "Channel ID: $CHANNEL_ID"
    echo
    
    check_clawdbot
    configure_discord
    
    echo
    log_success "Discord configuration complete!"
    log_info "Run ./test_discord.sh $CHANNEL_ID to test connectivity"
}

main "$@"