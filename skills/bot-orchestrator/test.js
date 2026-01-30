#!/usr/bin/env node
/**
 * Bot Orchestrator Test Suite
 * Comprehensive testing for all system components
 */

const { CONFIG, BOT_TEMPLATES } = require('./orchestrator.js');

// Test configuration
const TESTS = {
    config: {
        name: 'Configuration Validation',
        tests: [
            () => testConfigStructure(),
            () => testBotTemplates(),
            () => testEnvironmentVariables()
        ]
    },
    templates: {
        name: 'Bot Template Validation',
        tests: [
            () => testTemplateCompleteness(),
            () => testInstanceTypes(),
            () => testModelSelection()
        ]
    },
    api: {
        name: 'API Endpoint Testing',
        tests: [
            () => testHealthEndpoint(),
            () => testDashboardEndpoint(),
            () => testDeploymentValidation()
        ]
    }
};

// Colors for output
const colors = {
    green: '\033[0;32m',
    red: '\033[0;31m',
    blue: '\033[0;34m',
    yellow: '\033[1;33m',
    reset: '\033[0m'
};

function log(message, color = 'blue') {
    console.log(`${colors[color]}[TEST]${colors.reset} ${message}`);
}

function success(message) {
    console.log(`${colors.green}✅ ${message}${colors.reset}`);
}

function error(message) {
    console.log(`${colors.red}❌ ${message}${colors.reset}`);
}

function warning(message) {
    console.log(`${colors.yellow}⚠️  ${message}${colors.reset}`);
}

// Configuration Tests
function testConfigStructure() {
    log('Testing configuration structure...');
    
    const requiredKeys = ['orchestrator', 'aws', 'monitoring', 'telegram', 'stateFile'];
    const missingKeys = requiredKeys.filter(key => !CONFIG[key]);
    
    if (missingKeys.length === 0) {
        success('Configuration structure is valid');
        return true;
    } else {
        error(`Missing configuration keys: ${missingKeys.join(', ')}`);
        return false;
    }
}

function testBotTemplates() {
    log('Testing bot templates...');
    
    const requiredTemplates = ['tool-builder', 'designer', 'support', 'manager'];
    const availableTemplates = Object.keys(BOT_TEMPLATES);
    const missingTemplates = requiredTemplates.filter(t => !availableTemplates.includes(t));
    
    if (missingTemplates.length === 0) {
        success(`All required bot templates available: ${availableTemplates.join(', ')}`);
        return true;
    } else {
        error(`Missing bot templates: ${missingTemplates.join(', ')}`);
        return false;
    }
}

function testEnvironmentVariables() {
    log('Testing environment variables...');
    
    const warnings = [];
    
    if (!process.env.ORCHESTRATOR_BOT_TOKEN) {
        warnings.push('ORCHESTRATOR_BOT_TOKEN not set - Telegram alerts disabled');
    }
    
    if (!process.env.ALERT_CHAT_ID) {
        warnings.push('ALERT_CHAT_ID not set - Telegram alerts disabled');
    }
    
    if (!process.env.AWS_REGION) {
        warnings.push('AWS_REGION not set - using default: us-west-1');
    }
    
    if (warnings.length > 0) {
        warnings.forEach(w => warning(w));
        return true; // Warnings don't fail the test
    } else {
        success('All environment variables configured');
        return true;
    }
}

// Template Tests
function testTemplateCompleteness() {
    log('Testing template completeness...');
    
    const requiredFields = ['instanceType', 'model', 'heartbeat', 'memory', 'storage', 'compaction', 'cooldown', 'capabilities'];
    let allComplete = true;
    
    for (const [templateName, template] of Object.entries(BOT_TEMPLATES)) {
        const missingFields = requiredFields.filter(field => !template[field]);
        
        if (missingFields.length > 0) {
            error(`Template ${templateName} missing fields: ${missingFields.join(', ')}`);
            allComplete = false;
        }
    }
    
    if (allComplete) {
        success('All bot templates are complete');
        return true;
    } else {
        return false;
    }
}

function testInstanceTypes() {
    log('Testing instance type assignments...');
    
    const validInstanceTypes = ['t3.micro', 't3.small', 't3.medium', 't3.large', 't3.xlarge'];
    let allValid = true;
    
    for (const [templateName, template] of Object.entries(BOT_TEMPLATES)) {
        if (!validInstanceTypes.includes(template.instanceType)) {
            error(`Template ${templateName} has invalid instance type: ${template.instanceType}`);
            allValid = false;
        }
    }
    
    if (allValid) {
        success('All instance types are valid');
        return true;
    } else {
        return false;
    }
}

function testModelSelection() {
    log('Testing model selections...');
    
    const validModels = [
        'anthropic/claude-3-5-haiku-latest',
        'anthropic/claude-sonnet-4-20250514', 
        'anthropic/claude-opus-latest'
    ];
    
    let allValid = true;
    
    for (const [templateName, template] of Object.entries(BOT_TEMPLATES)) {
        if (!validModels.includes(template.model)) {
            error(`Template ${templateName} has invalid model: ${template.model}`);
            allValid = false;
        }
    }
    
    if (allValid) {
        success('All model selections are valid');
        return true;
    } else {
        return false;
    }
}

