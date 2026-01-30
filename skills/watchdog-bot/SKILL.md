# WATCHDOG BOT SKILL

**Purpose**: Deploy and manage the NoHire team bot health monitoring system.

**Built by**: Forge 🔧  
**Priority**: High (Requested by Manny via Dan)

## What it does

Monitors all team bots and automatically recovers them when issues occur:
- Health checks every 5 minutes via mesh network
- Context overflow detection every 2 minutes  
- Auto-restart offline bots via SSH
- Clear sessions when context overflow detected
- Real-time Discord alerts for all actions

## Quick Deploy

```bash
cd skills/watchdog-bot
chmod +x deploy-watchdog.sh
./deploy-watchdog.sh cluster1
```

**All credentials and keys are now automatically configured!**

## Files Included

- `watchdog-bot.js` - Main monitoring logic with context detection
- `send-discord.js` - Discord messaging helper (bypasses clawdbot issues)  
- `deploy-watchdog.sh` - Automated EC2 deployment with all fixes
- `watchdog-userdata.sh` - Bootstrap script
- `watchdog.service` - Systemd service config with proper paths
- `test-watchdog.js` - Test suite
- `README.md` - Full documentation

## Bot Fleet Monitored

- Dan: 54.215.71.171
- Forge: 18.144.25.135
- Forge Jr: 54.193.122.20  
- ArtDesign: 54.215.251.55
- Marketer: 50.18.68.16
- Franky: 18.144.174.205

## Enhanced Features (Fixed Issues)

✅ **Auto-restart** offline bots  
✅ **Context overflow detection** via clawdbot status parsing  
✅ **Session cleanup** when context overflows  
✅ **Discord alerts** via dedicated Node.js script (no clawdbot dependency)  
✅ **SSH key auto-deployment** to Watchdog instance  
✅ **5-minute** health check cycles + **2-minute** context checks  
✅ **Systemd service** with auto-restart  
✅ **Full path resolution** for systemd environment  

## FIXES APPLIED (Never Manual Again)

### 1. SSH Key Deployment
**Problem**: Watchdog couldn't connect to bots (Permission denied)  
**Fix**: Auto-copy bot-factory.pem during deployment  
**Automation**: Built into deploy-watchdog.sh  

### 2. Discord Messaging  
**Problem**: clawdbot channel errors, JSON syntax issues  
**Fix**: Dedicated Node.js script with proper escaping  
**Automation**: send-discord.js included in all deployments  

### 3. Context Overflow Detection
**Problem**: No mechanism to detect context limits  
**Fix**: Parse `clawdbot status` output every 2 minutes  
**Automation**: Built into watchdog-bot.js monitoring loop  

### 4. Systemd Configuration
**Problem**: Wrong paths, missing environment variables  
**Fix**: Full paths, proper environment setup  
**Automation**: Correct service file template  

## Testing

```bash
node test-watchdog.js
```

Verifies SSH access, mesh health checks, Discord alerting, and context detection.

## Management

```bash
# Check status
ssh ubuntu@WATCHDOG_IP 'sudo systemctl status watchdog'

# View logs  
ssh ubuntu@WATCHDOG_IP 'sudo journalctl -u watchdog -f'

# Restart
ssh ubuntu@WATCHDOG_IP 'sudo systemctl restart watchdog'
```

## Monitoring Endpoints

- **Health Check**: `http://BOT_IP:47823/health` (mesh network)
- **Context Check**: SSH + `clawdbot status` parsing
- **Discord Alerts**: Direct API via send-discord.js
- **Recovery Actions**: SSH automation with full paths

## Recovery Actions

- **Bot Offline** → SSH restart: `pkill clawdbot && nohup clawdbot gateway start &`
- **Context Overflow** → Clear sessions: `rm -rf ~/.clawdbot/agents/main/sessions/*` + restart  
- **All Actions** → Discord alert to team via Node.js script

## Architecture

```
Watchdog Instance (EC2)
├── watchdog-bot.js (main monitor)
├── send-discord.js (Discord alerts)  
├── SSH key (bot-factory.pem) 
└── Systemd service (auto-restart)

Monitors via:
├── Mesh Network (health checks)
├── SSH Commands (context + recovery)
└── Discord API (team alerts)
```

**Ready for immediate deployment - ALL ISSUES AUTOMATED!** 🐕

## Known Issues & Solutions

All previously manual fixes are now automated:
- ✅ SSH key deployment 
- ✅ Discord messaging reliability
- ✅ Context overflow detection
- ✅ Systemd configuration
- ✅ Environment variable setup

**No manual intervention required!**