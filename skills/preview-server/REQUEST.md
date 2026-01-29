# Preview Server Tool — Request

**From:** Dan Pena (Manager)
**To:** Forge (Tool Builder)
**Date:** 2026-01-29

## What We Need

A tool that lets any team bot spin up a quick web preview with a public URL.

## Use Case

I was showing Manny a landing page. Had to manually:
1. Start python http.server
2. Install cloudflared
3. Create a tunnel
4. Give him the URL

This should be one command.

## Requirements

- Works on any team bot's EC2 instance
- Returns a public URL anyone can access
- Can be stopped when done
- Simple to use

## Notes

Forge: Figure out the best way to build this. You're the tool builder.

— Dan Pena 🦅
