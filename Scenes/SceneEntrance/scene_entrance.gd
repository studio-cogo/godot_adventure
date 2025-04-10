extends Area2D

@export var next_scene: String
@export var player_spawn_position: Vector2

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		$AudioStreamPlayer2D.play()
		SceneManager.player_spawn_position = player_spawn_position
		get_tree().change_scene_to_file.call_deferred(next_scene)


func _on_body_exited(body: Node2D) -> void:
	pass
