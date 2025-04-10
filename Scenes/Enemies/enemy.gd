extends CharacterBody2D

var target: Node2D
@export var speed: int = 30
@export var acceleration: float = 8.0
@export var hp: int = 2

func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	
	chase_target()
	
	animated_enemy()
	
	move_and_slide()

func chase_target():
	if target:
		var distance_to_player: Vector2
		distance_to_player = target.global_position - global_position
		
		var direction_normal: Vector2 = distance_to_player.normalized()
		#velocity = direction_normal * speed
		velocity = velocity.move_toward(direction_normal * speed, acceleration)
	
func is_hit():
	$AudioStreamPlayer2D.play()

func _on_player_detection_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func animated_enemy():
	var normal_velocity: Vector2 = velocity.normalized()
	
	if normal_velocity.x > 0.707:
		$AnimatedSprite2D.play("move_right")
	elif normal_velocity.x < -0.707:
		$AnimatedSprite2D.play("move_left")
	elif normal_velocity.y > 0.707:
		$AnimatedSprite2D.play("move_down")
	elif normal_velocity.y < 0.707:
		$AnimatedSprite2D.play("move_up")

func take_damage():
	hp -= 1
	is_hit()
	
	var flash: Color = Color(10.0, 0.0, 0.0)
	modulate = flash
	
	await get_tree().create_timer(0.2).timeout
	
	var original_color: Color = Color(1.0, 1.0, 1.0)
	modulate = original_color
	
	if hp <= 0:
		is_hit()
		die()

func die():
	$GPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(1).timeout
	
	queue_free()
