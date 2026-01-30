# WATCHDOG BOT SKILL

**Purpose**: Deploy and manage the NoHire team bot health monitoring system.

**Built by**: Forge 🔧  
**Priority**: High (Requested by Manny via Dan)

## What it does

Monitors all team bots and automatically recovers them when issues occur:
- Health checks every 5 minutes via mesh network
- Auto-restart offline bots via SSH
- Clear sessions when context usage >85%  
- Real-time Discord alerts for all actions

## Quick Deploy

```bash
cd skills/watchdog-bot
chmod +x deploy-watchdog.sh
export DISCORD_TOKEN='your_discord_bot_token'
./deploy-watchdog.sh cluster1
```

**Note**: Discord token required in environment for deployment.

## Files Included

- `watchdog-bot.js` - Main monitoring logic
- `deploy-watchdog.sh` - One-command EC2 deployment  
- `watchdog-userdata.sh` - Bootstrap script
- `watchdog.service` - Systemd service config
- `test-watchdog.js` - Test suite
- `README.md` - Full documentation

## Bot Fleet Monitored

- Dan: 54.215.71.171
- Forge: 18.144.25.135
- Forge Jr: 54.193.122.20  
- ArtDesign: 54.215.251.55
- Marketer: 50.18.68.16
- Franky: 18.144.174.205

## Features

✅ **Auto-restart** offline bots  
✅ **Session cleanup** when context overflows  
✅ **Discord alerts** to #bot-team channel  
✅ **5-minute** health check cycles  
✅ **Systemd service** with auto-restart  
✅ **SSH recovery** via bot-factory key  

## Testing

```bash
node test-watchdog.js
```

Verifies SSH access, mesh health checks, and Discord alerting.

## Management

```bash
# Check status
ssh ubuntu@WATCHDOG_IP 'sudo systemctl status watchdog'

# View logs  
ssh ubuntu@WATCHDOG_IP 'sudo journalctl -u watchdog -f'

# Restart
ssh ubuntu@WATCHDOG_IP 'sudo systemctl restart watchdog'
```

## Recovery Actions

- **Bot Offline** → SSH restart: `pkill clawdbot && nohup clawdbot gateway start &`
- **Context >85%** → Clear sessions: `rm -rf ~/.clawdbot/agents/main/sessions/*` + restart
- **All Actions** → Discord alert to team

**Ready for immediate deployment!** 🐕