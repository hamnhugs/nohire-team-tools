#!/bin/bash

# Bot Onboarding Tool - Installation Script
# Built by Forge 🔧
# Sets up dependencies for bot onboarding automation

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INSTALL]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "🤖 Installing Bot Onboarding Tool dependencies..."

# Check OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This tool requires Linux (Ubuntu/EC2)"
    exit 1
fi

# Check curl
log_info "Checking curl..."
if command -v curl &> /dev/null; then
    log_success "curl found: $(curl --version | head -1)"
else
    log_info "Installing curl..."
    sudo apt update -qq
    sudo apt install -y curl
    log_success "curl installed"
fi

# Check git
log_info "Checking git..."
if command -v git &> /dev/null; then
    log_success "git found: $(git --version)"
else
    log_info "Installing git..."
    sudo apt update -qq
    sudo apt install -y git
    log_success "git installed"
fi

# Check jq (for JSON parsing)
log_info "Checking jq..."
if command -v jq &> /dev/null; then
    log_success "jq found: $(jq --version)"
else
    log_info "Installing jq..."
    sudo apt update -qq
    sudo apt install -y jq
    log_success "jq installed"
fi

# Check whoami command
log_info "Checking basic shell tools..."
if command -v whoami &> /dev/null; then
    log_success "Shell tools available"
else
    log_error "Basic shell tools missing"
    exit 1
fi

# Create workspace directory if needed
log_info "Setting up workspace..."
if [[ ! -d "$HOME/clawd" ]]; then
    mkdir -p "$HOME/clawd"
    log_success "Workspace directory created: ~/clawd"
else
    log_success "Workspace directory exists: ~/clawd"
fi

# Create config directories
mkdir -p "$HOME/.config"
log_success "Config directories ready"

# Make onboard-bot.sh executable
if [[ -f "./onboard-bot.sh" ]]; then
    chmod +x onboard-bot.sh
    log_success "Made onboard-bot.sh executable"
fi

# Test basic functionality
log_info "Testing basic functionality..."

# Test curl
if curl -s --connect-timeout 5 https://api.github.com > /dev/null; then
    log_success "Internet connectivity: OK"
else
    log_warning "Internet connectivity issues detected"
fi

# Test git
if git --version > /dev/null 2>&1; then
    log_success "Git functionality: OK" 
else
    log_error "Git not working properly"
    exit 1
fi

# Test jq
if echo '{"test": "value"}' | jq -r '.test' > /dev/null 2>&1; then
    log_success "JSON processing (jq): OK"
else
    log_error "jq not working properly"
    exit 1
fi

# Final check
if command -v curl &> /dev/null && command -v git &> /dev/null && command -v jq &> /dev/null; then
    log_success "✅ All dependencies installed successfully!"
    echo ""
    echo "Usage: ./onboard-bot.sh <bot-name> [role]"
    echo "Example: ./onboard-bot.sh artdesign designer"
    echo ""
    echo "Roles: designer, tool-builder, assistant"
    echo ""
    echo "Built by Forge 🔧"
else
    log_error "❌ Installation incomplete. Please check errors above."
    exit 1
fi