# Bot Onboarding Automation 🤖

**Auto-setup new team bots with complete knowledge, tools, and communication**

## What It Does

Automatically configures new team bots with everything they need to know:
- Team structure and workflow
- Communication via Switchboard
- Access to all team tools
- Daily habits and monitoring
- Proper file organization

**Solves the manual setup problem** - new bots are instantly productive!

## Quick Start

```bash
# Onboard a new designer bot
./onboard-bot.sh artdesign designer

# Onboard a new tool builder
./onboard-bot.sh newbot tool-builder  

# Onboard a general assistant
./onboard-bot.sh helper assistant
```

## What Gets Set Up

| Component | Purpose | Location |
|-----------|---------|----------|
| **AGENTS.md** | Team knowledge & identity | `~/clawd/AGENTS.md` |
| **HEARTBEAT.md** | Monitoring habits | `~/clawd/HEARTBEAT.md` |
| **TOOLS.md** | Tool usage guide | `~/clawd/TOOLS.md` |
| **MEMORY.md** | Quick reference | `~/clawd/MEMORY.md` |
| **Team Tools** | Complete toolkit | `~/clawd/nohire-team-tools/` |
| **Switchboard** | Communication setup | `~/.config/switchboard/` |

## Team Knowledge Included

### 👥 **Team Structure**
- **Manny** 👑 - Team Lead (Final approval)
- **Dan Pena** 🦅 - Manager (Reviews & coordinates)
- **Forge** 🔧 - Tool Builder (Automation & tools)
- **ArtDesign** 🎨 - Designer (UX/design review)

### 🔄 **Workflow Process**
1. **Build/Create** → 2. **Design Review** → 3. **Manager Review** → 4. **Final Approval**

### 💬 **Communication**
- **Switchboard API** for all team communication
- **Bot IDs**: forge, artdesign, dan-pena
- **Auto-configured** endpoints and credentials

## Bot Roles Supported

### 🎨 **Designer**
```bash
./onboard-bot.sh artdesign designer
```
- UX/design review focus
- Interface feedback capabilities
- Design workflow knowledge

### 🔧 **Tool Builder** 
```bash
./onboard-bot.sh forge tool-builder
```
- Automation and tool development
- GitHub and deployment knowledge
- Technical problem-solving focus

### 🤖 **Assistant**
```bash
./onboard-bot.sh helper assistant
```
- General support capabilities
- Basic team knowledge
- Flexible task handling

## Auto-Generated Files

### AGENTS.md Example
```markdown
# AGENTS.md - NewBot's Workspace

## Who I Am
🔧 **NewBot** — Assistant
I assist with various tasks and provide support to the team.

## Team Structure
- **Manny** 👑 - Team Lead
- **Dan Pena** 🦅 - Manager
[... complete team info ...]
```

### HEARTBEAT.md Example
```markdown
# HEARTBEAT.md

## Every Heartbeat - Check These:

### 1. Switchboard Check
```bash
curl -s "API/messages/newbot" | jq '.messages[] | select(.read == false)'
```
[... complete monitoring habits ...]
```

## Use Cases

### 🚀 **New Bot Deployment**
**Problem**: Manual setup takes hours, bots don't know team structure
```bash
# Before: Manual setup, missing knowledge, broken communication
# After: One command = fully configured bot
./onboard-bot.sh newbot designer
```

### 🔄 **Bot Refresh/Reset**
```bash
# Refresh existing bot with latest team knowledge
./onboard-bot.sh artdesign designer
```

### 📦 **Mass Deployment**
```bash
# Onboard multiple bots quickly
./onboard-bot.sh bot1 assistant
./onboard-bot.sh bot2 designer  
./onboard-bot.sh bot3 tool-builder
```

## Features

✅ **Complete Team Knowledge**: Structure, workflow, contacts
✅ **Auto Tool Setup**: Clones and installs all team tools
✅ **Switchboard Config**: Communication endpoints and credentials  
✅ **Daily Habits**: Monitoring and maintenance routines
✅ **Role-Specific Setup**: Designer, tool-builder, assistant templates
✅ **File Organization**: Standard workspace structure
✅ **Connectivity Testing**: Verifies Switchboard access

## Requirements

- Internet connection (for git clone, API access)
- Basic shell tools (curl, git, jq)
- Write access to ~/clawd directory

## Team Integration

**Before Onboarding Automation:**
1. Deploy new bot instance ⏰
2. Manually explain team structure ⏰⏰  
3. Set up communication ⏰
4. Install tools one by one ⏰⏰⏰
5. Explain workflow ⏰⏰
6. **Total: Hours of manual work** ❌

**With Onboarding Automation:**
1. Deploy new bot instance ⏰
2. Run: `./onboard-bot.sh newbot role` ⏰
3. **Total: Minutes of automated setup** ✅

## Troubleshooting

### "Git clone failed"
- Check internet connection
- Verify GitHub access permissions

### "Switchboard test failed"
- Check API connectivity
- Verify bot name doesn't conflict

### "Permission denied"
- Ensure script is executable: `chmod +x onboard-bot.sh`
- Check write access to ~/clawd directory

## Built by Forge 🔧

**For Manny's requirement**: Auto-setup new team bots with complete team knowledge.

**Perfect for**: New deployments, bot refresh, mass onboarding, team scaling