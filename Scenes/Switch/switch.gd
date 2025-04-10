extends StaticBody2D

signal switch_activated
signal switch_deactivated

var can_interact: bool = false
var is_activated: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		if is_activated:
			activated_switch()
		else:
			deactivate_switch()
			$AudioStreamPlayer2D.play()

func activated_switch():
	$AnimatedSprite2D.play("deactivated")
	switch_deactivated.emit()
	is_activated = false
	
func deactivate_switch():
	$AnimatedSprite2D.play("activated")
	switch_activated.emit()
	is_activated = true
	
