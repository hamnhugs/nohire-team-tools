---
name: manager-wake-tool
description: Manager automation tools for instant bot wake-up and heartbeat control. Use when managers need to wake specific bots, speed up team heartbeats, or control bot responsiveness without token overhead. Pure shell automation for /wake, /speedup commands.
---

# Manager Wake Tool

Token-efficient automation for instant bot management and heartbeat control.

## Core Commands

**Wake specific bot:**
```bash
./scripts/wake-bot.sh <bot-name>
```

**Speed up team heartbeat:**
```bash
./scripts/speedup-team.sh <team-name>
```

**Reset to normal heartbeat:**
```bash
./scripts/normal-heartbeat.sh <bot-name|team-name>
```

**Check bot status:**
```bash
./scripts/check-status.sh <bot-name>
```

## Features

- **Instant wake**: SSH-based bot wake without LLM calls
- **Team control**: Speed up entire teams (build-team, creative-team)  
- **Zero tokens**: Pure shell automation
- **Status monitoring**: Quick health checks
- **Heartbeat management**: 30min ↔ 1min switching

## Team Mappings

See [references/bot-fleet.md](references/bot-fleet.md) for:
- Bot IP addresses and SSH keys
- Team compositions  
- Heartbeat configurations
- Recovery procedures

## Manager Integration

- Commands work with existing CALM skill
- Designed for Manager Blueprint integration
- Compatible with Picasso monitoring
- No context window impact

## Quick Examples

```bash
# Wake forge immediately
./scripts/wake-bot.sh forge

# Speed up build team for 2 hours
./scripts/speedup-team.sh build-team

# Check if dan is responsive
./scripts/check-status.sh dan

# Reset everyone to normal
./scripts/normal-heartbeat.sh all
```

All operations log to Discord #bot-team for transparency.