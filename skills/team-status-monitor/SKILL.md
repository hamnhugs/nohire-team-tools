---
name: team-status-monitor
description: Efficient team health monitoring for NoHire bot fleet. Token-saving status checks via mesh network connectivity. Use when checking team bot availability, diagnosing outages, monitoring system health, or providing status updates to Discord/managers without expensive individual bot queries.
---

# Team Status Monitor

## Overview

Provides efficient monitoring of NoHire team bot health through mesh network connectivity checks. Designed to save tokens by replacing individual bot queries with automated scripts that check all team members simultaneously.

## Quick Commands

### Full Team Status Check
```bash
./scripts/check-team-status.sh
```
**Output:** Detailed status report with summary statistics and health indicators
**Use for:** Comprehensive system health assessment, troubleshooting, documentation

### Discord/Messaging Quick Status  
```bash
./scripts/quick-status.sh
```
**Output:** One-liner format perfect for Discord updates  
**Use for:** Team notifications, manager updates, status broadcasts

## Core Capabilities

### 1. Mesh Network Health Monitoring
- Tests connectivity to each bot's mesh network endpoint (port 47823)
- 3-second timeout prevents hanging on unresponsive bots
- Distinguishes between network issues vs process crashes

### 2. Automated Status Classification
- **🟢 Green**: All 6 bots online (exit code 0)
- **🟡 Yellow**: Partial outage - majority online (exit code 1)  
- **🔴 Red**: Major outage - majority offline (exit code 2)

### 3. Token-Efficient Reporting
- Eliminates need for individual bot queries that consume context
- Provides same information as manual checks in fraction of tokens
- Optimized output formats for different use cases

## Team Configuration

Current NoHire bot fleet monitored:
- **Dan** (54.215.71.171) - Manager
- **Forge** (18.144.25.135) - Builder  
- **Forge Jr** (54.193.122.20) - Builder
- **ArtDesign** (54.215.251.55) - Designer
- **Marketer** (50.18.68.16) - Marketing
- **Franky** (18.144.174.205) - Assistant

For detailed configuration, troubleshooting steps, and recovery procedures, see [team-config.md](references/team-config.md).

## Integration Examples

### Discord Status Updates
```bash
# Quick team notification
./scripts/quick-status.sh | clawdbot message send --channel discord --target 1466825803512942813 --message "$(cat -)"
```

### Manager Notifications  
```bash
# Full status for manager review
./scripts/check-team-status.sh > team_status_$(date +%Y%m%d_%H%M).txt
```

### Automated Monitoring
```bash
# Exit codes enable automation
if ./scripts/quick-status.sh >/dev/null; then
    echo "Team healthy"
else
    echo "Team issues detected - investigate"
fi
```

## When to Use This Skill

- **Before major operations**: Verify team availability 
- **During incident response**: Quick assessment of affected systems
- **For status reporting**: Efficient updates to Discord/managers  
- **Token conservation**: Replace manual individual bot checks
- **System monitoring**: Automated health verification

## Resources

### scripts/
- `check-team-status.sh` - Comprehensive status report with summary statistics
- `quick-status.sh` - Concise one-liner output for notifications

### references/  
- `team-config.md` - Complete team configuration, troubleshooting guides, and recovery procedures