#!/bin/bash

# Remote Discord Configuration Script
# Configures Discord on remote bots via mesh network messaging

BOT_NAME="$1"
BOT_TOKEN="${2:-$DISCORD_BOT_TOKEN}"
GUILD_ID="${3:-1466818873390272677}"
CHANNEL_ID="${4:-1466825803512942813}"
MESH_URL="http://localhost:47823"
FROM_BOT_ID="${FROM_BOT_ID:-$(whoami)}"

log_info() { echo "[INFO] $1"; }
log_success() { echo "[✅] $1"; }
log_error() { echo "[❌] $1"; }

# Validate required parameters
validate_params() {
    if [[ -z "$BOT_NAME" ]]; then
        log_error "Bot name is required!"
        echo "Usage: $0 <bot_name> [bot_token] [guild_id] [channel_id]"
        echo "Example: $0 forge"
        exit 1
    fi
}

# Check mesh network connectivity
check_mesh() {
    log_info "Checking mesh network connectivity..."
    
    if ! curl -s "$MESH_URL/health" > /dev/null; then
        log_error "Mesh network not accessible at $MESH_URL"
        exit 1
    fi
    
    log_success "Mesh network connected"
}

# Send Discord configuration via mesh network
send_config_message() {
    log_info "Sending Discord configuration to $BOT_NAME via mesh network..."
    
    # Create the configuration command with proper escaping
    local config_command="clawdbot gateway config.patch '{
  \"plugins\": {
    \"entries\": {
      \"discord\": {
        \"enabled\": true
      }
    }
  },
  \"channels\": {
    \"discord\": {
      \"enabled\": true,
      \"token\": \"$BOT_TOKEN\",
      \"groupPolicy\": \"allowlist\",
      \"dm\": {
        \"policy\": \"allowlist\"
      },
      \"guilds\": {
        \"$GUILD_ID\": {
          \"requireMention\": true,
          \"channels\": {
            \"$CHANNEL_ID\": {
              \"enabled\": true
            }
          }
        }
      }
    }
  },
  \"tools\": {
    \"message\": {
      \"crossContext\": {
        \"allowWithinProvider\": true,
        \"allowAcrossProviders\": true
      }
    }
  }
}'"

    # Send mesh message with configuration instructions
    local message="PRIORITY: Apply Discord configuration immediately. Run: $config_command. Then test with: clawdbot message send --channel discord --target $CHANNEL_ID --message \"🤖 $BOT_NAME reporting in. Discord connected.\""
    
    local response=$(curl -s -X POST "$MESH_URL/send" \
        -H "Content-Type: application/json" \
        -d "{\"from_bot_id\": \"$FROM_BOT_ID\", \"to_bot_id\": \"$BOT_NAME\", \"content\": \"$message\"}")
    
    if echo "$response" | grep -q "\"success\":true"; then
        log_success "Configuration instructions sent to $BOT_NAME"
    else
        log_error "Failed to send configuration to $BOT_NAME"
        echo "Response: $response"
        exit 1
    fi
}

# Main execution
main() {
    echo "=== Remote Discord Configuration ==="
    echo "Target Bot: $BOT_NAME"
    echo "From Bot: $FROM_BOT_ID"
    echo "Guild ID: $GUILD_ID"
    echo "Channel ID: $CHANNEL_ID"
    echo "Bot Token: ${BOT_TOKEN:0:20}..."
    echo
    
    validate_params
    check_mesh
    send_config_message
    
    echo
    log_success "Discord configuration sent to $BOT_NAME!"
    log_info "Check Discord #bot-team channel for $BOT_NAME test message"
    log_info "Allow a few minutes for the bot to process and restart"
}

# Show usage if no parameters
if [[ $# -eq 0 ]]; then
    echo "Remote Discord Configuration Script"
    echo
    echo "Usage: $0 <bot_name> [bot_token] [guild_id] [channel_id]"
    echo
    echo "Examples:"
    echo "  $0 forge"
    echo "  $0 artdesign"
    echo "  $0 marketer"
    echo
    exit 1
fi

main "$@"