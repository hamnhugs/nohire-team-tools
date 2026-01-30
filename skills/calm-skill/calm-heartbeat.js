#!/usr/bin/env node

/**
 * CALM HEARTBEAT MANAGER
 * Bot-side component for handling priority mode heartbeat changes
 * Built by Forge for NoHire team
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Configuration
const CONFIG = {
    NORMAL_HEARTBEAT: 30 * 60 * 1000, // 30 minutes  
    PRIORITY_HEARTBEAT: 60 * 1000,    // 1 minute
    CONFIG_FILE: path.join(process.env.HOME, '.clawdbot', 'calm-state.json'),
    CLAWDBOT_CONFIG: path.join(process.env.HOME, '.clawdbot', 'clawdbot.json'),
    MAX_PRIORITY_DURATION: 4 * 60 * 60 * 1000, // 4 hours max
};

/**
 * Read current CALM state
 */
function readCalmState() {
    try {
        if (fs.existsSync(CONFIG.CONFIG_FILE)) {
            const data = fs.readFileSync(CONFIG.CONFIG_FILE, 'utf8');
            return JSON.parse(data);
        }
    } catch (error) {
        console.error('Error reading CALM state:', error);
    }
    
    return {
        priority_mode: false,
        normal_heartbeat: CONFIG.NORMAL_HEARTBEAT,
        priority_heartbeat: CONFIG.PRIORITY_HEARTBEAT,
        last_updated: new Date().toISOString()
    };
}

/**
 * Write CALM state
 */
function writeCalmState(state) {
    try {
        const dir = path.dirname(CONFIG.CONFIG_FILE);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        
        state.last_updated = new Date().toISOString();
        fs.writeFileSync(CONFIG.CONFIG_FILE, JSON.stringify(state, null, 2));
        return true;
    } catch (error) {
        console.error('Error writing CALM state:', error);
        return false;
    }
}

/**
 * Read Clawdbot configuration
 */
function readClawdbotConfig() {
    try {
        if (fs.existsSync(CONFIG.CLAWDBOT_CONFIG)) {
            const data = fs.readFileSync(CONFIG.CLAWDBOT_CONFIG, 'utf8');
            return JSON.parse(data);
        }
    } catch (error) {
        console.error('Error reading Clawdbot config:', error);
    }
    return null;
}

/**
 * Update Clawdbot heartbeat configuration
 */
function updateHeartbeatConfig(intervalMs) {
    return new Promise((resolve) => {
        const configPatch = {
            agents: {
                defaults: {
                    heartbeat: {
                        intervalMs: intervalMs
                    }
                }
            }
        };
        
        const command = `clawdbot gateway config.patch '${JSON.stringify(configPatch)}'`;
        
        exec(command, { timeout: 30000 }, (error, stdout, stderr) => {
            if (error) {
                console.error('Failed to update heartbeat config:', error);
                resolve(false);
                return;
            }
            
            console.log(`✅ Heartbeat updated to ${intervalMs}ms`);
            resolve(true);
        });
    });
}

/**
 * Check if bot is currently processing (simplified check)
 */
function isBotBusy() {
    // This is a simplified check - in reality, we'd integrate with Clawdbot's internal state
    // For now, we'll assume the bot can handle heartbeat changes gracefully
    return false;
}

/**
 * Activate priority mode
 */
async function activatePriorityMode(task, triggeredBy = 'manager') {
    console.log('🚨 ACTIVATING PRIORITY MODE');
    console.log(`Task: ${task}`);
    console.log(`Triggered by: ${triggeredBy}`);
    
    // Check if bot is busy
    if (isBotBusy()) {
        console.log('⚠️ Bot is busy - queuing priority mode activation');
        // In a real implementation, we'd queue this for later
        return false;
    }
    
    // Read current state
    const state = readCalmState();
    
    // Update state to priority mode
    state.priority_mode = true;
    state.task = task;
    state.triggered_by = triggeredBy;
    state.activated_at = new Date().toISOString();
    state.current_heartbeat = CONFIG.PRIORITY_HEARTBEAT;
    
    // Save state
    if (!writeCalmState(state)) {
        console.error('❌ Failed to save CALM state');
        return false;
    }
    
    // Update Clawdbot configuration
    const success = await updateHeartbeatConfig(CONFIG.PRIORITY_HEARTBEAT);
    if (!success) {
        console.error('❌ Failed to update Clawdbot heartbeat');
        return false;
    }
    
    console.log('✅ Priority mode activated');
    console.log(`⏰ Heartbeat: ${CONFIG.PRIORITY_HEARTBEAT}ms (${CONFIG.PRIORITY_HEARTBEAT / 1000}s)`);
    
    // Set auto-cooldown timer
    setTimeout(() => {
        console.log('⏰ Auto-cooldown timer triggered');
        deactivatePriorityMode('auto-cooldown');
    }, CONFIG.MAX_PRIORITY_DURATION);
    
    return true;
}

/**
 * Deactivate priority mode (cooldown)
 */
