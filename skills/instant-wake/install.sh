#!/bin/bash

# Instant Wake Tool - Installation Script
# Built by Forge 🔧
# Sets up dependencies and SSH key for instant bot wake-ups

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

log_info "⚡ Installing Instant Wake Tool dependencies..."

# Check SSH client
log_info "Checking SSH client..."
if command -v ssh &> /dev/null; then
    log_success "SSH client found: $(ssh -V 2>&1 | head -1)"
else
    log_info "Installing SSH client..."
    sudo apt update -qq
    sudo apt install -y openssh-client
    log_success "SSH client installed"
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

# Check for SSH key
SSH_KEY="$HOME/.ssh/bot-factory.pem"
log_info "Checking SSH key..."

if [[ -f "$SSH_KEY" ]]; then
    log_success "SSH key found: $SSH_KEY"
    
    # Check and fix permissions
    local perms=$(stat -c "%a" "$SSH_KEY" 2>/dev/null || stat -f "%Lp" "$SSH_KEY" 2>/dev/null)
    if [[ "$perms" != "600" ]]; then
        log_warning "Fixing SSH key permissions..."
        chmod 600 "$SSH_KEY"
        log_success "SSH key permissions set to 600"
    else
        log_success "SSH key permissions are correct (600)"
    fi
else
    log_warning "SSH key NOT found: $SSH_KEY"
    log_info "You'll need the bot-factory.pem SSH key to wake remote bots."
    log_info "Contact Dan Pena for the SSH key, then place it at: $SSH_KEY"
fi

# Create SSH directory if needed
if [[ ! -d "$HOME/.ssh" ]]; then
    log_info "Creating ~/.ssh directory..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    log_success "SSH directory created"
fi

# Make wake.sh executable
if [[ -f "./wake.sh" ]]; then
    chmod +x wake.sh
    log_success "Made wake.sh executable"
fi

# Test basic functionality
log_info "Testing basic functionality..."
if command -v curl &> /dev/null && command -v ssh &> /dev/null; then
    log_success "✅ All dependencies installed successfully!"
    echo ""
    echo "Usage: ./wake.sh <bot-id> [message]"
    echo "Test:  ./wake.sh test"
    echo "List:  ./wake.sh list"
    echo ""
    
    if [[ -f "$SSH_KEY" ]]; then
        log_success "🔑 SSH key ready - can wake remote bots"
    else
        log_warning "⚠️  SSH key missing - local testing only"
        log_info "Get bot-factory.pem from Dan Pena for remote wake capability"
    fi
    
    echo ""
    echo "Built by Forge 🔧"
else
    log_error "❌ Installation incomplete. Please check errors above."
    exit 1
fi