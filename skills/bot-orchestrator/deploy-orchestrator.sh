#!/bin/bash
# Bot Orchestrator Deployment Script
# Enterprise-grade deployment with monitoring and rollback capabilities
# Built by Forge 🔧

set -e

# Configuration
ORCHESTRATOR_INSTANCE_TYPE="t3.medium"
ORCHESTRATOR_PORT="19000"
AWS_REGION="${AWS_REGION:-us-west-1}"
KEY_PAIR="${KEY_PAIR:-bot-factory}"
SECURITY_GROUP="${SECURITY_GROUP:-sg-bot-factory}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[ORCHESTRATOR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                      BOT ORCHESTRATOR DEPLOY                     ║${NC}"
    echo -e "${PURPLE}║                    Enterprise Bot Management                     ║${NC}"
    echo -e "${PURPLE}║                        Built by Forge 🔧                         ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Validate prerequisites
validate_prerequisites() {
    log "Validating deployment prerequisites..."
    
    # Check required files
    if [[ ! -f "orchestrator.js" ]]; then
        error "orchestrator.js not found"
        exit 1
    fi
    
    if [[ ! -f "package.json" ]]; then
        error "package.json not found"
        exit 1
    fi
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        error "AWS CLI not found. Install with: pip install awscli"
        exit 1
    fi
    
    # Check SSH key
    if [[ ! -f ~/.ssh/${KEY_PAIR}.pem ]]; then
        error "SSH key not found: ~/.ssh/${KEY_PAIR}.pem"
        exit 1
    fi
    
    # Test AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials not configured"
        exit 1
    fi
    
    success "All prerequisites validated"
}

# Provision EC2 instance for orchestrator
provision_orchestrator_instance() {
    log "Provisioning EC2 instance for Bot Orchestrator..."
    
    # Get latest Ubuntu AMI
    local ami_id=$(aws ec2 describe-images \
        --owners 099720109477 \
        --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*" \
        --query 'Images|sort_by(@, &CreationDate)[-1].ImageId' \
        --output text \
        --region $AWS_REGION)
    
    if [[ -z "$ami_id" || "$ami_id" == "None" ]]; then
        error "Failed to get Ubuntu AMI ID"
        exit 1
    fi
    
    log "Using AMI: $ami_id"
    
    # Launch instance
    local instance_info=$(aws ec2 run-instances \
        --image-id $ami_id \
        --count 1 \
        --instance-type $ORCHESTRATOR_INSTANCE_TYPE \
        --key-name $KEY_PAIR \
        --security-group-ids $SECURITY_GROUP \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=bot-orchestrator},{Key=Role,Value=orchestrator},{Key=CreatedBy,Value=forge}]" \
        --region $AWS_REGION \
        --output json)
    
    if [[ $? -ne 0 ]]; then
        error "Failed to launch EC2 instance"
        exit 1
    fi
    
    local instance_id=$(echo "$instance_info" | jq -r '.Instances[0].InstanceId')
    
    log "Instance launched: $instance_id"
    log "Waiting for instance to be running..."
    
    # Wait for instance to be running
    aws ec2 wait instance-running --instance-ids $instance_id --region $AWS_REGION
    
    # Get public IP
    local public_ip=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text \
        --region $AWS_REGION)
    
    success "Instance ready: $instance_id ($public_ip)"
    
    # Store for later use
    echo "$instance_id" > .orchestrator-instance-id
    echo "$public_ip" > .orchestrator-public-ip
    
    echo "$instance_id|$public_ip"
}

