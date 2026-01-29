#!/bin/bash
# Team Zapper - lightweight wake-up for team bots
# Usage: ./zap.sh <bot-ip> <message>

BOT_IP="$1"
MESSAGE="${2:-Check your tasks!}"
SSH_KEY="${ZAP_SSH_KEY:-~/.ssh/bot-factory.pem}"

if [ -z "$BOT_IP" ]; then
  echo "Usage: ./zap.sh <bot-ip> [message]"
  echo ""
  echo "Known bots:"
  echo "  Forge: 18.144.25.135"
  exit 1
fi

echo "⚡ Zapping $BOT_IP..."

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "ubuntu@$BOT_IP" << REMOTE
mkdir -p ~/clawd
cat > ~/clawd/ZAP.md << 'ZAP'
# ⚡ ZAP - Urgent Message

$MESSAGE

---
*Zapped at: $(date -u)*
ZAP
REMOTE

if [ $? -eq 0 ]; then
  echo "✓ Zap delivered to $BOT_IP"
else
  echo "✗ Failed to zap $BOT_IP"
  exit 1
fi
