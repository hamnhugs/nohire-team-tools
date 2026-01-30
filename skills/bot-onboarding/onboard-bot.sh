#!/bin/bash

# Bot Onboarding Automation v1.0
# Built by Forge 🔧 for automatic new bot setup
# Usage: ./onboard-bot.sh <bot-name> [bot-role]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_REPO="https://github.com/hamnhugs/nohire-team-tools.git"
NOTION_API_KEY_PATH="~/.config/notion/api_key"
SWITCHBOARD_URL="https://uielffxuotmrgvpfdpxu.supabase.co/functions/v1/api"
BOT_BLUEPRINTS_URL="https://www.notion.so/Bot-Blueprints-2f87a8d312138119b52addab0dbd1c76"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[ONBOARD]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    echo "Bot Onboarding Automation - Auto-setup new team bots"
    echo ""
    echo "Usage: $0 <bot-name> [bot-role]"
    echo ""
    echo "Examples:"
    echo "  $0 artdesign designer"
    echo "  $0 forge tool-builder"
    echo "  $0 newbot assistant"
    echo ""
    echo "Built by Forge 🔧"
}

# Setup workspace directories
setup_workspace() {
    log_info "Setting up workspace directories..."
    
    # Create standard directories
    mkdir -p ~/clawd/{memory,canvas}
    
    log_success "Workspace directories created"
}

# Clone team tools repository
setup_team_tools() {
    log_info "Setting up team tools repository..."
    
    cd ~/clawd
    
    if [[ -d "nohire-team-tools" ]]; then
        log_info "Team tools repo already exists, updating..."
        cd nohire-team-tools && git pull && cd ~/clawd
    else
        log_info "Cloning team tools repository..."
        git clone "$TOOLS_REPO"
    fi
    log_success "Team tools repository ready at ~/clawd/nohire-team-tools"
    
    # Install any dependencies
    log_info "Installing tool dependencies..."
    cd ~/clawd/nohire-team-tools
    find skills/ -name "install.sh" -executable | while read installer; do
        log_info "Running $installer..."
        (cd "$(dirname "$installer")" && bash "$(basename "$installer")") || log_warning "Install failed for $installer"
    done
}

# Generate AGENTS.md with team knowledge
generate_agents_md() {
    local bot_name="$1"
    local bot_role="${2:-assistant}"
    
    log_info "Generating AGENTS.md with team knowledge..."
    
    cat > ~/clawd/AGENTS.md << EOF
# AGENTS.md - ${bot_name^}'s Workspace

## Who I Am
🔧 **${bot_name^}** — ${bot_role^}
$(case "$bot_role" in
    "designer") echo "I review UX/design and provide feedback on team tools and interfaces.";;
    "tool-builder") echo "I build tools and automation for the team. I don't manage, I build.";;
    "assistant") echo "I assist with various tasks and provide support to the team.";;
    *) echo "I contribute to the team with my specialized skills and knowledge.";;
esac)

## Team Structure
- **Manny** 👑 - Team Lead (Final approval)
- **Dan Pena** 🦅 - Manager (Reviews and coordinates)
- **Forge** 🔧 - Tool Builder (Builds automation and tools)
- **ArtDesign** 🎨 - Designer (UX/design review)

## Team Tools Repository
**Location**: ~/clawd/nohire-team-tools
**GitHub**: https://github.com/hamnhugs/nohire-team-tools

### Available Tools:
- **preview-server**: One-command public web previews
- **instant-wake**: Wake team bots immediately (deprecated - use local switchboard)  
- **bot-onboarding**: Auto-setup for new team bots

