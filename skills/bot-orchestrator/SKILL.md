---
name: bot-orchestrator
description: Enterprise-grade Bot Management System for managing, monitoring, and deploying AI bots at scale. Replaces manual bot creation with intelligent automation including health monitoring and automated recovery.
---

# Bot Orchestrator 🤖🎛️

Enterprise-grade Bot Management System built by **Forge 🔧** for intelligent bot automation.

## Purpose

Comprehensive system for managing, monitoring, and deploying AI bots at scale. Replaces manual bot creation and monitoring with intelligent automation.

### Key Problems Solved
- **Manual Bot Deployment** → Automated provisioning with optimal configurations
- **No Health Monitoring** → Real-time health tracking with predictive alerts  
- **Manual Recovery** → Automated incident detection and recovery procedures
- **Configuration Drift** → Centralized configuration management with rollback
- **Resource Waste** → Intelligent instance sizing and cost optimization

## Quick Start

```bash
# Deploy the orchestrator system
./deploy-orchestrator.sh

# Start monitoring
npm install
node orchestrator.js

# Run tests
node test.js
```

## Core Components

1. **Intelligent Provisioning Engine**
   - Type-specific instance sizing (t3.micro → t3.large)
   - Optimal model selection (Haiku → Sonnet → Opus)
   - Automated configuration deployment
   - Performance optimization settings

2. **Real-time Health Monitoring**
   - Comprehensive health scoring (0-100)
   - Multi-metric analysis (response time, endpoint health, mesh connectivity)
   - 24-hour health history tracking
   - Predictive failure detection

3. **Automated Recovery System**
   - Emergency response procedures (restart → reboot → redeploy)
   - Automated failure detection and response
   - Recovery success verification
   - Escalation and alerting

## Usage

### Deploy New Bot
```bash
# Deploy with specific configuration
./deploy-orchestrator.sh create-bot <bot-type> <cluster>
```

### Monitor Fleet Health
```bash
# Check all bots
node orchestrator.js --mode monitor

# Check specific bot
node orchestrator.js --bot <bot-id> --health-check
```

### Recovery Actions
```bash
# Auto-recover offline bot
node orchestrator.js --bot <bot-id> --recover

# Emergency restart
node orchestrator.js --bot <bot-id> --emergency-restart
```

## Prerequisites

- AWS CLI configured with proper permissions
- SSH key: ~/.ssh/bot-factory.pem
- Node.js environment
- Network access to target instances

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Dashboard     │◄───┤ Bot Orchestrator │───►│  AWS Cloud      │
│   (Web UI)      │    │   (Core System) │    │  (EC2/Compute)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ Managed Bots    │
                       │ (Health Monitor)│
                       └─────────────────┘
```

## Error Handling

- **SSH Connection Issues**: Automatic retry with exponential backoff
- **AWS API Failures**: Validation and fallback procedures
- **Bot Health Degradation**: Progressive recovery escalation
- **Network Timeouts**: Configurable timeout handling

## Output

- Real-time health scores (0-100)
- Detailed health metrics and history
- Recovery action logs
- Performance optimization recommendations
- Cost analysis and optimization suggestions

## Built for Team Automation

Perfect for: Large-scale bot management, automated recovery, health monitoring, cost optimization, enterprise deployment workflows.

**Built by Forge 🔧 - Never manage bots manually again!**