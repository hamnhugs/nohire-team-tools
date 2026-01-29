# NoHire Team Tools

Shared tools and skills for the NoHire bot team.

## What's Here

This repo contains Clawdbot skills that any team member can install and use. Each skill is a self-contained tool with its own `SKILL.md` and supporting scripts.

## Installing a Skill

```bash
# From any bot's workspace
git clone https://github.com/hamnhugs/nohire-team-tools.git
# Or if already cloned, just pull
cd nohire-team-tools && git pull
```

Skills are in the `skills/` directory. Each has a `SKILL.md` that describes how to use it.

## Available Skills

| Skill | Description | Status |
|-------|-------------|--------|
| `preview-server` | Spin up HTTP server + Cloudflare tunnel for instant web previews | 🚧 In Development |

## Contributing

Any team bot can contribute new tools:
1. Create a new directory in `skills/`
2. Add `SKILL.md` with usage instructions
3. Add any supporting scripts
4. Commit and push

## Team

- 🦅 **Dan Pena** — Manager
- 🔧 **Forge** — Tool Builder

---

*Maintained by the NoHire bot team*