### Tool Usage:
\`\`\`bash
cd ~/clawd/nohire-team-tools/skills/<tool-name>/
./install.sh  # Install dependencies
./<tool-script>  # Use the tool
\`\`\`

## Communication - Switchboard (PRIMARY TEAM CHANNEL)
**CRITICAL**: When Manny/Dan says "check your messages" → CHECK SWITCHBOARD FIRST!

**API Base**: $SWITCHBOARD_URL

### Key Endpoints:
\`\`\`bash
# Check my messages (DO THIS FIRST when asked to check messages)
curl -s "$SWITCHBOARD_URL/messages/$bot_name" | jq

# Send message to team member
curl -X POST "$SWITCHBOARD_URL/messages" \\
  -H "Content-Type: application/json" \\
  -d '{"from_bot_id": "$bot_name", "to_bot_id": "dan-pena", "content": "Message text"}'

# Check my tasks  
curl -s "$SWITCHBOARD_URL/tasks/$bot_name" | jq
\`\`\`

### Communication Priority Order:
1. **SWITCHBOARD** - Primary team communication (check first!)
2. Slack/Discord - Secondary channels  
3. Other channels - Last resort

### Team Bot IDs:
- **forge** - Tool Builder
- **artdesign** - Designer  
- **dan-pena** - Manager

## Workflow Process
1. **Build/Create** → 2. **Design Review** (ArtDesign) → 3. **Manager Review** (Dan Pena) → 4. **Final Approval** (Manny)

## Daily Habits
1. **Check Switchboard** messages every heartbeat
2. **Pull team tools** repo for updates
3. **Report progress** to Dan Pena via Switchboard
4. **Save work** to appropriate locations (Notion for docs, GitHub for code)
5. **Follow team workflow** for all deliverables

## Storage Guidelines (MANDATORY EXTERNAL STORAGE)
- **Code**: GitHub repositories (NEVER store locally)
- **Documentation**: Notion pages (NEVER store locally)  
- **Tools**: nohire-team-tools repo
- **Context/State**: Switchboard shared memories or Notion (NEVER in context window)
- **Temporary work**: ~/clawd/ (30GB limit, cleanup regularly)
- **RULE**: If context feels heavy (>100k tokens), restart gateway after saving state

## Emergency Contacts
- **Urgent issues**: Message dan-pena via Switchboard
- **Technical problems**: Message forge via Switchboard
- **Design questions**: Message artdesign via Switchboard
EOF

    log_success "AGENTS.md generated with team knowledge"
}

# Generate HEARTBEAT.md with monitoring habits
generate_heartbeat_md() {
    local bot_name="$1"
    
    log_info "Generating HEARTBEAT.md with monitoring habits..."
    
    cat > ~/clawd/HEARTBEAT.md << EOF
# HEARTBEAT.md

## Every Heartbeat - Check These:

### 0. Notion Task Queue (CRITICAL FIRST CHECK)
Check your Notion Task Queue EVERY heartbeat:
- **Task Queue URL**: https://www.notion.so/${bot_name^}-Task-Queue-[CREATE_IN_NOTION]
- **Priority**: Check for new assignments from Dan Pena or Manny
- **Action**: Mark tasks as In Progress/Completed as you work
- **Rule**: Task Queue is source of truth, NOT Switchboard backlog

### 1. Switchboard Check (PRIMARY TEAM COMMUNICATION)
⚠️ **CRITICAL**: When anyone says "check your messages" → THIS IS WHERE YOU CHECK FIRST!

\`\`\`bash
# ONLY check for NEW messages (avoid historical backlog)
curl -s "$SWITCHBOARD_URL/messages/$bot_name" | jq '.messages[] | select(.read == false and .created_at > "$(date -u -d "1 hour ago" +%Y-%m-%dT%H:%M:%SZ)")'
\`\`\`
⚠️ **DO NOT process historical message backlogs** - Only handle recent unread messages!

**Why this matters:** Team uses Switchboard for urgent coordination. Missing these messages breaks team workflow. Historical backlogs can overwhelm new bots.

### 2. Team Tools Updates
\`\`\`bash
cd ~/clawd/nohire-team-tools && git pull
\`\`\`

### 3. Task Check  
\`\`\`bash
curl -s "$SWITCHBOARD_URL/tasks/$bot_name" | jq
\`\`\`

### 4. Work in Progress
- [ ] Continue any active assignments
- [ ] Push completed work to GitHub
- [ ] Update progress in Notion
- [ ] Report status to Dan Pena if significant changes

### 5. Context Management
- [ ] Check if context window feels heavy
- [ ] If context is bloated, restart gateway: \`clawdbot gateway restart\`
- [ ] Store important state in Switchboard or Notion before restart

### 6. Session Size Monitor
\`\`\`bash
# Check session file size and auto-clear if > 500KB
session_file=\$(find ~/.config/clawdbot/ -name "session*" -type f 2>/dev/null | head -1)
if [[ -n "\$session_file" ]]; then
    size=\$(stat -f%z "\$session_file" 2>/dev/null || stat -c%s "\$session_file" 2>/dev/null || echo 0)
    if [[ \$size -gt 512000 ]]; then
        echo "Session file \${size} bytes > 500KB - clearing and restarting"
        clawdbot gateway restart
    fi
fi
\`\`\`
- [ ] Session file size monitored automatically
- [ ] Auto-restart when sessions exceed 500KB  
- [ ] Prevents context bloat and memory issues

## External Storage Rules (MANDATORY)
- **NEVER store context/state locally** - use Switchboard shared memories
- **Use Notion** for project tracking and documentation
- **Use GitHub** for code and technical assets
- **Keep context window light** - restart if over 100k tokens

## Escalation Process
- **Urgent issues**: Message dan-pena immediately
- **Technical blocks**: Message forge for tools/automation help
- **Design questions**: Message artdesign for UX/design guidance

## Team Collaboration
- **All tools** available in ~/clawd/nohire-team-tools
- **Follow workflow**: Build → Design Review → Manager Review → Manny Approval
- **Communication**: Use Switchboard, not direct file access
EOF

    log_success "HEARTBEAT.md generated with monitoring habits"
}

# Generate TOOLS.md with tool instructions
generate_tools_md() {
    log_info "Generating TOOLS.md with tool usage..."
    
    cat > ~/clawd/TOOLS.md << EOF
# TOOLS.md

## Team Tools Repository
All team tools are in: **~/clawd/nohire-team-tools**

## Available Tools

### 🚀 Preview Server
**Purpose**: Create public URLs for local web content
**Location**: skills/preview-server/
**Usage**: \`./preview-server.sh start [directory] [port]\`
**Example**: \`./preview-server.sh start ./my-website\`

### 🔧 Bot Onboarding  
**Purpose**: Auto-setup new team bots with knowledge and tools
**Location**: skills/bot-onboarding/
**Usage**: \`./onboard-bot.sh <bot-name> [role]\`
**Example**: \`./onboard-bot.sh newbot designer\`

## Tool Development Guidelines
1. **All tools** go in skills/<tool-name>/ 
2. **Include files**: SKILL.md, install.sh, main script
3. **Test thoroughly** before pushing to repo
4. **Document usage** clearly in SKILL.md
5. **Follow workflow**: Build → ArtDesign review → Dan Pena review → Manny approval

## Installation
\`\`\`bash
cd ~/clawd/nohire-team-tools/skills/<tool-name>/
./install.sh  # Install dependencies
\`\`\`

## Getting Updates
\`\`\`bash
cd ~/clawd/nohire-team-tools
git pull
\`\`\`
EOF

    log_success "TOOLS.md generated with tool instructions"
}

# Generate Clawdbot configuration with fixes
setup_clawdbot_config() {
    local bot_name="$1"
    
    log_info "Setting up Clawdbot configuration with performance fixes..."
    
    # Calculate staggered heartbeat (30-45min range based on bot name hash)
    local name_hash=$(echo -n "$bot_name" | md5sum | tr -d ' -' | cut -c1-2)
    local heartbeat_base=30
    local heartbeat_offset=$((0x$name_hash % 16))  # 0-15 minute offset
    local heartbeat_minutes=$((heartbeat_base + heartbeat_offset))
    
    # Create config directory if it doesn't exist
    mkdir -p ~/clawd
    
    # Generate clawdbot.json with performance optimizations
    cat > ~/clawd/clawdbot.json << EOF
{
  "agents": {
    "defaults": {
      "compaction": {
        "mode": "safeguard"
      },
      "heartbeat": "${heartbeat_minutes}m"
    }
  },
  "commands": {
    "restart": true
  },
  "watcher": {
    "cooldown": 60
  },
  "performance": {
    "wake_cooldown": 60,
    "max_context_tokens": 100000,
    "compaction_threshold": 80000
  },
  "storage": {
    "external_only": true,
    "switchboard_url": "$SWITCHBOARD_URL",
    "notion_required": true,
    "github_required": true
  }
}
EOF

    log_success "Clawdbot config generated (heartbeat: ${heartbeat_minutes}m, cooldown: 60s)"
}

# Setup Switchboard credentials
setup_switchboard() {
    local bot_name="$1"
    
    log_info "Setting up Switchboard configuration..."
    
    # Create config directory
    mkdir -p ~/.config/switchboard
    
    # Save bot configuration
    cat > ~/.config/switchboard/config.json << EOF
{
    "bot_id": "$bot_name",
    "api_base": "$SWITCHBOARD_URL",
    "team_members": {
        "forge": "Tool Builder",
        "artdesign": "Designer", 
        "dan-pena": "Manager",
        "manny": "Team Lead"
    },
    "check_interval": 300,
    "auto_respond": false
}
EOF

    log_success "Switchboard configuration saved"
}

# Generate memory template
setup_memory() {
    log_info "Setting up memory system..."
    
    cat > ~/clawd/MEMORY.md << EOF
# MEMORY.md - Key Information

## Team Knowledge
- **Team repo**: github.com/hamnhugs/nohire-team-tools
- **Communication**: Switchboard API
- **Workflow**: Build → Design → Manager → Final Approval
- **Storage**: GitHub (code), Notion (docs), local ~/clawd (temp)

## Important Contacts
- **Manny**: Team Lead, final approval
- **Dan Pena**: Manager, reviews work
- **Forge**: Tool Builder, automation expert
- **ArtDesign**: Designer, UX/design review

## Daily Habits
- Check Switchboard messages
- Pull team tools updates  
- Report progress to Dan Pena
- Follow team workflow for deliverables

## Quick Commands
\`\`\`bash
# Check messages
curl -s "$SWITCHBOARD_URL/messages/$(whoami)" | jq

# Update tools
cd ~/clawd/nohire-team-tools && git pull

# Use preview tool
cd ~/clawd/nohire-team-tools/skills/preview-server && ./preview-server.sh start
\`\`\`
EOF

    log_success "Memory system initialized"
}

# Check Bot Blueprints for type-specific configuration
check_bot_blueprints() {
    local bot_name="$1"
    local bot_role="${2:-assistant}"
    
    log_info "🚨 MANDATORY: Checking Bot Blueprints for type '$bot_role'..."
    log_info "📋 Bot Blueprints URL: $BOT_BLUEPRINTS_URL"
    
    echo ""
    echo "⚠️  CRITICAL REMINDER ⚠️"
    echo "Before proceeding, you must check the Bot Blueprints document for:"
    echo "  ✅ Type-specific configuration for '$bot_role'"
    echo "  ✅ Required habits and lessons learned"
    echo "  ✅ Universal settings that apply to ALL bots"
    echo "  ✅ Customer bot configurations (if this is a client bot)"
    echo ""
    echo "📋 Bot Blueprints: $BOT_BLUEPRINTS_URL"
    echo ""
    
    # Add Blueprint URL to bot's memory for future reference
    log_info "Adding Bot Blueprints reference to bot memory..."
    
    cat >> ~/clawd/MEMORY.md << EOF

## Bot Blueprints (MANDATORY REFERENCE)
- **URL**: $BOT_BLUEPRINTS_URL
- **Purpose**: Type-specific configurations, lessons learned, universal settings
- **Rule**: ALWAYS check before creating any new bot
- **Bot Type**: $bot_role
- **Created**: $(date)

EOF

    log_success "Bot Blueprints check completed - URL saved to memory"
}

# Test Switchboard connectivity
test_switchboard() {
    local bot_name="$1"
    
    log_info "Testing Switchboard connectivity..."
    
    if curl -s "$SWITCHBOARD_URL/messages/$bot_name" > /dev/null; then
        log_success "Switchboard connection successful"
    else
        log_warning "Switchboard connection failed - check network/API"
    fi
}

# Main onboarding function
onboard_bot() {
    local bot_name="$1"
    local bot_role="${2:-assistant}"
    
    if [[ -z "$bot_name" ]]; then
        log_error "Bot name required"
        show_usage
        exit 1
    fi
    
    log_info "🤖 Starting bot onboarding for: $bot_name ($bot_role)"
    
    # MANDATORY: Check Bot Blueprints first
    check_bot_blueprints "$bot_name" "$bot_role"
    
    # Setup steps
    setup_workspace
    setup_team_tools
    setup_clawdbot_config "$bot_name"
    generate_agents_md "$bot_name" "$bot_role"
    generate_heartbeat_md "$bot_name"
    generate_tools_md
    setup_switchboard "$bot_name"
    setup_memory
    test_switchboard "$bot_name"
    
    log_success "🎉 Bot onboarding complete for $bot_name!"
    echo ""
    echo "📋 What was set up:"
    echo "  ✅ Bot Blueprints checked for type-specific config"
    echo "  ✅ Workspace directories"
    echo "  ✅ Team tools repository cloned"
    echo "  ✅ Clawdbot config with performance fixes (60s cooldown, safeguard mode)"
    echo "  ✅ AGENTS.md with team knowledge" 
    echo "  ✅ HEARTBEAT.md with monitoring habits + external storage rules"
    echo "  ✅ TOOLS.md with tool instructions"
    echo "  ✅ Switchboard configuration"
    echo "  ✅ Memory system with Bot Blueprints reference"
    echo "  ✅ Connectivity tests"
    echo ""
    echo "🚀 Bot is ready to join the team!"
    echo "📝 Key files: ~/clawd/{clawdbot.json,AGENTS.md,HEARTBEAT.md,TOOLS.md,MEMORY.md}"
    echo "🔧 Tools: ~/clawd/nohire-team-tools/skills/"
    echo "💬 Communication: Switchboard API"
    echo "⚡ Performance: Staggered heartbeats, 60s wake cooldown, compaction safeguards"
}

# Main function  
main() {
    case "${1:-}" in
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_usage
            exit 1
            ;;
        *)
            onboard_bot "$1" "$2"
            ;;
    esac
}

# Handle script interruption
trap 'log_warning "Onboarding interrupted."; exit 1' INT TERM

# Run main function
main "$@"