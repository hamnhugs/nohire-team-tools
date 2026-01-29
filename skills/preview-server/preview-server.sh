#!/bin/bash

# Preview Server Tool v1.0
# Built by Forge 🔧 for one-command public web previews
# Usage: ./preview-server.sh [directory] [port]

set -e

# Configuration
DEFAULT_PORT=8080
DEFAULT_DIR="."
TUNNEL_LOG="/tmp/preview-server-tunnel.log"
SERVER_PID_FILE="/tmp/preview-server.pid"
TUNNEL_PID_FILE="/tmp/preview-server-tunnel.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[PREVIEW]${NC} $1"
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

# Show usage
show_usage() {
    echo "Preview Server Tool - One-command public web previews"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start [dir] [port]  Start preview server (default: current dir, port 8080)"
    echo "  stop               Stop the preview server"
    echo "  status             Check server status"
    echo "  url                Show public URL"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Preview current directory"
    echo "  $0 start ./dist 3000       # Preview ./dist on port 3000"
    echo "  $0 stop                     # Stop the server"
    echo ""
    echo "Built by Forge 🔧"
}

# Check if cloudflared is installed
check_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        log_error "cloudflared not found. Installing..."
        
        # Install cloudflared
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /tmp/cloudflared
            chmod +x /tmp/cloudflared
            sudo mv /tmp/cloudflared /usr/local/bin/
            log_success "cloudflared installed successfully"
        else
            log_error "Unsupported OS. Please install cloudflared manually."
            exit 1
        fi
    fi
}

# Start the preview server
start_server() {
    local serve_dir="${1:-$DEFAULT_DIR}"
    local port="${2:-$DEFAULT_PORT}"
    
    # Check if already running
    if [[ -f "$SERVER_PID_FILE" ]] && ps -p "$(cat $SERVER_PID_FILE)" > /dev/null 2>&1; then
        log_warning "Server already running. Use 'stop' first."
        show_status
        exit 0
    fi
    
    # Validate directory
    if [[ ! -d "$serve_dir" ]]; then
        log_error "Directory does not exist: $serve_dir"
        exit 1
    fi
    
    log_info "🚀 Starting Preview Server..."
    log_info "Directory: $(realpath $serve_dir)"
    log_info "Port: $port"
    
    # Check if cloudflared is available
    check_cloudflared
    
    # Start local server
    cd "$serve_dir"
    log_info "Starting local HTTP server..."
    
    # Use Python's built-in server
    if command -v python3 &> /dev/null; then
        python3 -m http.server "$port" > /dev/null 2>&1 &
    elif command -v python &> /dev/null; then
        python -m http.server "$port" > /dev/null 2>&1 &
    else
        log_error "Python not found. Cannot start HTTP server."
        exit 1
    fi
    
    local server_pid=$!
    echo "$server_pid" > "$SERVER_PID_FILE"
    
    # Give server a moment to start
    sleep 2
    
    # Check if server started successfully
    if ! ps -p "$server_pid" > /dev/null 2>&1; then
        log_error "Failed to start HTTP server"
        rm -f "$SERVER_PID_FILE"
        exit 1
    fi
    
    log_success "HTTP server started (PID: $server_pid)"
    
    # Start cloudflared tunnel
    log_info "Creating public tunnel..."
    cloudflared tunnel --url "http://localhost:$port" --logfile "$TUNNEL_LOG" > /dev/null 2>&1 &
    local tunnel_pid=$!
    echo "$tunnel_pid" > "$TUNNEL_PID_FILE"
    
    # Wait for tunnel URL
    log_info "Waiting for tunnel to establish..."
    local timeout=15
    local count=0
    
    while [[ $count -lt $timeout ]]; do
        if [[ -f "$TUNNEL_LOG" ]] && grep -q "https.*trycloudflare.com" "$TUNNEL_LOG"; then
            break
        fi
        sleep 1
        ((count++))
    done
    
    if [[ $count -eq $timeout ]]; then
        log_error "Tunnel failed to establish within $timeout seconds"
        stop_server
        exit 1
    fi
    
    # Extract public URL
    local public_url=$(grep -o 'https://.*\.trycloudflare\.com' "$TUNNEL_LOG" | head -1)
    
    log_success "🌐 Preview Server is running!"
    echo ""
    echo "┌─────────────────────────────────────────────────────┐"
    echo "│                   PREVIEW READY                     │"  
    echo "├─────────────────────────────────────────────────────┤"
    echo "│ Public URL: $public_url"
    echo "│ Local URL:  http://localhost:$port"
    echo "│ Directory:  $(realpath $serve_dir)"
    echo "└─────────────────────────────────────────────────────┘"
    echo ""
    log_info "Share the Public URL with anyone to view your preview!"
    log_info "Use '$0 stop' to stop the server when done."
    
    # Save URL for later reference
    echo "$public_url" > /tmp/preview-server-url.txt
}

