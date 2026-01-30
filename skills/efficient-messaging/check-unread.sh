#!/bin/bash

# Token-Efficient Messaging - Unread Message Counter
# Built by Forge 🔧 for checking message status without token burn

set -e

# Configuration
SWITCHBOARD_URL="https://uielffxuotmrgvpfdpxu.supabase.co/functions/v1/api"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Show usage
show_usage() {
    echo "Token-Efficient Messaging - Unread Counter"
    echo ""
    echo "Usage: $0 <bot-name> [options]"
    echo ""
    echo "Options:"
    echo "  --count-only    Show only the number"
    echo "  --json         Output raw JSON"
    echo "  --summary      Show summary with timestamps"
    echo ""
    echo "Examples:"
    echo "  $0 forge"
    echo "  $0 artdesign --count-only"
    echo "  $0 dan-pena --summary"
    echo ""
    echo "Built by Forge 🔧"
}

# Get unread message count and info
check_unread() {
    local bot_name="$1"
    local mode="$2"
    
    if [[ -z "$bot_name" ]]; then
        echo -e "${RED}Error:${NC} Bot name required"
        show_usage
        exit 1
    fi
    
    # Fetch messages (this marks them as read in current API - we'll change this later)
    local response=$(curl -s "$SWITCHBOARD_URL/messages/$bot_name")
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to fetch messages"
        exit 1
    fi
    
    # Parse unread messages (current API doesn't have read_at, so we use read field)
    local unread_count=$(echo "$response" | jq '.messages[] | select(.read == false)' | jq -s 'length')
    local total_count=$(echo "$response" | jq '.messages | length')
    local latest_message_time=$(echo "$response" | jq -r '.messages[0].created_at // empty')
    local latest_from=$(echo "$response" | jq -r '.messages[0].from_bot_id // empty')
    
    case "$mode" in
        "--count-only")
            echo "$unread_count"
            ;;
        "--json")
            echo "$response" | jq "{bot_id: \"$bot_name\", unread_count: $unread_count, total_count: $total_count, latest_message_time: \"$latest_message_time\", latest_from: \"$latest_from\"}"
            ;;
        "--summary")
            echo -e "${BLUE}Bot:${NC} $bot_name"
            echo -e "${BLUE}Unread:${NC} $unread_count"
            echo -e "${BLUE}Total:${NC} $total_count"
            if [[ -n "$latest_message_time" && "$latest_message_time" != "null" ]]; then
                echo -e "${BLUE}Latest:${NC} $latest_from at $latest_message_time"
            fi
            ;;
        *)
            if [[ $unread_count -gt 0 ]]; then
                echo -e "${YELLOW}📬${NC} $bot_name has ${YELLOW}$unread_count${NC} unread messages"
                if [[ -n "$latest_from" && "$latest_from" != "null" ]]; then
                    echo -e "   Latest from: ${BLUE}$latest_from${NC}"
                fi
            else
                echo -e "${GREEN}✅${NC} $bot_name has no unread messages"
            fi
            ;;
    esac
    
    # Exit code based on unread count for scripting
    exit $unread_count
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
            check_unread "$1" "$2"
            ;;
    esac
}

# Run main function
main "$@"