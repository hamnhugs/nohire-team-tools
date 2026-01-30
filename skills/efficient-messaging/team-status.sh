#!/bin/bash

# Token-Efficient Messaging - Team Status Dashboard  
# Built by Forge 🔧 for checking all team bot message status

set -e

# Configuration
SWITCHBOARD_URL="https://uielffxuotmrgvpfdpxu.supabase.co/functions/v1/api"
TEAM_BOTS=("forge" "artdesign" "dan-pena" "marketer")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Show usage
show_usage() {
    echo "Token-Efficient Messaging - Team Status Dashboard"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --json         Output raw JSON for all bots"
    echo "  --summary      Brief summary format" 
    echo "  --alerts-only  Show only bots with unread messages"
    echo "  --bot <name>   Check specific bot only"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full team status"
    echo "  $0 --alerts-only      # Only show bots with messages"
    echo "  $0 --bot forge        # Check just forge"
    echo ""
    echo "Built by Forge 🔧"
}

# Get status for single bot
get_bot_status() {
    local bot_name="$1"
    local quiet="$2"
    
    local response=$(curl -s "$SWITCHBOARD_URL/messages/$bot_name" 2>/dev/null)
    
    if [[ $? -ne 0 || -z "$response" ]]; then
        if [[ "$quiet" != "true" ]]; then
            echo -e "  ${RED}✗${NC} $bot_name - API error"
        fi
        return 1
    fi
    
    local unread_count=$(echo "$response" | jq '.messages[] | select(.read == false)' | jq -s 'length' 2>/dev/null || echo "0")
    local total_count=$(echo "$response" | jq '.messages | length' 2>/dev/null || echo "0")
    local latest_from=$(echo "$response" | jq -r '.messages[0].from_bot_id // "none"' 2>/dev/null)
    local latest_time=$(echo "$response" | jq -r '.messages[0].created_at // "never"' 2>/dev/null)
    
    # Format timestamp if available
    local time_display="$latest_time"
    if [[ "$latest_time" != "never" && "$latest_time" != "null" ]]; then
        time_display=$(date -d "$latest_time" "+%H:%M" 2>/dev/null || echo "$latest_time")
    fi
    
    echo "$bot_name|$unread_count|$total_count|$latest_from|$time_display"
    return $unread_count
}

# Display team status
show_team_status() {
    local mode="$1"
    local specific_bot="$2"
    
    echo -e "${BOLD}📊 Team Message Status${NC}"
    echo -e "${BLUE}$(date)${NC}"
    echo ""
    
    local bots_to_check=("${TEAM_BOTS[@]}")
    if [[ -n "$specific_bot" ]]; then
        bots_to_check=("$specific_bot")
    fi
    
    local total_unread=0
    local alert_count=0
    
    for bot in "${bots_to_check[@]}"; do
        local status=$(get_bot_status "$bot" "true")
        local unread=$(echo "$status" | cut -d'|' -f2)
        local total=$(echo "$status" | cut -d'|' -f3)
        local latest_from=$(echo "$status" | cut -d'|' -f4)
        local time_display=$(echo "$status" | cut -d'|' -f5)
        
        if [[ "$unread" =~ ^[0-9]+$ ]]; then
            total_unread=$((total_unread + unread))
            
            if [[ $unread -gt 0 ]]; then
                alert_count=$((alert_count + 1))
            fi
            
            # Skip bots with no messages if alerts-only mode
            if [[ "$mode" == "--alerts-only" && $unread -eq 0 ]]; then
                continue
            fi
            
            # Display format
            if [[ $unread -gt 0 ]]; then
                if [[ $unread -ge 10 ]]; then
                    echo -e "  ${RED}🚨${NC} ${BOLD}$bot${NC}: ${RED}$unread${NC} unread (${total} total) - Latest: ${BLUE}$latest_from${NC} at $time_display"
                elif [[ $unread -ge 5 ]]; then
                    echo -e "  ${YELLOW}⚠️${NC}  ${BOLD}$bot${NC}: ${YELLOW}$unread${NC} unread (${total} total) - Latest: ${BLUE}$latest_from${NC} at $time_display"
                else
                    echo -e "  ${YELLOW}📬${NC} ${BOLD}$bot${NC}: ${YELLOW}$unread${NC} unread (${total} total) - Latest: ${BLUE}$latest_from${NC} at $time_display"
                fi
            else
                echo -e "  ${GREEN}✅${NC} ${BOLD}$bot${NC}: No unread messages (${total} total)"
            fi
        else
            echo -e "  ${RED}✗${NC} ${BOLD}$bot${NC}: Connection error"
        fi
    done
    
    echo ""
    echo -e "${BOLD}Summary:${NC}"
    echo -e "  Total unread across team: ${YELLOW}$total_unread${NC}"
    echo -e "  Bots with alerts: ${YELLOW}$alert_count${NC}/${#bots_to_check[@]}"
    
    if [[ $alert_count -eq 0 ]]; then
        echo -e "  ${GREEN}🎉 All bots caught up!${NC}"
    fi
}

# Generate JSON output
show_json_status() {
    local specific_bot="$1"
    
    local bots_to_check=("${TEAM_BOTS[@]}")
    if [[ -n "$specific_bot" ]]; then
        bots_to_check=("$specific_bot")
    fi
    
    echo "{"
    echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"team_status\": ["
    
    local first=true
    for bot in "${bots_to_check[@]}"; do
        local status=$(get_bot_status "$bot" "true")
        local unread=$(echo "$status" | cut -d'|' -f2)
        local total=$(echo "$status" | cut -d'|' -f3)
        local latest_from=$(echo "$status" | cut -d'|' -f4)
        local latest_time=$(echo "$status" | cut -d'|' -f5)
        
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        
        echo -n "    {"
        echo -n "\"bot_id\": \"$bot\", \"unread_count\": $unread, \"total_count\": $total"
        if [[ "$latest_from" != "none" ]]; then
            echo -n ", \"latest_from\": \"$latest_from\", \"latest_time\": \"$latest_time\""
        fi
        echo -n "}"
    done
    
    echo ""
    echo "  ]"
    echo "}"
}

# Main function
main() {
    local mode=""
    local specific_bot=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --json)
                mode="--json"
                shift
                ;;
            --summary)
                mode="--summary"
                shift
                ;;
            --alerts-only)
                mode="--alerts-only"
                shift
                ;;
            --bot)
                specific_bot="$2"
                shift 2
                ;;
            help|-h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    case "$mode" in
        "--json")
            show_json_status "$specific_bot"
            ;;
        *)
            show_team_status "$mode" "$specific_bot"
            ;;
    esac
}

# Run main function
main "$@"