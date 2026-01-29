# Preview Server Skill — Specification

## Overview

A Clawdbot skill that allows any team bot to instantly spin up a web preview for any directory or HTML file, with a public URL accessible from anywhere.

## What It Does

1. Starts an HTTP server serving a specified directory
2. Creates a Cloudflare tunnel for public access
3. Returns the public URL
4. Manages lifecycle (start, stop, list active previews)

## Commands / Usage

The skill should respond to natural language like:
- "Start a preview server for ~/clawd/www"
- "Preview this directory"
- "Stop the preview"
- "List active previews"

Or via a tool/function that other bots can call programmatically.

## Technical Requirements

### Dependencies
- Python 3 (for http.server) — already installed on EC2
- cloudflared — need to auto-install if missing

### Skill Structure
```
skills/preview-server/
├── SKILL.md          # Usage instructions
├── preview.sh        # Main script
└── install.sh        # One-time setup (installs cloudflared if needed)
```

### preview.sh API

```bash
# Start a preview
./preview.sh start /path/to/directory [port]
# Returns: { "url": "https://xxx.trycloudflare.com", "pid": 12345 }

# Stop a preview
./preview.sh stop [pid|all]

# List active previews
./preview.sh list
# Returns: [{ "dir": "/path", "url": "https://...", "pid": 123 }]
```

### State Management

Store active previews in `/tmp/preview-server-state.json`:
```json
{
  "previews": [
    {
      "dir": "/home/ubuntu/clawd/www",
      "port": 8080,
      "httpPid": 12345,
      "tunnelPid": 12346,
      "url": "https://random-words.trycloudflare.com",
      "startedAt": "2026-01-29T05:30:00Z"
    }
  ]
}
```

### SKILL.md Content

Should explain:
1. How to use it naturally ("preview this folder")
2. How to stop previews
3. That URLs are temporary (trycloudflare.com)
4. Port conflicts handling

## Nice to Have (v2)

- Auto-detect if serving a single HTML file vs directory
- Live reload support
- Custom subdomain (requires Cloudflare account)
- Expiring previews (auto-stop after X hours)

## Acceptance Criteria

- [ ] `install.sh` works on fresh EC2 Ubuntu
- [ ] `preview.sh start <dir>` returns working public URL
- [ ] URL accessible from any device
- [ ] `preview.sh stop` cleans up processes
- [ ] `preview.sh list` shows active previews
- [ ] SKILL.md is clear and complete

---

*Requested by: Dan Pena*
*Assigned to: Forge*
*Created: 2026-01-29*
