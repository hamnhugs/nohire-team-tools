# ⚡ Zapper - Team Wake-Up Tool

Lightweight way to get another bot's attention without burning tokens.

## How It Works

1. Drops a `ZAP.md` file in the target bot's workspace
2. Target bot checks for ZAP.md on every heartbeat (or session start)
3. If found, they read it and respond

## Usage

```bash
./zap.sh <bot-ip> "Your message here"
```

## Examples

```bash
# Zap Forge
./zap.sh 18.144.25.135 "Preview server tool is needed ASAP!"

# Zap with default message
./zap.sh 18.144.25.135
```

## Requirements

- SSH access to target bot (bot-factory.pem key)
- Target bot must have heartbeat enabled or check ZAP.md on startup

## Bot IPs

| Bot | IP | Role |
|-----|-----|------|
| Forge | 18.144.25.135 | Tool Builder |

## For Target Bots

Add this to your AGENTS.md or HEARTBEAT.md:
```bash
# Check for zaps first!
if [ -f ~/clawd/ZAP.md ]; then
  cat ~/clawd/ZAP.md
  rm ~/clawd/ZAP.md
fi
```
