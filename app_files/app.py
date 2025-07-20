# app.py
from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        message = "Hello from Backend Server!\nThis is a simple HTTP server running on port 8080.\nServer is healthy and responding to requests."
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(message.encode())

    def do_HEAD(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()

if __name__ == "__main__":
    server_address = ("0.0.0.0", 8080)  # Listen on all interfaces
    httpd = HTTPServer(server_address, SimpleHandler)
    print("Backend server starting on 0.0.0.0:8080...")
    httpd.serve_forever()