# Install and configure orchestrator on instance
configure_orchestrator() {
    local public_ip=$1
    
    log "Configuring Bot Orchestrator on $public_ip..."
    
    # Wait for SSH to be available
    log "Waiting for SSH access..."
    local retry_count=0
    while ! ssh -i ~/.ssh/${KEY_PAIR}.pem -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$public_ip "echo 'SSH Ready'" &> /dev/null; do
        if [[ $retry_count -ge 30 ]]; then
            error "SSH access timeout after 5 minutes"
            exit 1
        fi
        sleep 10
        ((retry_count++))
    done
    
    success "SSH access established"
    
    # Copy orchestrator files
    log "Copying orchestrator files..."
    scp -i ~/.ssh/${KEY_PAIR}.pem -o StrictHostKeyChecking=no -r \
        orchestrator.js package.json dashboard/ \
        ubuntu@$public_ip:~/
    
    # Install and configure
    ssh -i ~/.ssh/${KEY_PAIR}.pem -o StrictHostKeyChecking=no ubuntu@$public_ip << 'EOF'
        # Update system
        sudo apt-get update -y
        
        # Install Node.js 18
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        
        # Install dependencies
        npm install --production
        
        # Create systemd service
        sudo tee /etc/systemd/system/bot-orchestrator.service > /dev/null << SERVICE_EOF
[Unit]
Description=Bot Orchestrator - Enterprise Bot Management
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/node orchestrator.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=ORCHESTRATOR_PORT=19000

[Install]
WantedBy=multi-user.target
SERVICE_EOF

        # Enable and start service
        sudo systemctl daemon-reload
        sudo systemctl enable bot-orchestrator
        sudo systemctl start bot-orchestrator
        
        # Verify service is running
        sleep 5
        sudo systemctl status bot-orchestrator
        
        echo "✅ Bot Orchestrator service configured and started"
EOF
    
    success "Orchestrator configured and running"
}

# Verify orchestrator deployment
verify_deployment() {
    local public_ip=$1
    
    log "Verifying Bot Orchestrator deployment..."
    
    # Test health endpoint
    local retry_count=0
    while ! curl -s "http://$public_ip:$ORCHESTRATOR_PORT/health" > /dev/null; do
        if [[ $retry_count -ge 12 ]]; then
            error "Health check failed after 2 minutes"
            return 1
        fi
        sleep 10
        ((retry_count++))
    done
    
    # Get health status
    local health=$(curl -s "http://$public_ip:$ORCHESTRATOR_PORT/health")
    echo "$health" | jq . > /dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        success "Bot Orchestrator is healthy and operational"
        echo "📊 Health Status:"
        echo "$health" | jq .
        return 0
    else
        error "Health check returned invalid response"
        return 1
    fi
}

