# WATCHDOG BOT - Team Bot Health Monitor

Built by Forge for the NoHire team bot fleet.

## Purpose

Monitors all team bots and automatically recovers them when issues occur:
- Health checks every 5 minutes
- Auto-restart offline bots
- Clear sessions when context usage >85%
- Alert team via Discord when actions taken

## Bot Fleet Monitored

- **Dan**: 54.215.71.171 (Team Manager)
- **Forge**: 18.144.25.135 (Tool Builder)  
- **Forge Jr**: 54.193.122.20 (Assistant Tool Builder)
- **ArtDesign**: 54.215.251.55 (Designer)
- **Marketer**: 50.18.68.16 (Marketing)
- **Franky**: 18.144.174.205 (Support)

## Features

### Health Monitoring
- Checks mesh network endpoints (`http://bot-ip:47823/health`)
- Detects offline/unresponsive bots
- Monitors context usage levels
- 30-second timeout per bot

### Auto-Recovery Actions
- **Bot Offline**: SSH restart (`pkill clawdbot && nohup clawdbot gateway start &`)
- **Context Overflow**: Clear sessions (`rm -rf ~/.clawdbot/agents/main/sessions/*`) + restart
- **Discord Alerts**: Real-time notifications to #bot-team channel

### Deployment
- **Model**: Claude Sonnet (same as Forge)
- **Platform**: Dedicated EC2 instance
- **Service**: Systemd service with auto-restart
- **Monitoring**: Discord alerts for all actions

## Files

- `watchdog-bot.js` - Main monitoring logic
- `deploy-watchdog.sh` - EC2 deployment script
- `watchdog-userdata.sh` - Bootstrap script
- `watchdog.service` - Systemd service config
- `test-watchdog.js` - Test suite
- `package.json` - Node.js package config

## Deployment

1. **Run deployment script**:
   ```bash
   chmod +x deploy-watchdog.sh
   ./deploy-watchdog.sh cluster1
   ```

2. **Monitor deployment**:
   ```bash
   # Check Discord #bot-team for "WATCHDOG ONLINE" message
   ```

3. **Verify operation**:
   ```bash
   ssh -i ~/.ssh/bot-factory.pem ubuntu@WATCHDOG_IP
   sudo systemctl status watchdog
   sudo journalctl -u watchdog -f
   ```

## Testing

Run test suite before deployment:
```bash
node test-watchdog.js
```

Tests verify:
- ✅ Configuration loading
- ✅ SSH connectivity to team bots
- ✅ Mesh network health checks
- ✅ Discord alerting functionality

## Management

### Check Status
```bash
ssh ubuntu@WATCHDOG_IP 'sudo systemctl status watchdog'
```

### View Logs
```bash
ssh ubuntu@WATCHDOG_IP 'sudo journalctl -u watchdog -f'
```

### Restart Service
```bash
ssh ubuntu@WATCHDOG_IP 'sudo systemctl restart watchdog'
```

### Manual Health Check
```bash
ssh ubuntu@WATCHDOG_IP 'cd /home/ubuntu/watchdog && node -e "require(\"./watchdog-bot\").runHealthChecks()"'
```

## Security

- SSH access via `~/.ssh/bot-factory.pem` key
- Discord token stored securely in systemd environment
- Read-only access to other bot instances
- Isolated systemd service with security restrictions

## Architecture

```
Watchdog Bot (New EC2)
├── Health Check Timer (5 min)
├── SSH Recovery Client
├── Discord Alert Client
└── Mesh Network Monitor
    ├── Dan Bot (:47823/health)
    ├── Forge Bot (:47823/health)
    ├── Forge Jr Bot (:47823/health)
    ├── ArtDesign Bot (:47823/health)
    ├── Marketer Bot (:47823/health)
    └── Franky Bot (:47823/health)
```

## Alerts

All actions generate Discord alerts:
- 🐕 **WATCHDOG ONLINE**: Service started
- 🔄 **WATCHDOG ACTION**: Bot restarted
- 🧹 **WATCHDOG ACTION**: Sessions cleared
- 🚨 **WATCHDOG ERROR**: Issue with monitoring
- 🛑 **WATCHDOG OFFLINE**: Service stopped

## Recovery Time

- **Detection**: Up to 5 minutes (health check interval)
- **SSH Restart**: ~10-15 seconds
- **Bot Recovery**: ~30-60 seconds (Clawdbot startup)
- **Total**: ~2-3 minutes maximum downtime

Built by Forge 🔧 for NoHire team reliability.