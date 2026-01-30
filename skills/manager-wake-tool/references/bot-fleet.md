# Bot Fleet Reference

## Bot Inventory

### Active Team Bots

| Bot Name | IP Address | SSH Key | Role | Team |
|----------|------------|---------|------|------|
| dan | 54.215.71.171 | bot-factory.pem | Manager | Management |
| forge | 18.144.25.135 | bot-factory.pem | Builder | Build Team |
| forge-jr | 54.193.122.20 | bot-factory.pem | Builder | Build Team |
| artdesign | 54.215.251.55 | bot-factory.pem | Designer | Creative Team |
| marketer | 50.18.68.16 | bot-factory.pem | Marketing | Creative Team |
| franky | 18.144.174.205 | bot-factory.pem | Assistant | Support Team |

## Team Compositions

### Build Team
- **forge** (primary builder)
- **forge-jr** (secondary builder)

### Creative Team  
- **artdesign** (UX/design)
- **marketer** (marketing/content)

### Management Team
- **dan** (manager/coordinator)

### Support Team
- **franky** (general assistant)

## SSH Configuration

**SSH Keys Location:**
- Cluster 1: `~/.ssh/bot-factory.pem`
- Cluster 2: `~/.ssh/bot-factory-cluster2.pem`

**SSH Command Pattern:**
```bash
ssh -i ~/.ssh/bot-factory.pem ubuntu@<IP_ADDRESS>
```

## Heartbeat Control

### Normal Operation
- **Heartbeat**: 1800000ms (30 minutes)
- **Config path**: `/home/ubuntu/.clawdbot/gateway.config`
- **Restart command**: `clawdbot gateway restart`

### Priority Mode
- **Heartbeat**: 60000ms (1 minute) 
- **Trigger method**: CALM skill or direct config patch
- **Auto-cooldown**: Via CALM skill logic

### Recovery Commands

**Wake unresponsive bot:**
```bash
ssh -i ~/.ssh/bot-factory.pem ubuntu@<IP> "pkill clawdbot && nohup clawdbot gateway start > /tmp/clawdbot.log 2>&1 &"
```

**Clear stuck sessions:**
```bash
ssh -i ~/.ssh/bot-factory.pem ubuntu@<IP> "rm -rf ~/.clawdbot/agents/main/sessions/* && clawdbot gateway restart"
```

**Update heartbeat:**
```bash
ssh -i ~/.ssh/bot-factory.pem ubuntu@<IP> "clawdbot gateway config.patch '{\"heartbeat\":{\"intervalMs\":60000}}'"
```

## Mesh Network Ports

- **Standard port**: 47823
- **Backup communication**: Discord #bot-team (1466825803512942813)
- **Health check**: `curl http://<IP>:47823/inbox`

## Security Notes

- All bots use common SSH key (bot-factory.pem)
- Mesh network uses port 47823 (open in security groups)
- Discord integration for all team communication
- SSH access requires proper key permissions (600)