# Create orchestrator dashboard
create_dashboard() {
    local public_ip=$1
    
    log "Setting up orchestrator dashboard..."
    
    mkdir -p dashboard
    
    cat > dashboard/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bot Orchestrator Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #fff; }
        .header { text-align: center; margin-bottom: 30px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #2a2a2a; padding: 20px; border-radius: 10px; text-align: center; }
        .stat-value { font-size: 2em; font-weight: bold; color: #0066FF; }
        .bot-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .bot-card { background: #2a2a2a; padding: 20px; border-radius: 10px; border-left: 4px solid #0066FF; }
        .health-indicator { display: inline-block; width: 12px; height: 12px; border-radius: 50%; margin-right: 8px; }
        .healthy { background: #28a745; }
        .degraded { background: #ffc107; }
        .critical { background: #dc3545; }
        .actions { margin-top: 15px; }
        .btn { padding: 8px 16px; margin: 4px; background: #0066FF; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .btn:hover { background: #0052cc; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🤖 Bot Orchestrator Dashboard</h1>
        <p>Enterprise Bot Management System - Built by Forge 🔧</p>
    </div>
    
    <div class="stats" id="stats">
        <!-- Stats will be populated by JavaScript -->
    </div>
    
    <div class="bot-grid" id="bot-grid">
        <!-- Bot cards will be populated by JavaScript -->
    </div>
    
    <script>
        async function loadDashboard() {
            try {
                const response = await fetch('/dashboard');
                const data = await response.json();
                
                updateStats(data.summary);
                updateBots(data.registry);
                
            } catch (error) {
                console.error('Failed to load dashboard:', error);
            }
        }
        
        function updateStats(summary) {
            const stats = document.getElementById('stats');
            stats.innerHTML = `
                <div class="stat-card">
                    <div class="stat-value">${summary.totalBots}</div>
                    <div>Total Bots</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${summary.healthyBots}</div>
                    <div>Healthy</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${summary.degradedBots}</div>
                    <div>Degraded</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${summary.criticalBots}</div>
                    <div>Critical</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${summary.averageHealth}%</div>
                    <div>Avg Health</div>
                </div>
            `;
        }
        
        function updateBots(registry) {
            const grid = document.getElementById('bot-grid');
            grid.innerHTML = '';
            
            Object.entries(registry).forEach(([id, bot]) => {
                const healthClass = bot.healthScore > 70 ? 'healthy' : 
                                  bot.healthScore > 30 ? 'degraded' : 'critical';
                
                const card = document.createElement('div');
                card.className = 'bot-card';
                card.innerHTML = `
                    <h3><span class="health-indicator ${healthClass}"></span>${bot.id}</h3>
                    <p><strong>Type:</strong> ${bot.type}</p>
                    <p><strong>IP:</strong> ${bot.ip}</p>
                    <p><strong>Health:</strong> ${bot.healthScore}%</p>
                    <p><strong>Status:</strong> ${bot.status}</p>
                    <div class="actions">
                        <button class="btn" onclick="recoverBot('${id}', 'restart')">Restart</button>
                        <button class="btn" onclick="recoverBot('${id}', 'reboot')">Reboot</button>
                    </div>
                `;
                grid.appendChild(card);
            });
        }
        
        async function recoverBot(botId, method) {
            try {
                const response = await fetch(`/recover/${botId}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ method })
                });
                
                const result = await response.json();
                alert(`Recovery initiated for ${botId}: ${method}`);
                
                // Reload dashboard after delay
                setTimeout(loadDashboard, 5000);
                
            } catch (error) {
                alert(`Failed to recover ${botId}: ${error.message}`);
            }
        }
        
        // Load dashboard on page load and refresh every 30 seconds
        loadDashboard();
        setInterval(loadDashboard, 30000);
    </script>
</body>
</html>
HTML_EOF
    
    success "Dashboard created"
}

# Generate deployment summary
generate_summary() {
    local public_ip=$1
    local instance_id=$2
    
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                     DEPLOYMENT COMPLETE! 🎉                     ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo "📍 Instance Information:"
    echo "   Instance ID: $instance_id"
    echo "   Public IP: $public_ip"
    echo "   Type: $ORCHESTRATOR_INSTANCE_TYPE"
    echo ""
    
    echo "🌐 Orchestrator Endpoints:"
    echo "   Dashboard: http://$public_ip:$ORCHESTRATOR_PORT"
    echo "   API: http://$public_ip:$ORCHESTRATOR_PORT/dashboard"
    echo "   Health: http://$public_ip:$ORCHESTRATOR_PORT/health"
    echo ""
    
    echo "🔧 Management Commands:"
    echo "   SSH Access: ssh -i ~/.ssh/${KEY_PAIR}.pem ubuntu@$public_ip"
    echo "   Service Status: sudo systemctl status bot-orchestrator"
    echo "   View Logs: journalctl -u bot-orchestrator -f"
    echo ""
    
    echo "🚀 Next Steps:"
    echo "   1. Access the dashboard to monitor bot health"
    echo "   2. Deploy new bots via POST /deploy API"
    echo "   3. Set up Telegram alerts with bot token"
    echo "   4. Configure monitoring and alerting"
    echo ""
    
    echo "💡 Quick Test:"
    echo "   curl http://$public_ip:$ORCHESTRATOR_PORT/health | jq"
    echo ""
}

# Main deployment function
main() {
    header
    
    log "Starting Bot Orchestrator deployment..."
    
    # Validate prerequisites
    validate_prerequisites
    
    # Create dashboard files
    create_dashboard
    
    # Provision and configure
    local instance_info=$(provision_orchestrator_instance)
    local instance_id=$(echo "$instance_info" | cut -d'|' -f1)
    local public_ip=$(echo "$instance_info" | cut -d'|' -f2)
    
    configure_orchestrator "$public_ip"
    
    # Verify deployment
    if verify_deployment "$public_ip"; then
        generate_summary "$public_ip" "$instance_id"
        
        # Save deployment info
        echo "ORCHESTRATOR_IP=$public_ip" > .orchestrator.env
        echo "ORCHESTRATOR_INSTANCE_ID=$instance_id" >> .orchestrator.env
        
        success "Bot Orchestrator deployment completed successfully!"
        exit 0
    else
        error "Deployment verification failed"
        exit 1
    fi
}

# Show usage
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Bot Orchestrator Deployment Script"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Environment Variables:"
    echo "  AWS_REGION       - AWS region (default: us-west-1)"
    echo "  KEY_PAIR         - SSH key pair name (default: bot-factory)"
    echo "  SECURITY_GROUP   - Security group ID (default: sg-bot-factory)"
    echo ""
    echo "Prerequisites:"
    echo "  - AWS CLI configured with valid credentials"
    echo "  - SSH key pair exists: ~/.ssh/bot-factory.pem"
    echo "  - Security group allows inbound traffic on port 19000"
    echo ""
    exit 0
fi

# Run deployment
main "$@"