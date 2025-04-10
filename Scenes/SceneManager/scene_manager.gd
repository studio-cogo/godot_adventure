extends Node2D

var player_spawn_position: Vector2
var player_hp: int = 3
var opened_chests: Array[String] = []

func _ready() -> void:
	# Set the position of Player when game starts
	player_spawn_position = Vector2(0.0, 0.0)
	
	Engine.max_fps = 60
