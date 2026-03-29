class_name Generator_Pokoi
extends Node3D

@export var rooms: Array # next room is the one with index + 1
const room_size: float = 10;
var enter_signal 
var name_dictionary: Dictionary = {
	"Przedpokoj" : 0, "Kuchnia" :1, "Salon" : 2, "Jadalnia" : 3
}
var initiated_rooms: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	rooms.resize(4)
	
	rooms[name_dictionary.get("Przedpokoj")] = preload("res://pokoje_dworek/Przedpokoj.tscn")
	rooms[name_dictionary.get("Kuchnia")] = preload("res://pokoje_dworek/Kuchnia.tscn")
	rooms[name_dictionary.get("Salon")] = preload("res://pokoje_dworek/Salon.tscn")
	rooms[name_dictionary.get("Jadalnia")] = preload("res://pokoje_dworek/Jadalnia.tscn")
	
	var current_room = rooms[0].instantiate()
	add_child(current_room)
	initiated_rooms.append([current_room,0])
	generate_rooms(0)

func convert_name_to_number(name) -> void:
	name = name.split("/")
	name = name[name.size()-1].split(".")[0]
	print(name)
	generate_rooms(name_dictionary.get(name))

func generate_rooms(room_number) -> void:
	
	if rooms.is_empty():
		push_error("No rooms to generate!")
		return
	var current_room
	
	for i in range(initiated_rooms.size() - 1, -1, -1):
		if initiated_rooms[i][1] != room_number :
			initiated_rooms[i][0].queue_free()
			initiated_rooms.remove_at(i)
		else :
			current_room = initiated_rooms[i][0]
		
	
	var relative_positions = [
		[
		 	current_room.position + current_room.global_basis * Vector3(0,0,room_size), # shift of the room, for now I assume all rooms are squared, and have doors at the middle of each wall
			0 # angle to rotate the room
		],
		[
			current_room.position + current_room.global_basis  * Vector3(-room_size,0,0),
			PI/2
		],
		[
			current_room.position + current_room.global_basis * Vector3(room_size,0,0),
			-PI/2
		]
	]
	relative_positions.shuffle()
	
	var path_room = rooms[(room_number+1)%rooms.size()].instantiate()
	
	path_room.rotate_y(relative_positions[0][1])
	path_room.position = relative_positions[0][0]

	add_child(path_room)
	
	var index1 = get_random_index(room_number)
	var index2 = get_random_index(room_number)
	while(index2 == index1):
		index2 = get_random_index(room_number)
	
	var room1 = rooms[index1].instantiate()
	var room2 = rooms[index2].instantiate()
	
	room1.rotate_y(relative_positions[1][1])
	room2.rotate_y(relative_positions[2][1])
	
	room1.position = relative_positions[1][0]
	room2.position = relative_positions[2][0]
	
	add_child(room1)
	add_child(room2)
	
	initiated_rooms.append([path_room, (room_number+1)%rooms.size()])
	initiated_rooms.append([room1, index1])
	initiated_rooms.append([room2, index2])
	
	enter_signal = path_room.entered.connect(convert_name_to_number)

func get_random_index(current_index) -> int :
	var index = randi()%rooms.size()
	if index == current_index or index == (current_index+1)%rooms.size():
		return get_random_index(current_index)
	else:
		return index
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
