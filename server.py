
import http.server
import socketserver
import json
import urllib.parse
import jaclang
import main as app

# Initialize graph topology on startup
app.api_init_graph()

class ChamaHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/api/overview":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            data = app.api_get_overview()
            self.wfile.write(json.dumps(data).encode("utf-8"))
        elif parsed.path in ["/", "/index.html"]:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            with open("index.html", "rb") as f:
                self.wfile.write(f.read())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8")
        payload = json.loads(body) if body else {}

        if parsed.path == "/api/deposit":
            raw_sms = payload.get("raw_sms", "")
            result = app.api_process_deposit(raw_sms)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(result).encode("utf-8"))

        elif parsed.path == "/api/loan":
            member_name = payload.get("member_name", "")
            requested_kes = float(payload.get("requested_kes", 0.0))
            purpose = payload.get("purpose", "")
            result = app.api_apply_loan(member_name, requested_kes, purpose)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(result).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    PORT = 8000
    with socketserver.TCPServer(("", PORT), ChamaHandler) as httpd:
        print("\n========================================================")
        print(f"  CHAMAGRAPH AI DASHBOARD RUNNING AT: http://localhost:{PORT}")
        print("========================================================\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down server.")
