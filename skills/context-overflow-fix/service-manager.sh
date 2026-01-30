#!/bin/bash

# CONTEXT OVERFLOW SERVICE MANAGER
# Built by FORGE JR for NoHire team
# Manages background monitoring and prevention services

SKILL_DIR="$(dirname "$0")"
PID_DIR="/tmp/context-overflow"
MONITOR_PID="$PID_DIR/monitor.pid"
PREVENT_PID="$PID_DIR/prevent.pid"

mkdir -p "$PID_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

start_monitor() {
    if [ -f "$MONITOR_PID" ] && kill -0 $(cat "$MONITOR_PID") 2>/dev/null; then
        log "⚠️ Context monitor already running (PID: $(cat $MONITOR_PID))"
        return 1
    fi
    
    log "🚀 Starting context monitor..."
    nohup "$SKILL_DIR/context-monitor.sh" monitor > /tmp/context-monitor.log 2>&1 &
    echo $! > "$MONITOR_PID"
    log "✅ Context monitor started (PID: $!)"
}

start_prevention() {
    if [ -f "$PREVENT_PID" ] && kill -0 $(cat "$PREVENT_PID") 2>/dev/null; then
        log "⚠️ Auto prevention already running (PID: $(cat $PREVENT_PID))"
        return 1
    fi
    
    log "🚀 Starting auto prevention..."
    nohup "$SKILL_DIR/context-prevent.sh" auto > /tmp/context-prevent.log 2>&1 &
    echo $! > "$PREVENT_PID"
    log "✅ Auto prevention started (PID: $!)"
}

stop_monitor() {
    if [ -f "$MONITOR_PID" ] && kill -0 $(cat "$MONITOR_PID") 2>/dev/null; then
        kill $(cat "$MONITOR_PID")
        rm -f "$MONITOR_PID"
        log "✅ Context monitor stopped"
    else
        log "⚠️ Context monitor not running"
    fi
}

stop_prevention() {
    if [ -f "$PREVENT_PID" ] && kill -0 $(cat "$PREVENT_PID") 2>/dev/null; then
        kill $(cat "$PREVENT_PID")
        rm -f "$PREVENT_PID"
        log "✅ Auto prevention stopped"
    else
        log "⚠️ Auto prevention not running"
    fi
}

status() {
    log "🔍 Service Status:"
    
    if [ -f "$MONITOR_PID" ] && kill -0 $(cat "$MONITOR_PID") 2>/dev/null; then
        log "✅ Context Monitor: Running (PID: $(cat $MONITOR_PID))"
    else
        log "❌ Context Monitor: Stopped"
    fi
    
    if [ -f "$PREVENT_PID" ] && kill -0 $(cat "$PREVENT_PID") 2>/dev/null; then
        log "✅ Auto Prevention: Running (PID: $(cat $PREVENT_PID))"
    else
        log "❌ Auto Prevention: Stopped"
    fi
    
    # Show recent activity
    if [ -f "/tmp/context-monitor.log" ]; then
        log "📊 Last Monitor Activity:"
        tail -5 /tmp/context-monitor.log | sed 's/^/    /'
    fi
}

case "${1:-help}" in
    start)
        start_monitor
        start_prevention
        ;;
    start-monitor)
        start_monitor
        ;;
    start-prevent)
        start_prevention
        ;;
    stop)
        stop_monitor
        stop_prevention
        ;;
    stop-monitor)
        stop_monitor
        ;;
    stop-prevent)
        stop_prevention
        ;;
    restart)
        stop_monitor
        stop_prevention
        sleep 2
        start_monitor
        start_prevention
        ;;
    status)
        status
        ;;
    help|*)
        cat << 'EOF'
CONTEXT OVERFLOW SERVICE MANAGER

Usage: ./service-manager.sh <command>

Commands:
  start           - Start both monitor and auto prevention
  start-monitor   - Start context monitor only
  start-prevent   - Start auto prevention only
  stop            - Stop all services
  stop-monitor    - Stop context monitor only
  stop-prevent    - Stop auto prevention only
  restart         - Restart all services
  status          - Show service status

Services:
  📊 CONTEXT MONITOR    - Watches team bot context usage (5min intervals)
                         - Auto-triggers emergency reset at 85% usage
                         - Sends Discord alerts at 75% usage
                         
  🛡️ AUTO PREVENTION   - Scheduled maintenance to prevent overflow
                         - Every 4h: Soft cleanup (aggressive compaction)
                         - Every 8h: Memory flush to MEMORY.md
                         - Every 24h: Session rotation (fresh start)

Logs:
  Monitor:     /tmp/context-monitor.log
  Prevention:  /tmp/context-prevent.log
EOF
        ;;
esac