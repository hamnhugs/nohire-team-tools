# Team Configuration Reference

## NoHire Team Bot Fleet

| Bot Name | IP Address | Role | Team | Mesh Port |
|----------|------------|------|------|-----------|
| Dan | 54.215.71.171 | Manager | Management | 47823 |
| Forge | 18.144.25.135 | Builder | Build Team | 47823 |
| Forge Jr | 54.193.122.20 | Builder | Build Team | 47823 |
| ArtDesign | 54.215.251.55 | Designer | Creative Team | 47823 |
| Marketer | 50.18.68.16 | Marketing | Creative Team | 47823 |
| Franky | 18.144.174.205 | Assistant | Support Team | 47823 |

## Health Check Endpoints

### Mesh Network Health
- **URL Pattern**: `http://<IP>:47823/health`
- **Expected Response**: JSON with status info
- **Timeout**: 3 seconds recommended

### SSH Connectivity  
- **Port**: 22
- **Key**: `~/.ssh/bot-factory.pem`
- **User**: ubuntu
- **Pattern**: `ssh -i ~/.ssh/bot-factory.pem ubuntu@<IP>`

## Status Interpretation

### Exit Codes
- `0`: All bots online (🟢 ALL SYSTEMS OPERATIONAL)
- `1`: Majority online (🟡 PARTIAL OUTAGE)  
- `2`: Majority offline (🔴 MAJOR OUTAGE)

### Common Scenarios
- **Context Overflow**: Bots become unresponsive, mesh health checks fail
- **Instance Issues**: SSH responds but mesh fails (clawdbot crashed)
- **Network Issues**: Both SSH and mesh fail (infrastructure problems)

## Recovery Actions

### For Mesh Failures
1. Check if clawdbot processes are running: `ps aux | grep clawdbot`
2. Restart gateway: `clawdbot gateway restart`
3. Apply token limits if context overflow detected

### For Infrastructure Issues
1. Verify EC2 instance status in AWS console
2. Check security group rules (ports 22, 47823)
3. Restart instances if needed

## Discord Integration

### Team Notifications
- **Primary Channel**: #bot-team (1466825803512942813)
- **Server**: Nohire.io (1466818873390272677)
- **Format**: Use quick-status.sh output for concise updates

### Alert Thresholds
- **Green**: All 6 bots online
- **Yellow**: 4-5 bots online  
- **Red**: 3 or fewer bots online