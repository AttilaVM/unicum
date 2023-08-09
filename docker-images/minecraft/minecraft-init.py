#!/usr/bin/env python3
import subprocess
import sys
from subprocess import PIPE
from flask import Flask, request, jsonify
import os
import signal
import time

HTTP_PORT=5000

PID = os.getpid()
print("PID:", PID)

app = Flask(__name__)

# Start Minecraft server process
# TODO stop with error without server.jar

minecraft_server_process = subprocess.Popen(['java', '-jar', 'server.jar', 'nogui'], stdin=PIPE)

def signal_handler(signum, frame):
    if signum == signal.SIGINT:
        print("Received SIGINT (Ctrl-C)! Exiting gracefully...")
    elif signum == signal.SIGTERM:
        print("Received SIGTERM! Exiting gracefully...")
    sys.exit(0)

# Register the signal handlers
signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

@app.route('/stop', methods=['POST'])
def stop_server():
    json_data = request.json
    # Assuming you want the JSON to be: { "command": "stop" }
    if json_data and json_data.get('command') == 'stop':
        # Send the "stop" command to the Minecraft server process
        print("Minecraft server will be stopped", file=sys.stderr)
        minecraft_server_process.communicate(input='/stop\n'.encode())
        print("Minecraft server is stopping", file=sys.stderr)
        minecraft_server_process.wait()
        print("Minecraft server stopped successfully!", file=sys.stderr)
        os.kill(PID, signal.SIGTERM)
        
    return jsonify({"error": "Invalid command!"}), 400

if __name__ == "__main__":
   app.run(host='0.0.0.0', port=5000)