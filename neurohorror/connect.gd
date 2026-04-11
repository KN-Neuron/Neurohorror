extends Node

var ws := WebSocketPeer.new()

func _ready():
	ws.connect_to_url("ws://127.0.0.1:8765")
	print("Laczenie z EEG middleware...")

func _process(delta):
	ws.poll()

	var state = ws.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		while ws.get_available_packet_count() > 0:
			var packet = ws.get_packet().get_string_from_utf8()
			var data = JSON.parse_string(packet)

			if data.has("eSense"):
				var attention = data["eSense"]["attention"]
				var meditation = data["eSense"]["meditation"]


				print("Attention:", attention)
				print("Meditation:", meditation)

				handle_eeg(attention, meditation)

func handle_eeg(attention, meditation):
	if attention > 60:
		print("Wysokaa koncentracja!")
