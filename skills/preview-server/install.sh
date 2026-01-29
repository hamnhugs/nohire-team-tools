#!/bin/bash

# Preview Server Tool - Installation Script
# Built by Forge 🔧
# Installs dependencies for preview-server tool

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INSTALL]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "🚀 Installing Preview Server Tool dependencies..."

# Check OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    log_error "This tool requires Linux (Ubuntu/EC2)"
    exit 1
fi

# Check Python (usually pre-installed on Ubuntu)
log_info "Checking Python..."
if command -v python3 &> /dev/null; then
    log_success "Python3 found: $(python3 --version)"
elif command -v python &> /dev/null; then
    log_success "Python found: $(python --version)"
else
    log_info "Installing Python3..."
    sudo apt update -qq
    sudo apt install -y python3
    log_success "Python3 installed"
fi

# Install cloudflared
log_info "Checking cloudflared..."
if command -v cloudflared &> /dev/null; then
    log_success "cloudflared already installed: $(cloudflared --version 2>&1 | head -1)"
else
    log_info "Installing cloudflared..."
    
    # Download cloudflared
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /tmp/cloudflared
    
    # Make executable and move to bin
    chmod +x /tmp/cloudflared
    sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
    
    log_success "cloudflared installed: $(cloudflared --version 2>&1 | head -1)"
fi

# Install wget if not present
log_info "Checking wget..."
if ! command -v wget &> /dev/null; then
    log_info "Installing wget..."
    sudo apt update -qq
    sudo apt install -y wget
    log_success "wget installed"
else
    log_success "wget already available"
fi

# Make preview-server.sh executable
if [[ -f "./preview-server.sh" ]]; then
    chmod +x preview-server.sh
    log_success "Made preview-server.sh executable"
fi

# Test installation
log_info "Testing installation..."
if command -v cloudflared &> /dev/null && (command -v python3 &> /dev/null || command -v python &> /dev/null); then
    log_success "✅ All dependencies installed successfully!"
    echo ""
    echo "Usage: ./preview-server.sh start [directory] [port]"
    echo "Example: ./preview-server.sh start"
    echo ""
    echo "Built by Forge 🔧"
else
    log_error "❌ Installation incomplete. Please check errors above."
    exit 1
fi