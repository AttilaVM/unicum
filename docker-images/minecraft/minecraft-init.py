#!/usr/bin/env python3
import subprocess
import sys
from subprocess import PIPE
from flask import Flask, request, jsonify
import os
import signal
from multiprocessing import Process, Pipe

HTTP_PORT=80

PID = os.getpid()
print("PID:", PID)

# create pipe
parent_conn, child_conn = Pipe()

def minecraft_wrapper_process(command_pipe):
    minecraft_server_process = subprocess.Popen(['java', '-jar', '/app/server.jar', 'nogui'], stdin=PIPE)
    while True:
        msg = command_pipe.recv()  # Blocking call, waits for data
        print(f"Child Process Received: {msg}")
        if msg == "stop":
            print("Minecraft server will be stopped", file=sys.stderr)
            minecraft_server_process.communicate(input='/stop\n'.encode())
            print("Minecraft server is stopping", file=sys.stderr)
            minecraft_server_process.wait()
            print("Minecraft server stopped successfully!", file=sys.stderr)
        elif msg == "start":
            print("Minecraft server is starting!", file=sys.stderr)
            minecraft_server_process = subprocess.Popen(['java', '-jar', '/app/server.jar', 'nogui'], stdin=PIPE)

app = Flask(__name__)

# Start Minecraft server process
# TODO stop with error without server.jar


def signal_handler(signum, frame):
    if signum == signal.SIGINT:
        print("Received SIGINT (Ctrl-C)! Exiting gracefully...")
    elif signum == signal.SIGTERM:
        print("Received SIGTERM! Exiting gracefully...")
    sys.exit(0)

# Register the signal handlers
signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

@app.route('/command', methods=['POST'])
def stop_server():
    json_data = request.json
    if json_data and json_data.get('command') == 'stop':
        parent_conn.send("stop")
        return jsonify({"state": "stopping"}), 200
    elif json_data and json_data.get('command') == 'start':
        parent_conn.send("start")
        return jsonify({"state": "starting"}), 200
    else:
        return jsonify({"error": "Invalid command!"}), 400
# TODO /state

if __name__ == "__main__":
   p = Process(target=minecraft_wrapper_process, args=(child_conn,))
   p.start()
   app.run(host='0.0.0.0', port=HTTP_PORT)