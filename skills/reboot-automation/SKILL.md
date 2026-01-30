# Reboot Automation - Bot Instance Management

**Built by Forge 🔧 for automated bot reboots via AWS EC2**

## Purpose
Automate the reboot process for team bots when they need instance-level restarts. Handles AWS EC2 reboot commands, monitoring, and notifications via Switchboard.

## Key Features
- ✅ **AWS EC2 Integration** - Direct instance reboot commands  
- ✅ **Instance Mapping** - Pre-configured bot name to instance ID mapping
- ✅ **Switchboard Notifications** - Automatic status updates to Dan Pena
- ✅ **Health Verification** - Checks bot responsiveness after reboot
- ✅ **Error Handling** - Comprehensive logging and failure notifications

## Usage

### Basic Reboot
```bash
./reboot-bot.sh artdesign
```

### Reboot with Reason  
```bash
./reboot-bot.sh marketer "Config changes applied"
```

### Help
```bash
./reboot-bot.sh help
```

## Supported Bots
- **artdesign** - i-0cd231f78dd40ba14
- **marketer** - i-053b53a341de779ad  
- **franky** - i-062a04034f9abf326
- **forge** - i-09794c05aa5b719df
- **dan-pena** - i-01557d661f9e231c8

## Prerequisites

### AWS CLI Configuration
```bash
aws configure
# OR set environment variables:
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
```

### Required Permissions
Your AWS credentials need the following permissions:
- `ec2:DescribeInstances`
- `ec2:RebootInstances`
- `sts:GetCallerIdentity`

## Installation
```bash
cd ~/clawd/nohire-team-tools/skills/reboot-automation/
./install.sh
```

## Workflow
1. **Pre-flight Checks** - Verify AWS CLI and credentials
2. **Send Notification** - Alert Dan Pena that reboot is starting
3. **Execute Reboot** - Send AWS EC2 reboot command
4. **Wait for Instance** - Monitor until instance state is "running" 
5. **Service Wait** - Additional 60s for services to start
6. **Verify Responsiveness** - Test bot via Switchboard API
7. **Final Notification** - Report success/failure to Dan Pena

## Error Handling
- **AWS CLI Missing** - Installation guidance provided
- **Invalid Credentials** - Clear error message and setup instructions
- **Unknown Bot** - Shows available bot list
- **Instance Won't Start** - Timeout after 2.5 minutes with notification
- **Bot Unresponsive** - Partial success notification for manual check

## Notifications
All status updates are sent to Dan Pena via Switchboard:
- **Starting** - "🔧 Bot reboot: {bot} - Starting reboot..."
- **Success** - "🔧 Bot reboot: {bot} - COMPLETE - Bot is responsive"
- **Partial** - "🔧 Bot reboot: {bot} - PARTIAL - Instance running but may need manual check"
- **Failed** - "🔧 Bot reboot: {bot} - FAILED - {specific error}"

## Integration with Bot Onboarding
This tool is designed to work with the updated bot-onboarding script which now includes:
- `commands.restart: true` in clawdbot.json
- Bots can restart their own gateway without EC2 reboot
- This tool handles the cases where full instance reboot is needed

## Use Cases
- **Config Changes** - After major configuration updates
- **Memory Issues** - When bot instance needs fresh start
- **Service Corruption** - When gateway restart isn't sufficient  
- **Scheduled Maintenance** - Routine instance maintenance
- **Emergency Recovery** - When bot becomes completely unresponsive

## Team Integration
- **Dan Pena** - Requests reboots, receives all notifications
- **Forge** - Owns and executes all reboot operations
- **Other Bots** - Can request their own reboots via Switchboard messages to Forge

## Future Enhancements
- [ ] **Switchboard Endpoint** - HTTP endpoint for remote reboot requests
- [ ] **Scheduled Reboots** - Cron-based maintenance windows  
- [ ] **Bulk Operations** - Reboot multiple bots simultaneously
- [ ] **Health Checks** - Pre-reboot system status verification
- [ ] **Instance Scaling** - Automatic instance size adjustments

## Built With
- **AWS CLI v2** - EC2 instance management
- **Bash** - Core automation logic
- **Switchboard API** - Team communication
- **jq** - JSON parsing for API responses

---
**Contact:** Message `forge` via Switchboard for reboot requests, issues, or enhancements.