# CONTEXT OVERFLOW FIX SKILL

**Built by FORGE for NoHire Team**

## Purpose
Emergency reset tool for context overflow issues affecting multiple team bots simultaneously.

## What It Does
- **Emergency Reset**: Clears sessions for all team bots instantly
- **Auto Recovery**: Restarts gateways and runs identity recovery
- **Verification**: Checks bot responsiveness after reset
- **Parallel Execution**: Resets all bots simultaneously for speed

## Commands

### Emergency Reset (Immediate Use)
```bash
cd ~/clawd/nohire-team-tools/skills/context-overflow-fix/
./context-reset.sh
```

### Manual Single Bot Reset
```bash
# On target bot:
rm -rf ~/.clawdbot/agents/main/sessions/*
clawdbot gateway restart
~/clawd/whoami.sh recover
```

## When to Use
- **Context overflow errors** affecting team
- **Token limit exceeded** messages
- **Bots becoming unresponsive** due to memory issues
- **Manager reports team-wide context issues**

## What It Fixes
- ✅ Clears accumulated conversation history
- ✅ Resets token counters to zero
- ✅ Restores bot identity after session clear
- ✅ Verifies mesh network connectivity
- ✅ Gets all bots back online simultaneously

## Team Bots Covered
- dan (54.215.71.171)
- forge (18.144.25.135) 
- forge-jr (54.193.122.20)
- artdesign (54.215.251.55)
- marketer (50.18.68.16)
- franky (18.144.174.205)

## Permanent Fix Integration
This skill works with the Watchdog bot to:
- **Monitor** context usage continuously
- **Auto-trigger** resets at 85% context limit
- **Alert team** via Discord when actions taken
- **Prevent** context overflow before it happens

## Usage Example
```bash
# When team reports context overflow:
./context-reset.sh

# Output shows:
# 🚨 CONTEXT OVERFLOW EMERGENCY RESET STARTING...
# 🔄 Resetting context for dan (54.215.71.171)...
# 🔄 Resetting context for forge (18.144.25.135)...
# ✅ Reset complete for all bots
# 🔍 Verifying bot responsiveness...
# ✅ All bots responsive
```

## Troubleshooting
- **SSH connection fails**: Check bot-factory.pem key permissions
- **Bot still unresponsive**: May need manual EC2 restart
- **Identity recovery fails**: Run whoami.sh recover manually on affected bot

## Security
- Uses SSH key authentication
- Non-interactive SSH (safe for automation)
- No sensitive data in command history
- Parallel execution with timeout protection