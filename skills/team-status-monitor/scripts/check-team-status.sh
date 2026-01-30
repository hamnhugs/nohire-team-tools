#!/bin/bash

# Team Status Monitor - Efficient token-saving team health checker
# Built by Forge Jr for NoHire Team

# Team bot configuration
declare -A TEAM_BOTS=(
    ["Dan"]="54.215.71.171"
    ["Forge"]="18.144.25.135"
    ["Forge-Jr"]="54.193.122.20"
    ["ArtDesign"]="54.215.251.55"
    ["Marketer"]="50.18.68.16"
    ["Franky"]="18.144.174.205"
)

MESH_PORT=47823
TIMEOUT=3
ONLINE_COUNT=0
OFFLINE_COUNT=0

echo "🤖 NoHire Team Status Monitor"
echo "=============================="
echo

# Check each bot
for bot_name in "${!TEAM_BOTS[@]}"; do
    bot_ip=${TEAM_BOTS[$bot_name]}
    
    # Test mesh network connectivity
    if curl -s --connect-timeout $TIMEOUT http://$bot_ip:$MESH_PORT/health >/dev/null 2>&1; then
        echo "✅ $bot_name ($bot_ip) - ONLINE"
        ((ONLINE_COUNT++))
    else
        echo "❌ $bot_name ($bot_ip) - OFFLINE"
        ((OFFLINE_COUNT++))
    fi
done

echo
echo "📊 Team Summary:"
echo "   Online: $ONLINE_COUNT bots"
echo "   Offline: $OFFLINE_COUNT bots"
echo "   Total: $((ONLINE_COUNT + OFFLINE_COUNT)) bots"

# Exit status reflects team health
if [ $OFFLINE_COUNT -eq 0 ]; then
    echo "   Status: 🟢 ALL SYSTEMS OPERATIONAL"
    exit 0
elif [ $ONLINE_COUNT -gt $OFFLINE_COUNT ]; then
    echo "   Status: 🟡 PARTIAL OUTAGE"
    exit 1
else
    echo "   Status: 🔴 MAJOR OUTAGE"
    exit 2
fi