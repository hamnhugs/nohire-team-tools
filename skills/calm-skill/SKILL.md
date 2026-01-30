# CALM SKILL - Call to Action / Priority Mode

**Built by**: Forge 🔧  
**Priority**: High (Requested by Manny via Dan)  
**Purpose**: Allow managers to trigger priority mode across all team bots

## What it does

When a manager sends a "CALM" (Call to Action), all team bots:
- ⚡ **Speed up heartbeat** to 1 minute until tasks complete
- 🧠 **Smart heartbeat** - doesn't interrupt active work or waste tokens  
- ❄️ **Auto-cooldown** - returns to normal heartbeat when tasks done
- 📢 **Team broadcast** - notifies all bots via mesh/Discord

## Key Features

✅ **Smart Heartbeat Logic** - Only fires when bot is idle  
✅ **No Work Interruption** - Skips/queues if bot is processing  
✅ **Token Savings** - Fast heartbeat ONLY during priority  
✅ **Auto-Cooldown** - Returns to 30min heartbeat when done  
✅ **Team Coordination** - Broadcasts via mesh network + Discord  
✅ **Manual Override** - Managers can force cooldown anytime  

## Architecture

### Manager Side (calm.sh)
- `/calm trigger <task>` - Activate priority mode
- `/calm status` - Check current mode  
- `/calm cooldown` - Force return to normal
- `/calm test` - Test bot connectivity

### Bot Side (calm-heartbeat.js)  
- Process incoming CALM messages
- Adjust Clawdbot heartbeat configuration
- Track priority mode state
- Handle smart heartbeat logic

## Installation

```bash
cd skills/calm-skill
chmod +x install-calm.sh
./install-calm.sh
```

## Usage

### Manager Commands
```bash
# Trigger priority mode for all bots
./calm.sh trigger "Deploy Watchdog Bot immediately"

# Check current status
./calm.sh status

# Force cooldown to normal mode
./calm.sh cooldown

# Test connectivity to all bots
./calm.sh test

# List monitored bots
./calm.sh list-bots
```

### Bot Integration
```bash
# Process incoming CALM message (automated)
node calm-heartbeat.js process-message "PRIORITY MODE ACTIVATED..."

# Check local heartbeat status
node calm-heartbeat.js status

# Manual priority mode (testing)
node calm-heartbeat.js activate "Test task"

# Manual cooldown (testing)
node calm-heartbeat.js cooldown
```

## Team Bot Fleet

- **Dan**: 54.215.71.171:47823
- **Forge**: 18.144.25.135:47823
- **Forge Jr**: 54.193.122.20:47823
- **ArtDesign**: 54.215.251.55:47823
- **Marketer**: 50.18.68.16:47823
- **Franky**: 18.144.174.205:47823

## Heartbeat Timing

- **Normal Mode**: 30 minutes (1800s)
- **Priority Mode**: 1 minute (60s)
- **Max Priority Duration**: 4 hours (auto-cooldown)

## Smart Heartbeat Rules (Critical!)

**From Dan's Requirements:**
- ✅ Heartbeat must NOT disrupt active work
- ✅ Check if bot is mid-task before triggering
- ✅ If bot is processing → skip/queue the heartbeat  
- ✅ Only fire heartbeat when bot is idle
- ✅ Verify Clawdbot handles this properly
- ✅ 1-min heartbeat doesn't interrupt ongoing work

## Workflow Example

1. **Manager**: `./calm.sh trigger "Urgent deployment needed"`
2. **System**: Broadcasts to all 6 team bots via mesh network
3. **Bots**: Receive message, switch to 1-minute heartbeat
4. **Discord**: "#bot-team Priority mode activated" alert
5. **Bots**: Process urgent tasks with faster response
6. **Completion**: Bots report task done or auto-cooldown after 4h
7. **System**: Returns all bots to normal 30-minute heartbeat

## Files Included

- `calm.sh` - Manager command interface
- `calm-heartbeat.js` - Bot-side heartbeat manager  
- `install-calm.sh` - Installation script
- `SKILL.md` - This documentation
- `calm-config.json` - State tracking (created on use)

## Token Efficiency

- **Normal operation**: 30-minute heartbeat (minimal tokens)
- **Priority mode**: 1-minute heartbeat (only when needed)  
- **Smart logic**: No duplicate processing or work interruption
- **Auto-cooldown**: Prevents indefinite priority mode

## Discord Integration

All CALM actions generate Discord alerts:
- 🚨 **PRIORITY MODE ACTIVATED** - Task description + bot count
- ❄️ **PRIORITY MODE DEACTIVATED** - Return to normal mode
- 📊 **Status updates** - Current mode and timing

## Testing

```bash
# Test manager commands
./calm.sh test

# Test bot heartbeat manager
node calm-heartbeat.js status

# Full integration test
./calm.sh trigger "Test priority mode"
./calm.sh status  
./calm.sh cooldown
```

## Security & Reliability

- ✅ **State persistence** - Survives bot restarts
- ✅ **Auto-cooldown** - 4-hour maximum priority duration
- ✅ **Manual override** - Managers can force cooldown
- ✅ **Error handling** - Graceful fallbacks
- ✅ **No secrets** - Uses existing bot configurations

## Integration with Existing Tools

- **Mesh Network**: Primary communication channel
- **Discord**: Team notifications and status
- **Clawdbot**: Native heartbeat configuration
- **Watchdog Bot**: Will benefit from priority mode for faster recovery

**Ready for immediate deployment and testing!** 🚨