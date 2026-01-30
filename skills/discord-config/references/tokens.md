# Discord Bot Tokens and Security

## Current Team Bot Token

**Token**: `[TEAM_BOT_TOKEN]` (See secure team documentation)

**Server**: Nohire.io
**Server ID**: `1466818873390272677`
**Channel**: #bot-team  
**Channel ID**: `1466825803512942813`

## Bot Permissions

The bot token has the following Discord permissions:

- **Send Messages** - Post to #bot-team channel
- **Read Message History** - Access previous messages
- **Use External Emojis** - Enhanced message formatting
- **Mention Everyone** - Can use @everyone and @here (use sparingly)

**Important**: `requireMention: true` means bots only respond when @mentioned.

## Security Guidelines

### Token Protection

- **Never commit tokens to public repositories**
- **Use environment variables when possible**  
- **Rotate tokens if compromised**
- **Limit token permissions to minimum required**

### Configuration Security

- **Store tokens in secure configuration files**
- **Use `allowlist` policies for groups and DMs**
- **Enable `requireMention` to prevent spam**
- **Monitor bot activity for unusual patterns**

## Token Management

### Creating New Tokens

1. Go to Discord Developer Portal
2. Create new application
3. Go to "Bot" section
4. Create bot and copy token
5. Add bot to server with required permissions

### Revoking Tokens

1. Go to Discord Developer Portal
2. Navigate to your application
3. Go to "Bot" section  
4. Click "Regenerate" to create new token
5. Update all configurations with new token

## Emergency Procedures

### Token Compromise

1. **Immediately regenerate token** in Discord Developer Portal
2. **Update all bot configurations** with new token
3. **Restart all affected bots**
4. **Monitor for unauthorized activity**

### Bot Misbehavior

1. **Disable bot in Discord** (remove from server temporarily)
2. **Check bot logs** for error patterns
3. **Verify configuration** is correct
4. **Test in private channel** before re-enabling

## Multiple Bot Setup

For teams with multiple bots, each bot can use the same token but should have:

- **Unique bot names** for identification
- **Consistent configuration** across instances
- **Centralized monitoring** for token usage
- **Coordinated restart procedures** when updating tokens