# Preview Server Tool 🚀

**One-command public web previews for any team bot**

## What It Does

Instantly creates a public URL for local web content using cloudflared tunnels. Perfect for sharing previews, demos, or testing with team members.

## Quick Start

```bash
# Start preview server for current directory
./preview-server.sh start

# Preview specific folder
./preview-server.sh start ./my-website

# Custom port
./preview-server.sh start ./dist 3000

# Stop server
./preview-server.sh stop
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `start [dir] [port]` | Start preview server | `./preview-server.sh start ./public 8080` |
| `stop` | Stop the server | `./preview-server.sh stop` |
| `status` | Check server status | `./preview-server.sh status` |
| `url` | Show public URL | `./preview-server.sh url` |

## Use Cases

### 🎨 Show Landing Pages
```bash
cd my-landing-page/
./preview-server.sh start
# Share the public URL with anyone!
```

### 📱 Demo Applications  
```bash
npm run build
./preview-server.sh start ./build 3000
```

### 🔧 Quick File Sharing
```bash
# Share any folder instantly
./preview-server.sh start ~/Downloads
```

## Features

✅ **One Command**: Just run and get a public URL  
✅ **Auto-Install**: Installs cloudflared if needed  
✅ **Any Directory**: Preview any folder  
✅ **Custom Ports**: Specify port if needed  
✅ **Easy Cleanup**: Simple stop command  
✅ **Status Check**: Monitor running servers  

## Requirements

- Linux (Ubuntu/EC2)
- Python 3 (for HTTP server)
- Internet connection (for tunnel)

## How It Works

1. Starts Python's built-in HTTP server locally
2. Creates cloudflared tunnel for public access
3. Returns shareable public URL
4. Manages both processes automatically

## Team Workflow

**Dan's Use Case**: Share landing pages with Manny
```bash
cd website-project/
./preview-server.sh start
# ✅ Got public URL instantly - no manual setup!
```

**Bot Use Case**: Auto-preview generated content
```bash
# After building something
./preview-server.sh start ./output
curl $(./preview-server.sh url) # Test the preview
```

## Troubleshooting

### Port Already in Use
```bash
./preview-server.sh start . 8081  # Try different port
```

### Tunnel Fails
- Check internet connection
- Try restarting: `./preview-server.sh stop && ./preview-server.sh start`

### Permission Issues
```bash
sudo chmod +x preview-server.sh
```

## Built by Forge 🔧

Replaces manual `http.server + cloudflared` workflow with one simple command.

**Perfect for**: Demos, previews, quick sharing, team collaboration