# Stop the server
stop_server() {
    log_info "🛑 Stopping Preview Server..."
    
    local stopped_something=false
    
    # Stop tunnel
    if [[ -f "$TUNNEL_PID_FILE" ]]; then
        local tunnel_pid=$(cat "$TUNNEL_PID_FILE")
        if ps -p "$tunnel_pid" > /dev/null 2>&1; then
            kill "$tunnel_pid" 2>/dev/null || true
            log_success "Tunnel stopped"
            stopped_something=true
        fi
        rm -f "$TUNNEL_PID_FILE"
    fi
    
    # Stop HTTP server
    if [[ -f "$SERVER_PID_FILE" ]]; then
        local server_pid=$(cat "$SERVER_PID_FILE")
        if ps -p "$server_pid" > /dev/null 2>&1; then
            kill "$server_pid" 2>/dev/null || true
            log_success "HTTP server stopped"
            stopped_something=true
        fi
        rm -f "$SERVER_PID_FILE"
    fi
    
    # Cleanup temp files
    rm -f "$TUNNEL_LOG" /tmp/preview-server-url.txt
    
    if [[ "$stopped_something" == true ]]; then
        log_success "Preview Server stopped successfully"
    else
        log_warning "No running server found"
    fi
}

# Show server status
show_status() {
    local server_running=false
    local tunnel_running=false
    
    if [[ -f "$SERVER_PID_FILE" ]] && ps -p "$(cat $SERVER_PID_FILE)" > /dev/null 2>&1; then
        server_running=true
    fi
    
    if [[ -f "$TUNNEL_PID_FILE" ]] && ps -p "$(cat $TUNNEL_PID_FILE)" > /dev/null 2>&1; then
        tunnel_running=true
    fi
    
    echo "Preview Server Status:"
    echo "├─ HTTP Server: $([ "$server_running" = true ] && echo "✅ Running (PID: $(cat $SERVER_PID_FILE))" || echo "❌ Stopped")"
    echo "├─ Tunnel: $([ "$tunnel_running" = true ] && echo "✅ Running (PID: $(cat $TUNNEL_PID_FILE))" || echo "❌ Stopped")"
    
    if [[ -f "/tmp/preview-server-url.txt" ]]; then
        local public_url=$(cat /tmp/preview-server-url.txt)
        echo "└─ Public URL: $public_url"
    else
        echo "└─ Public URL: Not available"
    fi
}

# Show public URL
show_url() {
    if [[ -f "/tmp/preview-server-url.txt" ]]; then
        cat /tmp/preview-server-url.txt
    else
        log_error "No active preview server found"
        exit 1
    fi
}

# Main function
main() {
    case "${1:-start}" in
        "start")
            start_server "$2" "$3"
            ;;
        "stop")
            stop_server
            ;;
        "status")
            show_status
            ;;
        "url")
            show_url
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            echo "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Handle script interruption
trap 'log_warning "Interrupted. Use \"$0 stop\" to cleanup if needed."; exit 1' INT TERM

# Run main function
main "$@"