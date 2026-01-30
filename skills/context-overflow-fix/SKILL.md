# CONTEXT OVERFLOW FIX SKILL

**Built by FORGE for NoHire Team | Enhanced by FORGE JR**

## Purpose
Complete context overflow management system with detection, prevention, and emergency reset capabilities.

## 🎯 Complete Solution
This skill now provides **3 layers of protection**:

1. **🛡️ PREVENTION** - Proactive context management to avoid overflow
2. **📊 MONITORING** - Continuous detection with automatic alerts and triggers  
3. **🚨 EMERGENCY RESET** - Instant team-wide recovery when overflow occurs

## 🚀 Quick Start (Automated Protection)
```bash
cd ~/clawd/nohire-team-tools/skills/context-overflow-fix/
./service-manager.sh start
```
This starts both monitoring and prevention services in the background.

## 📋 Available Tools

### 1. Service Manager (RECOMMENDED)
```bash
./service-manager.sh start     # Start full protection system
./service-manager.sh status    # Check what's running
./service-manager.sh stop      # Stop all services
./service-manager.sh restart   # Restart everything
```

### 2. Context Monitor (Auto-Detection)
```bash
./context-monitor.sh monitor      # Start continuous monitoring
./context-monitor.sh status       # Check current team usage
./context-monitor.sh test-alert   # Test Discord alerts
```

**Monitoring Features:**
- ✅ Checks all team bots every 5 minutes
- ✅ Discord alerts at 75% context usage (75k tokens)
- ✅ **Auto-triggers emergency reset** at 85% usage (85k tokens)
- ✅ Verifies bot responsiveness after auto-fixes

### 3. Context Prevention (Proactive Management) 
```bash
./context-prevent.sh soft        # Gentle cleanup (all bots)
./context-prevent.sh memory      # Force memory flush (all bots) 
./context-prevent.sh rotate      # Session reset (all bots)
./context-prevent.sh auto        # Start auto-scheduled prevention
```

**Prevention Levels:**
- **Soft Cleanup**: Aggressive compaction, keeps conversation flow
- **Memory Flush**: Saves context to MEMORY.md files
- **Session Rotate**: Fresh start while preserving bot identity

### 4. Emergency Reset (Last Resort)
```bash
./context-reset.sh              # Nuclear option - immediate team reset
```

## 🔄 Automated Schedule
When `service-manager.sh start` is running:

**Prevention Schedule:**
- Every 4 hours: Soft cleanup (gentle maintenance)
- Every 8 hours: Memory flush (save context to files)
- Every 24 hours: Session rotation (fresh start)

**Monitoring Schedule:**
- Every 5 minutes: Check token usage on all bots
- Immediate: Auto-reset if any bot exceeds 85% context

## 🎯 When to Use Each Tool

### Use Prevention When:
- 📈 **Weekly maintenance** (run `soft` or `memory`)
- 🔄 **Before important tasks** (run `rotate` for fresh start)
- ⚡ **Performance feels sluggish** (run `soft` cleanup)

### Use Monitoring When:
- 🔍 **You want protection** (run `monitor` continuously)
- 📊 **Check team health** (run `status` for snapshot)
- 🚨 **Someone reports issues** (check alerts in Discord)

### Use Emergency Reset When:
- 🚨 **Multiple bots are failing** with context errors
- ⚠️ **Monitor didn't catch it** (shouldn't happen with automation)
- 💥 **Nuclear option needed** (clears everything instantly)

## 📊 Team Bots Covered
- dan (54.215.71.171)
- forge (18.144.25.135) 
- forge-jr (54.193.122.20)
- artdesign (54.215.251.55)
- marketer (50.18.68.16)
- franky (18.144.174.205)

## 🎉 What This Solves
✅ **No more manual resets** - Auto-detection and auto-fix  
✅ **No more context surprises** - Continuous monitoring with alerts  
✅ **No more emergency scrambles** - Proactive prevention keeps bots healthy  
✅ **Team-wide protection** - All bots managed simultaneously  
✅ **Discord integration** - Alerts go to #bot-team channel  
✅ **Background operation** - Set it and forget it  

## 🔧 Installation & Setup
```bash
cd ~/clawd/nohire-team-tools/skills/context-overflow-fix/
./service-manager.sh start
```

## 📱 Discord Alerts
Monitor sends alerts to Discord #bot-team channel:
- **Warning (75%)**: "⚠️ forge approaching context limit: 76000 tokens (76%)"
- **Critical (85%)**: "🚨 Emergency context reset triggered for team bots"
- **Resolved**: "✅ All bots should be responsive again"

## 🔍 Logs & Debugging
```bash
# Check service status
./service-manager.sh status

# View monitor logs
tail -f /tmp/context-monitor.log

# View prevention logs  
tail -f /tmp/context-prevent.log

# Test individual bot
ssh -i ~/.ssh/bot-factory.pem ubuntu@54.215.71.171 "clawdbot status"
```

## 🛡️ Security
- Uses SSH key authentication (bot-factory.pem)
- Non-interactive SSH connections
- Background processes with PID management
- No sensitive data in logs or command history
- Parallel execution with timeout protection

## ⚡ Performance Impact
- **Monitor**: Minimal (5-minute intervals, lightweight checks)
- **Prevention**: Scheduled during low-activity periods
- **Emergency Reset**: Fast parallel execution across team

This solution completely eliminates the "full-time job" of manually managing context overflow errors.