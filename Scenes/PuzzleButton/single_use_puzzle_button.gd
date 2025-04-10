extends Area2D

signal pressed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Pushable") or body is Player:
		pressed.emit()
		$AnimatedSprite2D.play("pressed")
		
