class_name Pomieszczenie
extends Node3D
	
signal entered(name)
	
	# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	await get_tree().create_timer(4).timeout
	entered.emit(self.scene_file_path)

func character_entered() -> void:
	pass
		

	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