async function deactivatePriorityMode(reason = 'manual') {
    console.log('❄️ DEACTIVATING PRIORITY MODE');
    console.log(`Reason: ${reason}`);
    
    // Check if bot is busy
    if (isBotBusy()) {
        console.log('⚠️ Bot is busy - queuing cooldown');
        // In a real implementation, we'd queue this for later
        return false;
    }
    
    // Read current state
    const state = readCalmState();
    
    // Update state to normal mode
    state.priority_mode = false;
    state.deactivated_at = new Date().toISOString();
    state.deactivation_reason = reason;
    state.current_heartbeat = CONFIG.NORMAL_HEARTBEAT;
    
    // Save state
    if (!writeCalmState(state)) {
        console.error('❌ Failed to save CALM state');
        return false;
    }
    
    // Update Clawdbot configuration
    const success = await updateHeartbeatConfig(CONFIG.NORMAL_HEARTBEAT);
    if (!success) {
        console.error('❌ Failed to update Clawdbot heartbeat');
        return false;
    }
    
    console.log('✅ Priority mode deactivated');
    console.log(`⏰ Heartbeat: ${CONFIG.NORMAL_HEARTBEAT}ms (${CONFIG.NORMAL_HEARTBEAT / (60 * 1000)}min)`);
    
    return true;
}

/**
 * Check current priority mode status
 */
function checkStatus() {
    const state = readCalmState();
    
    console.log('📊 CALM STATUS');
    console.log('==============');
    
    if (state.priority_mode) {
        console.log('🚨 Mode: PRIORITY ACTIVE');
        console.log(`📋 Task: ${state.task || 'N/A'}`);
        console.log(`👤 Triggered by: ${state.triggered_by || 'N/A'}`);
        console.log(`⏰ Activated: ${state.activated_at || 'N/A'}`);
        console.log(`💓 Current heartbeat: ${state.current_heartbeat}ms`);
        
        // Check if we're past max duration
        if (state.activated_at) {
            const activatedTime = new Date(state.activated_at).getTime();
            const now = Date.now();
            const elapsedMs = now - activatedTime;
            
            if (elapsedMs > CONFIG.MAX_PRIORITY_DURATION) {
                console.log('⚠️ WARNING: Priority mode has been active for over 4 hours');
                console.log('Consider manual cooldown if task is complete');
            }
        }
    } else {
        console.log('✅ Mode: NORMAL');
        console.log(`💓 Heartbeat: ${state.current_heartbeat || CONFIG.NORMAL_HEARTBEAT}ms`);
        
        if (state.deactivated_at) {
            console.log(`❄️ Last cooldown: ${state.deactivated_at}`);
            console.log(`📄 Reason: ${state.deactivation_reason || 'N/A'}`);
        }
    }
    
    console.log(`🕐 Last updated: ${state.last_updated}`);
    
    return state;
}

/**
 * Process incoming CALM message
 */
function processCalmMessage(message) {
    console.log('📨 Processing CALM message...');
    
    if (message.includes('PRIORITY MODE ACTIVATED')) {
        // Extract task from message
        const taskMatch = message.match(/\*\*Task\*\*: (.+)/);
        const task = taskMatch ? taskMatch[1] : 'Unspecified urgent task';
        
        activatePriorityMode(task, 'mesh-message');
    } else if (message.includes('PRIORITY MODE DEACTIVATED')) {
        deactivatePriorityMode('mesh-message');
    } else {
        console.log('⚠️ Unknown CALM message type');
    }
}

/**
 * CLI interface
 */
async function main() {
    const command = process.argv[2];
    
    switch (command) {
        case 'activate':
            const task = process.argv[3] || 'Manual priority mode activation';
            await activatePriorityMode(task, 'manual');
            break;
            
        case 'deactivate':
        case 'cooldown':
            await deactivatePriorityMode('manual');
            break;
            
        case 'status':
            checkStatus();
            break;
            
        case 'process-message':
            const message = process.argv[3];
            if (message) {
                processCalmMessage(message);
            } else {
                console.error('❌ Message content required');
                process.exit(1);
            }
            break;
            
        case 'help':
        case '--help':
        case '-h':
            console.log('CALM Heartbeat Manager');
            console.log('');
            console.log('Commands:');
            console.log('  activate <task>        Activate priority mode');
            console.log('  deactivate|cooldown    Deactivate priority mode');
            console.log('  status                 Show current status');
            console.log('  process-message <msg>  Process incoming CALM message');
            console.log('  help                   Show this help');
            console.log('');
            console.log('Built by Forge 🔧');
            break;
            
        default:
            console.error('❌ Unknown command. Use --help for usage.');
            process.exit(1);
    }
}

// Export functions for use as module
module.exports = {
    activatePriorityMode,
    deactivatePriorityMode,
    checkStatus,
    processCalmMessage,
    readCalmState,
    writeCalmState
};

// Run CLI if called directly
if (require.main === module) {
    main().catch(error => {
        console.error('CALM Heartbeat Manager failed:', error);
        process.exit(1);
    });
}