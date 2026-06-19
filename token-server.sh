#!/bin/bash
# token-server.sh — Auto-serves your GitHub Copilot token to storymap.html
# Run once: bash token-server.sh
# Keep it running while using AI Review in the story map

TOKEN=$(gh auth token 2>/dev/null)
if [ -z "$TOKEN" ]; then
  echo "❌ Not logged in. Run: gh auth login"
  exit 1
fi

echo "✅ Token found. Starting local token server on http://localhost:9977"
echo "   Keep this terminal open while using AI Review in storymap.html"
echo "   Press Ctrl+C to stop."

python3 - <<PYEOF
import http.server, json, socketserver

TOKEN = """$TOKEN"""

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()
        self.wfile.write(json.dumps({'token': TOKEN.strip()}).encode())
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()
    def log_message(self, fmt, *args):
        pass  # Silent

with socketserver.TCPServer(('localhost', 9977), Handler) as httpd:
    httpd.serve_forever()
PYEOF