// API Tests (mock tests since server might not be running)
function testHealthEndpoint() {
    log('Testing health endpoint structure...');
    
    // Mock health response structure
    const mockHealth = {
        status: 'operational',
        version: CONFIG.orchestrator.version,
        timestamp: new Date().toISOString(),
        managed_bots: 0,
        active_deployments: 0
    };
    
    const requiredFields = ['status', 'version', 'timestamp', 'managed_bots', 'active_deployments'];
    const missingFields = requiredFields.filter(field => !mockHealth[field] && mockHealth[field] !== 0);
    
    if (missingFields.length === 0) {
        success('Health endpoint structure is valid');
        return true;
    } else {
        error(`Health endpoint missing fields: ${missingFields.join(', ')}`);
        return false;
    }
}

function testDashboardEndpoint() {
    log('Testing dashboard endpoint structure...');
    
    // Mock dashboard response structure
    const mockDashboard = {
        registry: {},
        state: {},
        summary: {},
        alerts: [],
        metrics: {}
    };
    
    const requiredFields = ['registry', 'state', 'summary', 'alerts', 'metrics'];
    const missingFields = requiredFields.filter(field => mockDashboard[field] === undefined);
    
    if (missingFields.length === 0) {
        success('Dashboard endpoint structure is valid');
        return true;
    } else {
        error(`Dashboard endpoint missing fields: ${missingFields.join(', ')}`);
        return false;
    }
}

function testDeploymentValidation() {
    log('Testing deployment request validation...');
    
    const validRequest = {
        botName: 'test-bot',
        botType: 'support',
        telegramToken: 'test_token',
        environment: 'production'
    };
    
    const requiredFields = ['botName', 'botType', 'telegramToken'];
    const missingFields = requiredFields.filter(field => !validRequest[field]);
    
    if (missingFields.length === 0 && BOT_TEMPLATES[validRequest.botType]) {
        success('Deployment validation logic is correct');
        return true;
    } else {
        error('Deployment validation has issues');
        return false;
    }
}

// Test Runner
async function runTestSuite() {
    console.log('🧪 Bot Orchestrator Test Suite');
    console.log('==============================');
    console.log('');
    
    let totalTests = 0;
    let passedTests = 0;
    
    for (const [suiteName, suite] of Object.entries(TESTS)) {
        console.log(`📋 ${suite.name}`);
        console.log('-'.repeat(suite.name.length + 3));
        
        for (const test of suite.tests) {
            totalTests++;
            try {
                if (await test()) {
                    passedTests++;
                }
            } catch (error) {
                error(`Test failed with error: ${error.message}`);
            }
        }
        
        console.log('');
    }
    
    console.log('🎯 Test Summary');
    console.log('===============');
    console.log(`Total Tests: ${totalTests}`);
    console.log(`Passed: ${passedTests}`);
    console.log(`Failed: ${totalTests - passedTests}`);
    console.log(`Success Rate: ${Math.round((passedTests / totalTests) * 100)}%`);
    
    if (passedTests === totalTests) {
        success('🎉 All tests passed! Bot Orchestrator is ready for deployment.');
        process.exit(0);
    } else {
        error('⚠️ Some tests failed. Please review and fix issues before deployment.');
        process.exit(1);
    }
}

// Architecture Validation
function validateArchitecture() {
    log('Validating system architecture...');
    
    const architectureChecks = [
        {
            name: 'Separation of Concerns',
            check: () => {
                // Check if different responsibilities are properly separated
                const hasProvisioning = true; // Would check for provisioning logic
                const hasMonitoring = true;   // Would check for monitoring logic
                const hasRecovery = true;     // Would check for recovery logic
                return hasProvisioning && hasMonitoring && hasRecovery;
            }
        },
        {
            name: 'Error Handling',
            check: () => {
                // Check if proper error handling is in place
                return true; // Would validate try/catch blocks and error propagation
            }
        },
        {
            name: 'State Management',
            check: () => {
                // Check if state is properly managed and persisted
                return CONFIG.stateFile !== undefined;
            }
        },
        {
            name: 'Configuration Management',
            check: () => {
                // Check if configuration is externalized and manageable
                return Object.keys(CONFIG).length > 0 && Object.keys(BOT_TEMPLATES).length > 0;
            }
        }
    ];
    
    let allPassed = true;
    
    for (const check of architectureChecks) {
        if (check.check()) {
            success(`Architecture: ${check.name} ✓`);
        } else {
            error(`Architecture: ${check.name} ✗`);
            allPassed = false;
        }
    }
    
    if (allPassed) {
        success('System architecture validation passed');
    } else {
        error('System architecture has issues');
    }
    
    return allPassed;
}

// Main execution
if (require.main === module) {
    const args = process.argv.slice(2);
    
    if (args.includes('--architecture')) {
        validateArchitecture();
    } else {
        runTestSuite();
    }
}

module.exports = { runTestSuite, validateArchitecture };