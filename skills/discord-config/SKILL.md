---
name: discord-config
description: Configure Discord channels on Clawdbot instances for team communication. Use when setting up Discord integration on new bots, adding team bots to Discord servers, or troubleshooting Discord connectivity issues.
---

# Discord Config

## Overview

Automate Discord configuration for Clawdbot instances to enable team communication through Discord channels. Handles bot token setup, guild permissions, channel configuration, and connectivity testing.

## Configuration Workflow

### 1. Direct Configuration (Recommended)

Use when you have direct access to the Clawdbot instance:

```bash
# Apply Discord configuration
./scripts/configure_discord.sh [BOT_TOKEN] [GUILD_ID] [CHANNEL_ID]

# Test connectivity
./scripts/test_discord.sh [CHANNEL_ID]
```

### 2. Remote Configuration via Mesh Network

Use when configuring multiple remote bot instances:

```bash
# Send configuration to remote bot via mesh
./scripts/configure_remote_discord.sh [BOT_NAME] [BOT_TOKEN] [GUILD_ID] [CHANNEL_ID]
```

### 3. Configuration Verification

After configuration, verify the setup:

1. **Check config applied**: Look for Discord channel in bot config
2. **Test messaging**: Send test message to Discord channel  
3. **Verify mentions**: Ensure bot responds when mentioned

## Team Discord Settings

Current team Discord configuration:

- **Server**: Nohire.io
- **Guild ID**: `1466818873390272677` 
- **Channel**: #bot-team
- **Channel ID**: `1466825803512942813`
- **Bot Token**: (See references/tokens.md)

**Important**: `requireMention: true` means bots only respond when @mentioned in Discord.

## Troubleshooting

### Configuration Issues

**Problem**: Config patch fails
- **Solution**: Use the gateway tool directly instead of CLI
- **Command**: Use `gateway config.patch` with proper JSON

**Problem**: SSH access denied for remote configuration
- **Solution**: Send config via mesh network messaging
- **Alternative**: Request SSH key access from instance owner

### Connectivity Issues

**Problem**: Test message fails to send
- **Check**: Discord token validity
- **Check**: Bot permissions in Discord server
- **Check**: Channel ID accuracy

**Problem**: Bot doesn't respond to mentions
- **Check**: `requireMention: true` setting in config
- **Check**: Bot is online and connected to Discord

## Resources

### scripts/
- `configure_discord.sh` - Apply Discord configuration to local instance
- `test_discord.sh` - Send test message to verify connectivity  
- `configure_remote_discord.sh` - Configure Discord on remote bot via mesh

### references/
- `tokens.md` - Discord bot tokens and security guidelines
- `troubleshooting.md` - Common issues and detailed solutions