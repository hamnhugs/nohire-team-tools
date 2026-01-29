# Instant Wake Tool ⚡

**Wake any team bot IMMEDIATELY — no waiting for heartbeat**

## What It Does

Instantly wakes up team bots by SSH-ing into their instances and hitting their local gateway wake endpoint. Solves the problem of waiting 30+ minutes for heartbeat cycles when urgent tasks need immediate attention.

## Quick Start

```bash
# Wake Forge with urgent message
./wake.sh forge "Check your inbox NOW"

# Wake ArtDesign for review
./wake.sh artdesign "Urgent design review needed" 

# Wake with default message
./wake.sh forge

# Test the tool (self-wake)
./wake.sh test
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `./wake.sh <bot-id> [message]` | Wake specific bot | `./wake.sh forge "Emergency task"` |
| `./wake.sh test` | Test wake functionality | `./wake.sh test` |
| `./wake.sh list` | Show available bots | `./wake.sh list` |

## Use Cases

### 🚨 **Urgent Task Assignment**
**Problem**: Send task to bot via Switchboard, but bot doesn't see it for 30 minutes due to heartbeat cycle.
```bash
# Send task via Switchboard, then:
./wake.sh forge "Check Switchboard - URGENT task assigned!"
# Bot processes inbox immediately ⚡
```

### 🎨 **Design Review Needed**
```bash
./wake.sh artdesign "New tool ready for UX review"
```

### 📞 **Emergency Team Communication**
```bash
./wake.sh forge "Manny needs you in chat NOW"
```

## How It Works

1. **SSH Connection**: Uses `bot-factory.pem` key to SSH into target bot's EC2 instance
2. **Wake Endpoint**: Hits local gateway endpoint: `POST http://127.0.0.1:18789/hooks/wake`
3. **Immediate Response**: Bot wakes up instantly and processes Switchboard inbox
4. **No Heartbeat Wait**: Bypasses 30+ minute heartbeat cycles completely

## Setup Requirements

### SSH Key
Tool expects SSH key at: `~/.ssh/bot-factory.pem`
```bash
# Ensure correct permissions
chmod 600 ~/.ssh/bot-factory.pem
```

### Bot IP Configuration
Edit `wake.sh` to add bot IPs:
```bash
declare -A BOT_IPS=(
    ["forge"]="127.0.0.1"        # Self-testing
    ["artdesign"]="1.2.3.4"     # ArtDesign bot IP
    ["other-bot"]="5.6.7.8"     # Add more as needed
)
```

## Available Bots

- **forge**: Tool builder bot (Forge)
- **artdesign**: Design review bot (ArtDesign)
- More bots can be added as team expands

## Troubleshooting

### "SSH key not found"
```bash
# Check if key exists
ls -la ~/.ssh/bot-factory.pem

# If missing, contact Dan Pena for SSH key
```

### "Unknown bot ID"
```bash
# See available bots
./wake.sh list

# Add new bots by editing BOT_IPS in wake.sh
```

### "Failed to wake remote bot"
Possible causes:
- Bot instance is stopped/terminated
- Network connectivity issue  
- SSH key is incorrect
- Gateway not running on target bot

### Test First
```bash
# Always test locally first
./wake.sh test
```

## Team Workflow Integration

**Before Instant Wake:**
1. Dan sends task via Switchboard ➜ 
2. Wait 30+ minutes for heartbeat ➜ 
3. Bot eventually sees task ❌

**With Instant Wake:**
1. Dan sends task via Switchboard ➜ 
2. `./wake.sh forge "Check inbox NOW"` ➜ 
3. Bot wakes instantly and processes task! ✅

## Security Notes

- Uses SSH key authentication
- Only hits local gateway endpoints (127.0.0.1)
- No external network exposure
- SSH connections are encrypted and authenticated

## Built by Forge 🔧

Solves the heartbeat delay problem for urgent team communications.

**Perfect for**: Urgent tasks, design reviews, emergency communications, time-sensitive workflows