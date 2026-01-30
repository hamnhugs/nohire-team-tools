#!/bin/bash

# UPDATE HEARTBEAT.md FOR IDENTITY RECOVERY
# Adds mandatory identity check to heartbeat process
# Built by Forge for NoHire team anti-amnesia system

set -e

WORKSPACE_DIR="${WORKSPACE_DIR:-/home/ubuntu/clawd}"
HEARTBEAT_FILE="$WORKSPACE_DIR/HEARTBEAT.md"

# Backup original
if [[ -f "$HEARTBEAT_FILE" ]]; then
    cp "$HEARTBEAT_FILE" "$HEARTBEAT_FILE.backup"
fi

# Create updated HEARTBEAT.md with identity recovery
cat > "$HEARTBEAT_FILE" << 'EOF'
# HEARTBEAT.md

## MANDATORY FIRST CHECK - Identity Recovery
```bash
# Check if identity is intact after session reset
~/clawd/whoami.sh check
```
**If identity seems wrong or unclear, run:** `~/clawd/whoami.sh recover`

## Every Heartbeat - Check These:

### 1. Discord Communication (PRIMARY)
All team communication is now on Discord. Monitor the team channel.

### 2. Mesh Network Inbox
```bash
curl http://localhost:47823/inbox
```
Process any priority messages immediately.

### 3. Team Tools Updates
```bash
cd ~/clawd/nohire-team-tools && git pull
```

### 4. Work in Progress
- [ ] Continue any active assignments
- [ ] Push completed work to GitHub
- [ ] Update progress in Notion
- [ ] Report status to Dan Pena via Discord

## Escalation Process
- **Urgent issues**: Post in Discord team channel
- **Technical blocks**: Message forge via Discord
- **Design questions**: Message artdesign via Discord
- **Identity confusion**: Run `~/clawd/whoami.sh recover`

## Team Collaboration
- **All tools** available in ~/clawd/nohire-team-tools
- **Follow workflow**: Build → Design Review → Manager Review → Manny Approval
- **Communication**: Discord only

## Communication Channels
- **Primary**: Discord team channel (1466825803512942813)
- **Backup**: Direct Telegram to Manny if Discord fails
- **NO SWITCHBOARD**: Switchboard has been decommissioned

## Session Reset Protocol
**If you feel confused about who you are or what you're working on:**
1. Run: `~/clawd/whoami.sh recover`
2. Read the identity files it shows you
3. Confirm your role and current tasks
4. Continue with normal heartbeat process

**This is critical for preventing session reset amnesia!**
EOF

echo "✅ HEARTBEAT.md updated with identity recovery checks"
echo "📄 Original backed up as HEARTBEAT.md.backup"