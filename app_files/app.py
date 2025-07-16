# app.py
from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        message = "Hello from Backend \n   This is a simple HTTP server. \n  You can access it at http://localhost:8080"
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(message.encode())

if __name__ == "__main__":
    server_address = ("", 8080) # Use port 8080
    httpd = HTTPServer(server_address, SimpleHandler)
    print("Server running on port 8080...")
    httpd.serve_forever()
