# Discord Configuration Troubleshooting

## Common Configuration Issues

### Configuration Command Fails

**Problem**: `clawdbot gateway config.patch` fails with argument errors
```
error: too many arguments for 'gateway'. Expected 0 arguments but got 2.
```

**Solution**: Use the gateway tool directly instead of CLI
```bash
# Don't use CLI approach:
# clawdbot gateway config.patch '...'

# Use this approach instead:
clawdbot gateway config.patch '{...}'
```

**Alternative**: Create JSON file and reference it
```bash
echo '{"channels": {...}}' > /tmp/config.json
clawdbot gateway config.patch "$(cat /tmp/config.json)"
```

### SSH Access Issues for Remote Configuration

**Problem**: Permission denied when trying to SSH to remote instances
```
ubuntu@ip: Permission denied (publickey)
```

**Solutions**:
1. **Use mesh network messaging** (preferred)
   ```bash
   ./configure_remote_discord.sh forge
   ```

2. **Request SSH key access** from instance owner

3. **Use Discord for coordination** - message the instance owner directly

### Gateway Not Responsive

**Problem**: Configuration commands hang or fail to respond

**Diagnostic Steps**:
1. **Check gateway status**: `clawdbot status`
2. **Verify gateway port**: Default is 18789
3. **Check gateway logs**: Look for error patterns
4. **Restart if needed**: `clawdbot gateway restart`

## Connectivity Issues

### Test Message Fails

**Problem**: Discord test message doesn't send

**Diagnostic Checklist**:
- [ ] **Token validity**: Check if bot token is correct and active
- [ ] **Bot permissions**: Verify bot can send messages to channel  
- [ ] **Channel access**: Ensure bot is added to Discord server
- [ ] **Network connectivity**: Check if Discord API is accessible

**Commands to verify**:
```bash
# Check current configuration
clawdbot gateway config.get

# Verify Discord plugin is enabled
grep -A 10 '"discord"' ~/.clawdbot/clawdbot.json

# Test manual message send
clawdbot message send --channel discord --target 1466825803512942813 --message "test"
```

### Bot Doesn't Respond to Mentions

**Problem**: Bot receives messages but doesn't respond when mentioned

**Common Causes**:
1. **requireMention setting**: Verify it's set to `true`
2. **Mention format**: Use `@botname` in Discord
3. **Bot online status**: Check if bot shows as online
4. **Channel permissions**: Verify bot can read messages

**Verification Steps**:
```bash
# Check mention requirements in config
grep -A 5 "requireMention" ~/.clawdbot/clawdbot.json

# Test with explicit mention
# In Discord: @botname hello, are you working?
```

## Network and Mesh Issues

### Mesh Network Unreachable

**Problem**: Remote configuration fails because mesh network is down
```
Mesh network not accessible at http://localhost:47823
```

**Solutions**:
1. **Start mesh network**: Check if local mesh server is running
2. **Use alternative ports**: Try different mesh network endpoints
3. **Direct SSH**: Fall back to SSH if mesh is unavailable
4. **Discord coordination**: Use Discord to coordinate manual setup

### Mesh Message Delivery Fails

**Problem**: Configuration messages sent but not received by target bot

**Troubleshooting**:
1. **Check mesh inbox**: `curl -s http://localhost:47823/inbox`
2. **Verify bot names**: Ensure target bot ID is correct
3. **Message format**: Check JSON format in mesh messages
4. **Heartbeat timing**: Allow time for bot to process messages

## Performance Issues

### Slow Discord Response

**Problem**: Bot takes long time to respond to Discord messages

**Optimization**:
- **Check heartbeat interval**: Reduce for faster response
- **Monitor context window**: Large context slows processing  
- **Network latency**: Discord API response times vary
- **Bot load**: Multiple concurrent operations slow response

### Configuration Takes Too Long

**Problem**: Discord configuration process is slow or times out

**Solutions**:
1. **Simplify configuration**: Apply minimal required settings first
2. **Split configuration**: Apply plugins and channels separately
3. **Increase timeouts**: Allow more time for gateway restart
4. **Manual verification**: Check each step individually

## Advanced Diagnostics

### Debug Discord Plugin

```bash
# Check if Discord plugin loaded correctly
clawdbot status | grep -i discord

# Verify Discord connection
curl -s "https://discord.com/api/v10/gateway/bot" \
  -H "Authorization: Bot YOUR_TOKEN_HERE"

# Check Discord guild access
clawdbot message send --channel discord --target CHANNEL_ID --message "debug test"
```

### Configuration Validation

```bash
# Validate JSON configuration
echo '{"channels": {...}}' | jq '.'

# Check configuration file format
jq '.channels.discord' ~/.clawdbot/clawdbot.json

# Verify all required fields present
jq '.channels.discord | keys' ~/.clawdbot/clawdbot.json
```

### Emergency Recovery

If Discord configuration completely breaks the bot:

1. **Stop clawdbot**: Kill the process
2. **Backup config**: `cp ~/.clawdbot/clawdbot.json ~/.clawdbot/clawdbot.json.backup`
3. **Remove Discord config**: Edit config file manually to remove Discord section
4. **Restart clawdbot**: Start with clean configuration
5. **Re-apply gradually**: Add Discord configuration step by step