# Token-Efficient Messaging System - Technical Specification

**Built by Forge 🔧 per Dan's requirement for token reduction**

## Problem Statement
Current team communication burns unnecessary tokens when bots send acknowledgment messages like "Acknowledged, will do" or "Received, starting work." The LLM processing cost is the primary expense, not response length.

## Solution Architecture

### Phase 1: Switchboard API Enhancement
Modify the existing Supabase Edge Function to add read receipt functionality.

#### Database Schema Changes
```sql
-- Add read tracking to messages table
ALTER TABLE messages ADD COLUMN read_at TIMESTAMP NULL;
ALTER TABLE messages ADD COLUMN read_by TEXT NULL;
CREATE INDEX idx_messages_read_status ON messages(to_bot_id, read_at);
```

#### API Endpoint Changes

**Enhanced GET /messages/{bot-id}**
```http
GET /messages/forge
Response: 200 OK
{
  "bot_id": "forge",
  "messages": [
    {
      "id": "uuid",
      "from_bot_id": "dan-pena", 
      "to_bot_id": "forge",
      "content": "Build the reboot system",
      "read": false,
      "read_at": null,
      "created_at": "2026-01-30T01:00:00Z"
    }
  ],
  "unread_count": 5,
  "total_count": 47
}
```

**Auto-mark as read behavior:**
- When GET /messages/{bot-id} is called, mark all returned messages as read
- Set `read_at` to current timestamp
- Set `read_by` to the requesting bot_id

**New GET /messages/{bot-id}?unread_only=true**
```http  
GET /messages/forge?unread_only=true
Response: 200 OK
{
  "bot_id": "forge", 
  "messages": [...], // Only unread messages
  "unread_count": 3
}
```

**New GET /messages/{bot-id}/unread-count**
```http
GET /messages/forge/unread-count
Response: 200 OK
{
  "bot_id": "forge",
  "unread_count": 3,
  "last_message_at": "2026-01-30T02:00:00Z"
}
```

### Phase 2: Team Communication Policy
**New Rule: "Only respond when action is needed"**

| Message Type | Bot Response |
|--------------|--------------|
| Task assignment | Do the work, then report completion |
| Question for you | Answer the question |
| Information request | Provide the requested information |  
| Status update/FYI | **SILENCE** (read receipt = acknowledgment) |
| Confirmation needed | Explicit confirmation only |

### Phase 3: Read Receipt Dashboard
Optional: Build a simple dashboard for Dan to see message read status without asking bots.

## Implementation Plan

### Step 1: Supabase Function Update
```javascript
// In the existing Edge Function
export default async function handler(req) {
  const { bot_id } = req.params;
  const { unread_only } = req.query;
  
  if (req.method === 'GET') {
    // Get messages
    let query = supabase
      .from('messages')
      .select('*')
      .eq('to_bot_id', bot_id)
      .order('created_at', { ascending: false });
    
    if (unread_only === 'true') {
      query = query.is('read_at', null);
    }
    
    const { data: messages, error } = await query;
    
    if (!unread_only) {
      // Mark messages as read
      await supabase
        .from('messages')
        .update({ 
          read_at: new Date().toISOString(),
          read_by: bot_id 
        })
        .eq('to_bot_id', bot_id)
        .is('read_at', null);
    }
    
    const unread_count = await getUnreadCount(bot_id);
    
    return new Response(JSON.stringify({
      bot_id,
      messages,
      unread_count,
      total_count: messages.length
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

### Step 2: Bot Behavior Updates
Update all bots' HEARTBEAT.md and communication habits:

```bash
# Instead of calling messages and responding "Acknowledged"
curl -s "$SWITCHBOARD_URL/messages/forge" | jq

# New behavior: Just check unread count
curl -s "$SWITCHBOARD_URL/messages/forge/unread-count" | jq
```

### Step 3: Wrapper Tools
Create helper scripts for common operations:

```bash
./check-unread.sh forge        # Quick unread count
./mark-all-read.sh forge       # Mark all as read without responding  
./read-latest.sh forge 5       # Read latest 5 without auto-marking
```

## Benefits
- **Token Reduction**: Eliminate ~50% of acknowledgment messages
- **Faster Communication**: Dan can see read status without waiting for responses
- **Cleaner Chat**: Less noise, more signal
- **Cost Savings**: Significant reduction in LLM processing costs

## Metrics to Track
- **Pre-implementation**: Messages per day, token usage per bot
- **Post-implementation**: Reduction in acknowledgment messages, cost savings
- **Read Receipt Usage**: How often read receipts replace verbal confirmations

## Rollout Plan
1. **Technical Implementation** - Supabase function updates (1-2 days)
2. **Bot Updates** - Update communication patterns (1 day)
3. **Team Training** - New communication policy (immediate)
4. **Monitoring** - Track token reduction metrics (ongoing)

## Risk Mitigation
- **Gradual Rollout** - Test with 1-2 bots first
- **Fallback** - Keep verbal confirmations for critical messages
- **Monitoring** - Ensure important messages aren't missed
- **Clear Policy** - Explicit rules for when to respond vs. stay silent

---
**Next Steps**: Implement Supabase function changes, update bot communication patterns, deploy wrapper tools.