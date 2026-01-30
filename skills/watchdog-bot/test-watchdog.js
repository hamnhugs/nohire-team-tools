#!/usr/bin/env node

/**
 * WATCHDOG BOT - Test Suite
 * Verify Watchdog bot functionality before deployment
 */

const { 
    checkMeshHealth, 
    restartBot, 
    clearBotSessions 
} = require('./watchdog-bot');

// Test configuration
const TEST_CONFIG = {
    TEST_BOT_ID: 'forge',
    TEST_BOT_IP: '18.144.25.135',
    DISCORD_CHANNEL: '1466825803512942813'
};

/**
 * Test mesh health check
 */
async function testMeshHealthCheck() {
    console.log('🔍 Testing mesh health check...');
    
    try {
        const result = await checkMeshHealth(
            TEST_CONFIG.TEST_BOT_ID, 
            TEST_CONFIG.TEST_BOT_IP
        );
        
        console.log('Health check result:', result);
        
        if (result.status === 'healthy') {
            console.log('✅ Mesh health check working');
            return true;
        } else {
            console.log('⚠️ Mesh health check returned:', result.status);
            return false;
        }
    } catch (error) {
        console.error('❌ Mesh health check failed:', error);
        return false;
    }
}

/**
 * Test SSH connectivity
 */
async function testSSHConnectivity() {
    console.log('🔑 Testing SSH connectivity...');
    
    const { exec } = require('child_process');
    
    return new Promise((resolve) => {
        const sshCommand = `ssh -i ~/.ssh/bot-factory.pem -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ubuntu@${TEST_CONFIG.TEST_BOT_IP} "echo 'SSH test successful'"`;
        
        exec(sshCommand, { timeout: 15000 }, (error, stdout, stderr) => {
            if (error) {
                console.error('❌ SSH connectivity failed:', error.message);
                resolve(false);
                return;
            }
            
            if (stdout.includes('SSH test successful')) {
                console.log('✅ SSH connectivity working');
                resolve(true);
            } else {
                console.log('⚠️ SSH response unexpected:', stdout);
                resolve(false);
            }
        });
    });
}

/**
 * Test Discord alerting
 */
async function testDiscordAlerting() {
    console.log('💬 Testing Discord alerting...');
    
    const { exec } = require('child_process');
    
    return new Promise((resolve) => {
        const testMessage = `🧪 **WATCHDOG TEST**: Discord alerting test - ${new Date().toISOString()}`;
        const command = `clawdbot message send --channel discord --target ${TEST_CONFIG.DISCORD_CHANNEL} --message "${testMessage}"`;
        
        exec(command, { timeout: 10000 }, (error, stdout, stderr) => {
            if (error) {
                console.error('❌ Discord alerting failed:', error.message);
                resolve(false);
                return;
            }
            
            console.log('✅ Discord alert sent successfully');
            resolve(true);
        });
    });
}

/**
 * Test configuration validation
 */
function testConfiguration() {
    console.log('⚙️ Testing configuration...');
    
    const watchdogBot = require('./watchdog-bot');
    
    // Check if file loads without errors
    console.log('✅ Watchdog bot module loaded');
    
    // Check if required functions exist
    const requiredFunctions = [
        'checkMeshHealth',
        'restartBot', 
        'clearBotSessions'
    ];
    
    let allPresent = true;
    for (const func of requiredFunctions) {
        if (typeof watchdogBot[func] !== 'function') {
            console.error(`❌ Missing function: ${func}`);
            allPresent = false;
        }
    }
    
    if (allPresent) {
        console.log('✅ All required functions present');
    }
    
    return allPresent;
}

/**
 * Run all tests
 */
async function runTests() {
    console.log('🧪 WATCHDOG BOT TEST SUITE\n');
    
    const tests = [
        { name: 'Configuration', test: testConfiguration },
        { name: 'SSH Connectivity', test: testSSHConnectivity },
        { name: 'Mesh Health Check', test: testMeshHealthCheck },
        { name: 'Discord Alerting', test: testDiscordAlerting }
    ];
    
    const results = [];
    
    for (const { name, test } of tests) {
        console.log(`\n--- ${name} Test ---`);
        const result = await test();
        results.push({ name, passed: result });
    }
    
    // Summary
    console.log('\n📊 TEST RESULTS SUMMARY');
    console.log('========================');
    
    const passedTests = results.filter(r => r.passed);
    const failedTests = results.filter(r => !r.passed);
    
    passedTests.forEach(test => {
        console.log(`✅ ${test.name}`);
    });
    
    failedTests.forEach(test => {
        console.log(`❌ ${test.name}`);
    });
    
    console.log(`\n📈 Overall: ${passedTests.length}/${results.length} tests passed`);
    
    if (failedTests.length === 0) {
        console.log('🎉 ALL TESTS PASSED! Watchdog bot is ready for deployment.');
        return true;
    } else {
        console.log('⚠️ Some tests failed. Please fix issues before deployment.');
        return false;
    }
}

// Run tests if called directly
if (require.main === module) {
    runTests().then(success => {
        process.exit(success ? 0 : 1);
    }).catch(error => {
        console.error('Test suite failed:', error);
        process.exit(1);
    });
}

module.exports = {
    runTests,
    testMeshHealthCheck,
    testSSHConnectivity,
    testDiscordAlerting,
    testConfiguration
};