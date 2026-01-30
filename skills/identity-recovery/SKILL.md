# IDENTITY RECOVERY SKILL - Anti-Amnesia System

**Built by**: Forge 🔧  
**Priority**: URGENT (Prevents session reset amnesia)  
**Purpose**: Automate identity recovery when bots forget who they are after session resets

## The Problem

**Session Reset Amnesia**: When bots reset/restart, they forget:
- Who they are (name, role, identity)
- How they operate (workflows, habits)  
- Current tasks and context
- Team structure and communication

This causes confusion, incorrect behavior, and productivity loss.

## The Solution

Comprehensive identity recovery system with:
- ✅ **Automatic detection** of session resets
- ✅ **Instant recovery** by reading identity files
- ✅ **Manual commands** for triggered recovery
- ✅ **Startup integration** - built into bot initialization
- ✅ **Heartbeat checks** - ongoing identity verification

## Quick Install

```bash
cd skills/identity-recovery
chmod +x install-identity-recovery.sh
./install-identity-recovery.sh
```

## Available Commands

### Manual Recovery Commands
```bash
whoami          # Basic identity check - confirms who you are
recover         # Full recovery after amnesia (recommended)
context         # Show identity summary + recent memory
```

### Automatic Features
- **Startup Hook**: Detects session resets on bot startup
- **Heartbeat Integration**: First heartbeat checks identity
- **Session Monitoring**: Tracks session state for reset detection

## Identity Files Required

The system reads these files to restore identity:
- **SOUL.md** - Who you are, personality, how you work
- **IDENTITY.md** - Name, role, model, boss, core facts
- **AGENTS.md** - Team structure, workflows, communication
- **memory/YYYY-MM-DD.md** - Recent context and tasks

## Architecture

### Detection System
1. **Session State Tracking** - Monitors for reset indicators
2. **Time Gap Analysis** - Detects long inactivity periods  
3. **File Timestamps** - Checks for fresh starts
4. **Missing Context** - Identifies amnesia symptoms

### Recovery Process
1. **Detect Reset** - Automatic or manual trigger
2. **Read Identity Files** - Parse core identity information
3. **Extract Key Info** - Name, role, model, recent tasks
4. **Confirm Recovery** - Display summary and confirmation
5. **Alert Team** - Discord notification of recovery event

### Integration Points
- **Startup Hook** - `~/.bashrc` integration for auto-detection
- **Heartbeat Update** - Modified `HEARTBEAT.md` with identity checks
- **Command Aliases** - Easy access via `whoami`, `recover`, `context`
- **Session Monitoring** - Persistent state tracking

## Usage Examples

### After Session Reset (Amnesia)
```bash
# Bot feels confused, doesn't remember identity
recover

# System reads all identity files and displays:
# - SOUL.md: "I am FORGE, the Bot Creator..."
# - IDENTITY.md: "Name: FORGE, Role: Bot Creator..."  
# - AGENTS.md: "Team structure, workflows..."
# - Recent memory: Latest tasks and context

# Bot confirms: "I am FORGE, bot creator for NoHire, working for Manny"
```

### Quick Identity Check
```bash
# Fast confirmation during normal operation
whoami

# Shows basic identity info:
# NAME: FORGE
# ROLE: Bot Creator & Builder  
# MODEL: Claude Sonnet
# SOUL: I am FORGE, the Bot Creator
```

### Context Summary
```bash
# Show current identity + recent work
context

# Displays identity summary plus recent memory highlights
```

## Bot-Factory Integration

For new bot deployments, the system is automatically integrated via:

### launch-bot.sh Updates
```bash
# Add to bot deployment script:
cd /home/ubuntu/clawd/nohire-team-tools/skills/identity-recovery
./install-identity-recovery.sh
```

### Startup Integration
- **~/.bashrc** - Auto-runs identity check on shell startup
- **HEARTBEAT.md** - First heartbeat includes identity verification
- **Session State** - Persistent tracking across restarts

### Bot Blueprint Updates
All Bot Blueprints should include:
- Identity recovery system installation
- Proper SOUL.md, IDENTITY.md, AGENTS.md setup
- Session reset detection and recovery protocols

## Discord Integration

System sends team alerts for:
- 🧠 **Identity Recovery**: Bot completed identity recovery after reset
- 🚨 **Amnesia Detected**: Bot triggered manual recovery
- ✅ **Recovery Complete**: Identity restoration successful

## Files Included

- `whoami.sh` - Main identity recovery script with all commands
- `identity-startup-hook.sh` - Automatic session reset detection
- `update-heartbeat-for-identity.sh` - Heartbeat integration
- `install-identity-recovery.sh` - Complete installation automation
- `SKILL.md` - This documentation

## Prevention vs. Recovery

**Prevention** (Ideal):
- Proper session management in Clawdbot
- Context preservation across restarts
- Gradual memory compaction vs. hard resets

**Recovery** (This System):
- Detect when reset occurs despite prevention
- Instant restoration of identity and context
- Minimal downtime and confusion
- Team coordination through alerts

## Deployment Status

✅ **Ready for immediate deployment**  
✅ **All team bots should install this system**  
✅ **Bake into bot-factory for future bots**  
✅ **Testing completed on Forge instance**

## Testing

```bash
# Test identity recovery
./whoami.sh recover

# Test startup hook  
./identity-startup-hook.sh

# Test heartbeat integration
source update-heartbeat-for-identity.sh
```

**This solves the session reset amnesia problem once and for all!** 🧠🔧

**No more "Who am I?" confusion after bot resets.**