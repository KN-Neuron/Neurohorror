import asyncio
import websockets
import socket
import json

TG_HOST = "127.0.0.1"
TG_PORT = 13854

WS_PORT = 8765

async def eeg_server():
	tg_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	tg_sock.connect((TG_HOST, TG_PORT ))
	tg_sock.setblocking(False)
	tg_sock.send("{\"enableRawOutput\": false, \"format\": \"Json\"}".encode())

	async def handler(websocket):
		buffer = ""
		print("t")

		while True:
			try:
				data = tg_sock.recv(1024).decode("utf-8")
				buffer += data

				while "\r" in buffer:
					packet, buffer = buffer.split("\r", 1)

					eeg_data = json.loads(packet)

					if "eSense" in eeg_data:
						await websocket.send(json.dumps(eeg_data))

			except BlockingIOError:
				await asyncio.sleep(0.01)

	async with websockets.serve(handler, "localhost", WS_PORT):
		print("WebSocket działa na porcie", WS_PORT)
		await asyncio.Future()

	

asyncio.run(eeg_server())