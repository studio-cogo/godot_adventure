extends StaticBody2D

var can_interact: bool = false
@export var dialog_lines: Array[String] = ["Hello!", "This is a simple world.", "Maybe there is going to be more to see soon!"]
var dialog_index: int = 0

func _process(delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact"):
		if dialog_index < dialog_lines.size():
			$AudioStreamPlayer2D.play()
			$CanvasLayer.visible = true
			get_tree().paused = true
			
			$CanvasLayer/NPCDialog.text = dialog_lines[dialog_index]
			dialog_index += 1
		else:
			$CanvasLayer.visible = false
			get_tree().paused = false
			dialog_index = 0
