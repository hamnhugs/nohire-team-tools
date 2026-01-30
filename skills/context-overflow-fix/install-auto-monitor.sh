#!/bin/bash

# AUTO-INSTALL CONTEXT OVERFLOW PREVENTION
# Deploys automated context monitoring on each team bot
# Built by FORGE for NoHire team

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="context-monitor"

echo "🔧 Installing automated context overflow prevention..."

# Install the monitoring script
cp "$SCRIPT_DIR/auto-context-monitor.sh" ~/clawd/
chmod +x ~/clawd/auto-context-monitor.sh

# Create systemd service for continuous monitoring
cat > ~/clawd/context-monitor.service << 'EOF'
[Unit]
Description=Automated Context Overflow Prevention
After=network.target
Wants=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/clawd
ExecStart=/home/ubuntu/clawd/auto-context-monitor.sh
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Install service (if systemd is available)
if command -v systemctl >/dev/null 2>&1; then
    sudo cp ~/clawd/context-monitor.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable context-monitor
    sudo systemctl start context-monitor
    
    echo "✅ Systemd service installed and started"
    echo "📊 Status: sudo systemctl status context-monitor"
    echo "📋 Logs: sudo journalctl -u context-monitor -f"
else
    # Fallback: cron job every 5 minutes
    echo "⚠️ Systemd not available, setting up cron job..."
    
    # Remove existing cron job if present
    (crontab -l 2>/dev/null | grep -v "auto-context-monitor") | crontab -
    
    # Add new cron job
    (crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/clawd/auto-context-monitor.sh >/dev/null 2>&1") | crontab -
    
    echo "✅ Cron job installed (every 5 minutes)"
    echo "📋 View: crontab -l"
fi

# Create manual control commands
cat > ~/clawd/context-control.sh << 'EOF'
#!/bin/bash
# CONTEXT OVERFLOW CONTROL COMMANDS
case "$1" in
    start)
        if command -v systemctl >/dev/null 2>&1; then
            sudo systemctl start context-monitor
            echo "✅ Context monitor started"
        else
            nohup /home/ubuntu/clawd/auto-context-monitor.sh > /home/ubuntu/clawd/context-monitor.log 2>&1 &
            echo "✅ Context monitor started (background)"
        fi
        ;;
    stop)
        if command -v systemctl >/dev/null 2>&1; then
            sudo systemctl stop context-monitor
            echo "⏹️ Context monitor stopped"
        else
            pkill -f auto-context-monitor
            echo "⏹️ Context monitor stopped"
        fi
        ;;
    status)
        if command -v systemctl >/dev/null 2>&1; then
            sudo systemctl status context-monitor
        else
            if pgrep -f auto-context-monitor >/dev/null; then
                echo "✅ Context monitor running"
                tail -10 /home/ubuntu/clawd/context-monitor.log
            else
                echo "⏹️ Context monitor not running"
            fi
        fi
        ;;
    logs)
        if command -v systemctl >/dev/null 2>&1; then
            sudo journalctl -u context-monitor -f
        else
            tail -f /home/ubuntu/clawd/context-monitor.log
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status|logs}"
        echo "  start  - Start context monitoring"
        echo "  stop   - Stop context monitoring"  
        echo "  status - Check monitor status"
        echo "  logs   - View monitor logs"
        ;;
esac
EOF

chmod +x ~/clawd/context-control.sh

echo "🎯 INSTALLATION COMPLETE!"
echo ""
echo "📋 USAGE:"
echo "  ~/clawd/context-control.sh start   # Start monitoring"
echo "  ~/clawd/context-control.sh stop    # Stop monitoring"
echo "  ~/clawd/context-control.sh status  # Check status"
echo "  ~/clawd/context-control.sh logs    # View logs"
echo ""
echo "🤖 AUTOMATION ACTIVE:"
echo "  • Monitors context usage every 5 minutes"
echo "  • Auto-resets bots before overflow (75k token limit)"  
echo "  • Posts Discord alerts on auto-reset"
echo "  • Prevents token waste from context overflow"
echo ""
echo "🚀 Context overflow prevention is now AUTOMATED!"