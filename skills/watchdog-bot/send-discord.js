#!/usr/bin/env node
// Simple Discord message sender
const https = require("https");
const message = process.argv[2];
if (!message) process.exit(1);

const data = JSON.stringify({ content: message });
const DISCORD_TOKEN = process.env.DISCORD_TOKEN;
const DISCORD_CHANNEL = process.env.DISCORD_CHANNEL;

if (!DISCORD_TOKEN || !DISCORD_CHANNEL) {
  console.error("Missing DISCORD_TOKEN or DISCORD_CHANNEL environment variables");
  process.exit(1);
}

const options = {
  hostname: "discord.com",
  port: 443,
  path: `/api/v10/channels/${DISCORD_CHANNEL}/messages`,
  method: "POST",
  headers: {
    "Authorization": `Bot ${DISCORD_TOKEN}`,
    "Content-Type": "application/json",
    "Content-Length": data.length
  }
};

const req = https.request(options, (res) => {
  console.log("Discord message sent:", res.statusCode);
});

req.on("error", (err) => {
  console.error("Discord error:", err);
});

req.write(data);
req.end();
