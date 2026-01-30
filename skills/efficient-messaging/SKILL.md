# Token-Efficient Messaging System

**Built by Forge 🔧 to reduce unnecessary token burn from acknowledgment messages**

## Problem Solved
Eliminates token waste from bots sending "Acknowledged, will do" and similar confirmations. Read receipts provide acknowledgment without LLM processing costs.

## Current Tools (Phase 1)

### check-unread.sh
Check unread message count for any bot without burning tokens on acknowledgments.

```bash
./check-unread.sh forge                    # Standard format  
./check-unread.sh artdesign --count-only   # Just the number
./check-unread.sh dan-pena --summary       # Detailed info
./check-unread.sh forge --json             # Raw JSON output
```

**Exit codes:** Returns unread count as exit code for scripting.

### team-status.sh  
Team-wide message dashboard for monitoring all bots at once.

```bash
./team-status.sh                     # Full team status
./team-status.sh --alerts-only       # Only bots with unread messages  
./team-status.sh --bot forge         # Check specific bot
./team-status.sh --json              # JSON output for automation
```

**Output example:**
```
📊 Team Message Status
Wed Jan 30 02:30:45 UTC 2026

  🚨 forge: 12 unread (47 total) - Latest: dan-pena at 02:28
  ✅ artdesign: No unread messages (8 total)
  ⚠️  marketer: 6 unread (23 total) - Latest: dan-pena at 02:25

Summary:
  Total unread across team: 18
  Bots with alerts: 2/3
```

## New Communication Policy

### When to Respond vs. Stay Silent

| Message Type | Bot Action | Example |
|--------------|------------|---------|
| **Task Assignment** | Do work, report completion | "Build the reboot system" → Build it, then report "Reboot system complete" |
| **Direct Question** | Answer the question | "What's the status?" → Provide status update |
| **Request for Information** | Provide information | "Show me the logs" → Share logs |
| **FYI/Status Update** | **STAY SILENT** | "FYI: Config updated" → Read receipt = acknowledgment |
| **Confirmation Needed** | Explicit confirmation only | "Confirm you received this" → Confirm explicitly |
| **Error Reports** | Acknowledge + action plan | "Bug found" → "Acknowledged, investigating" |

### Token-Saving Rules
- ✅ **Silence = Acknowledgment** for informational messages
- ✅ **Read receipts** replace verbal confirmations
- ✅ **Action-only responses** for tasks (do the work, skip the "will do")
- ❌ **No more "Acknowledged"** messages for routine updates
- ❌ **No more "Starting work"** messages unless specifically requested

## API Specification (Phase 2)

### Planned Switchboard Enhancements
When the Supabase Edge Function is updated:

```bash
# New endpoints:
GET /messages/forge/unread-count        # Just count, no marking as read
GET /messages/forge?unread_only=true    # Only unread messages  
GET /messages/forge                     # Auto-marks as read
```

### Enhanced Message Format
```json
{
  "id": "uuid",
  "from_bot_id": "dan-pena",
  "to_bot_id": "forge", 
  "content": "Build reboot system",
  "read": false,
  "read_at": null,                      # NEW: When marked as read
  "read_by": null,                      # NEW: Which bot read it
  "created_at": "2026-01-30T02:00:00Z"
}
```

## Usage Patterns

### For Dan Pena (Message Sender)
```bash
# Check if bots read your messages without asking them
./team-status.sh --alerts-only

# See who's caught up  
./team-status.sh

# Check specific bot's responsiveness
./check-unread.sh forge --summary
```

### For Team Bots (Message Recipients)  
```bash
# Check unread count in HEARTBEAT.md without auto-marking as read
unread=$(./check-unread.sh $bot_name --count-only)
if [[ $unread -gt 0 ]]; then
    # Process messages only when there are some
    curl -s "$SWITCHBOARD_URL/messages/$bot_name" | jq
fi
```

## Integration Examples

### Updated HEARTBEAT.md Pattern
```bash
# OLD (burns tokens):
curl -s "$SWITCHBOARD_URL/messages/forge" | jq
# Always marks as read, bot often responds "Acknowledged"

# NEW (token efficient):
unread_count=$(./check-unread.sh forge --count-only) 
if [[ $unread_count -gt 0 ]]; then
    # Only fetch and process when there are messages
    curl -s "$SWITCHBOARD_URL/messages/forge" | jq
    # Only respond when action is needed
fi
```

### Dashboard for Dan
```bash
# Quick team check
./team-status.sh --alerts-only

# Monitor bot responsiveness
while true; do
    clear
    ./team-status.sh
    sleep 30
done
```

## Metrics & Benefits

### Token Reduction Estimates
- **Current**: ~50 acknowledgment messages per day across team
- **With read receipts**: ~5 explicit confirmations per day  
- **Estimated savings**: 90% reduction in acknowledgment tokens
- **Cost impact**: Significant reduction in LLM processing costs

### Communication Efficiency  
- **Faster status checks** for Dan (no waiting for bot responses)
- **Cleaner message logs** (less noise, more signal)
- **Preserved important confirmations** (only when truly needed)

## Installation

```bash
cd ~/clawd/nohire-team-tools/skills/efficient-messaging/
./install.sh
```

### Requirements
- `curl` (for API calls)
- `jq` (for JSON parsing)
- Access to Switchboard API

## Rollout Strategy

### Phase 1: Wrapper Tools (Current)
- ✅ `check-unread.sh` and `team-status.sh` deployed
- ✅ New communication policy defined
- ⏳ Update bot HEARTBEAT.md patterns
- ⏳ Team training on new response rules

### Phase 2: API Enhancement
- ⏳ Supabase Edge Function updates
- ⏳ Database schema changes for read receipts
- ⏳ Migration of existing bots to new endpoints

### Phase 3: Advanced Features  
- ⏳ Read receipt dashboard
- ⏳ Message priority levels  
- ⏳ Automated silence/response decisions

## Future Enhancements
- **Message Priority Levels** - Critical/Normal/FYI with different response rules
- **Auto-silence Mode** - Bots automatically stay silent for certain message types
- **Read Receipt Dashboard** - Web interface for Dan to monitor team status
- **Analytics** - Token usage tracking and savings reports
- **Smart Responses** - AI-powered decision on when to respond vs. stay silent

## Team Benefits
- **Dan**: Instant read status visibility, reduced token costs, cleaner communication
- **Bots**: Less pressure to acknowledge every message, focus on action items
- **Team**: More efficient coordination, better signal-to-noise ratio

---
**Contact:** Message `forge` via Switchboard for implementation questions or enhancements.