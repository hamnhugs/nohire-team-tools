#!/usr/bin/env node

/**
 * WATCHDOG BOT - Team Bot Health Monitor
 * Built by Forge for NoHire team
 * 
 * Monitors all team bots and auto-recovers issues
 */

const { spawn, exec } = require('child_process');
const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
    // Team bot fleet to monitor
    BOTS: {
        'dan': '54.215.71.171',
        'forge': '18.144.25.135', 
        'forge-jr': '54.193.122.20',
        'artdesign': '54.215.251.55',
        'marketer': '50.18.68.16',
        'franky': '18.144.174.205'
    },
    
    // Health check settings
    HEALTH_CHECK_INTERVAL: 5 * 60 * 1000, // 5 minutes
    RESPONSE_TIMEOUT: 30000, // 30 seconds
    CONTEXT_WARNING_THRESHOLD: 85, // 85% context usage
    
    // SSH settings
    SSH_KEY: process.env.SSH_KEY || '~/.ssh/bot-factory.pem',
    SSH_USER: 'ubuntu',
    
    // Discord settings (loaded from config)
    DISCORD_CHANNEL: '1466825803512942813',
    
    // Mesh network settings  
    MESH_PORT: 47823
};

/**
 * Health check via mesh network
 */
async function checkMeshHealth(botId, botIp) {
    return new Promise((resolve) => {
        const { exec } = require('child_process');
        const url = `http://${botIp}:${CONFIG.MESH_PORT}/health`;
        
        const timeout = setTimeout(() => {
            resolve({ 
                botId, 
                status: 'timeout', 
                error: `Mesh health check timeout (${CONFIG.RESPONSE_TIMEOUT}ms)` 
            });
        }, CONFIG.RESPONSE_TIMEOUT);
        
        exec(`curl -s --max-time 10 "${url}"`, (error, stdout, stderr) => {
            clearTimeout(timeout);
            
            if (error) {
                resolve({ 
                    botId, 
                    status: 'error', 
                    error: error.message 
                });
                return;
            }
            
            try {
                const response = JSON.parse(stdout);
                resolve({ 
                    botId, 
                    status: 'healthy', 
                    data: response 
                });
            } catch (parseError) {
                resolve({ 
                    botId, 
                    status: 'error', 
                    error: `Invalid response: ${stdout}` 
                });
            }
        });
    });
}

/**
 * SSH command execution
 */
async function executeSSHCommand(botIp, command) {
    return new Promise((resolve) => {
        const sshCommand = `ssh -i ${CONFIG.SSH_KEY} -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ${CONFIG.SSH_USER}@${botIp} "${command}"`;
        
        exec(sshCommand, { timeout: 30000 }, (error, stdout, stderr) => {
            if (error) {
                resolve({ 
                    success: false, 
                    error: error.message, 
                    stderr: stderr 
                });
                return;
            }
            
            resolve({ 
                success: true, 
                stdout: stdout, 
                stderr: stderr 
            });
        });
    });
}

/**
 * Restart bot via SSH
 */
async function restartBot(botId, botIp) {
    console.log(`🔄 RESTARTING BOT: ${botId} (${botIp})`);
    
    // Kill existing clawdbot processes
    const killResult = await executeSSHCommand(botIp, 'pkill clawdbot');
    console.log(`Kill result for ${botId}:`, killResult);
    
    // Wait a moment
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Start clawdbot gateway
    const startResult = await executeSSHCommand(botIp, 'cd ~ && nohup clawdbot gateway start > clawdbot.log 2>&1 &');
    console.log(`Start result for ${botId}:`, startResult);
    
    // Alert Discord
    await alertDiscord(`🔄 **WATCHDOG ACTION**: Restarted ${botId} bot (${botIp})`);
    
    return { killResult, startResult };
}

/**
 * Clear bot sessions when context too high
 */
async function clearBotSessions(botId, botIp) {
    console.log(`🧹 CLEARING SESSIONS: ${botId} (${botIp})`);
    
    // Clear session files
    const clearResult = await executeSSHCommand(botIp, 'rm -rf ~/.clawdbot/agents/main/sessions/*');
    console.log(`Clear result for ${botId}:`, clearResult);
    
    // Restart gateway to reload
    const restartResult = await restartBot(botId, botIp);
    
    // Alert Discord
    await alertDiscord(`🧹 **WATCHDOG ACTION**: Cleared sessions for ${botId} bot (context overflow)`);
    
    return { clearResult, restartResult };
}

/**
 * Send Discord alert
 */
async function alertDiscord(message) {
    try {
        // Use clawdbot message tool
        const command = `clawdbot message send --channel discord --target ${CONFIG.DISCORD_CHANNEL} --message "${message}"`;
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error('Discord alert failed:', error);
            } else {
                console.log('Discord alert sent:', message);
            }
        });
    } catch (error) {
        console.error('Discord alert error:', error);
    }
}

/**
 * Process health check results
 */
async function processHealthResults(results) {
    for (const result of results) {
        const { botId, status, error, data } = result;
        const botIp = CONFIG.BOTS[botId];
        
        console.log(`📊 Health check ${botId}: ${status}`);
        
        if (status === 'error' || status === 'timeout') {
            // Bot appears offline - attempt restart
            console.log(`❌ ${botId} appears offline: ${error}`);
            await restartBot(botId, botIp);
        } else if (status === 'healthy' && data) {
            // Check context usage if available
            if (data.contextUsage && data.contextUsage > CONFIG.CONTEXT_WARNING_THRESHOLD) {
                console.log(`⚠️ ${botId} context usage high: ${data.contextUsage}%`);
                await clearBotSessions(botId, botIp);
            } else {
                console.log(`✅ ${botId} healthy`);
            }
        }
    }
}

/**
 * Run health checks on all bots
 */
async function runHealthChecks() {
    console.log(`🔍 Starting health checks at ${new Date().toISOString()}`);
    
    const checks = Object.entries(CONFIG.BOTS).map(([botId, botIp]) => 
        checkMeshHealth(botId, botIp)
    );
    
    try {
        const results = await Promise.all(checks);
        await processHealthResults(results);
    } catch (error) {
        console.error('Health check batch failed:', error);
        await alertDiscord(`🚨 **WATCHDOG ERROR**: Health check batch failed - ${error.message}`);
    }
}

/**
 * Main watchdog loop
 */
async function startWatchdog() {
    console.log('🐕 WATCHDOG BOT STARTED');
    console.log(`📊 Monitoring ${Object.keys(CONFIG.BOTS).length} bots`);
    console.log(`⏰ Health check interval: ${CONFIG.HEALTH_CHECK_INTERVAL / 1000}s`);
    
    // Send startup alert
    await alertDiscord('🐕 **WATCHDOG ONLINE**: Bot health monitoring started. Checking all team bots every 5 minutes.');
    
    // Initial health check
    await runHealthChecks();
    
    // Schedule periodic health checks
    setInterval(runHealthChecks, CONFIG.HEALTH_CHECK_INTERVAL);
    
    // Keep process alive
    process.on('SIGINT', async () => {
        console.log('🛑 WATCHDOG SHUTTING DOWN');
        await alertDiscord('🛑 **WATCHDOG OFFLINE**: Bot health monitoring stopped.');
        process.exit(0);
    });
}

// Start the watchdog
if (require.main === module) {
    startWatchdog().catch(error => {
        console.error('Watchdog startup failed:', error);
        process.exit(1);
    });
}

module.exports = {
    startWatchdog,
    runHealthChecks,
    checkMeshHealth,
    restartBot,
    clearBotSessions
};