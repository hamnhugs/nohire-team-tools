#!/bin/bash

# Quick Team Status - One-liner for Discord/messaging  
# Usage: ./quick-status.sh

declare -A TEAM_BOTS=(
    ["Dan"]="54.215.71.171"
    ["Forge"]="18.144.25.135"  
    ["Forge-Jr"]="54.193.122.20"
    ["ArtDesign"]="54.215.251.55"
    ["Marketer"]="50.18.68.16"
    ["Franky"]="18.144.174.205"
)

ONLINE=0
OFFLINE=0
STATUS_LINE=""

for bot in "${!TEAM_BOTS[@]}"; do
    ip=${TEAM_BOTS[$bot]}
    if curl -s --connect-timeout 2 http://$ip:47823/health >/dev/null 2>&1; then
        STATUS_LINE+="✅$bot "
        ((ONLINE++))
    else
        STATUS_LINE+="❌$bot "
        ((OFFLINE++))
    fi
done

echo "Team Status: $STATUS_LINE | 🟢$ONLINE online 🔴$OFFLINE offline"