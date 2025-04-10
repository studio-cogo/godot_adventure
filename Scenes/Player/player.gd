extends CharacterBody2D
class_name Player

@export var move_speed: float = 100
@export var push_strength: float = 200
@export var acceleration: float = 12.0

var is_attacking: bool = false
var can_interact: bool = false

func _ready() -> void:
	update_treasure_label()
	update_hp_bar()
	
	if SceneManager.player_spawn_position != Vector2(0, 0):
		position = SceneManager.player_spawn_position
	

func _physics_process(delta: float) -> void:
	if SceneManager.player_hp <= 0:
		return
	
	if not is_attacking:
		move_player()
	
	push_blocks()
	
	update_treasure_label()
	
	if Input.is_action_just_pressed("interact") and not can_interact:
		attack()
	
	move_and_slide()

func move_player():
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#velocity = move_vector * move_speed
	velocity = velocity.move_toward(move_vector * move_speed, acceleration)
	
	if velocity.y < 0: # up
		$AnimatedSprite2D.play("move_up")
		$InteractArea2D.position = Vector2(0, -5)
	
	elif velocity.y > 0: # down
		$AnimatedSprite2D.play("move_down")
		$InteractArea2D.position = Vector2(0, 8)
	
	elif velocity.x > 0: # right
		$AnimatedSprite2D.play("move_right")
		$InteractArea2D.position = Vector2(7, 3)
	
	elif velocity.x < 0: # left
		$AnimatedSprite2D.play("move_left")
		$InteractArea2D.position = Vector2(-7, 3)
	
	else: # idle
		$AnimatedSprite2D.stop()

func push_blocks():
	# item collisions
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		var collider_node = collision.get_collider()
		
		if collider_node.is_in_group("Pushable"):
			var collision_normal: Vector2 = collision.get_normal()
			collider_node.apply_central_force(-collision_normal * push_strength)

func update_treasure_label():
	var treasure_amount: int = SceneManager.opened_chests.size()
	%TreasureLabel.text = str(treasure_amount)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Interactible"):
		can_interact = true
		body.can_interact = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Interactible"):
		can_interact = false
		body.can_interact = false


func _on_hitbox_area_2d_body_entered(body: Node2D) -> void:
	SceneManager.player_hp -= 1
	update_hp_bar()
	if SceneManager.player_hp <= 0:
		die()

	var distance_to_player: Vector2 = global_position - body.global_position
	var knockback_direction: Vector2 = distance_to_player.normalized()
	var knockback_strength: int = 200
	
	velocity += knockback_direction * knockback_strength
	
	var flash: Color = Color(4.0, 1.0, 1.0)
	modulate = flash
	$AudioStreamPlayer2D.play()
	
	await get_tree().create_timer(0.2).timeout
	
	var original_color: Color = Color(1.0, 1.0, 1.0)
	modulate = original_color
	

func die():
	$AnimatedSprite2D.play("death")
	$DeathSound.play()
	
	if $DeathTimer.is_stopped():
		$DeathTimer.start()

func _on_death_timer_timeout() -> void:
	SceneManager.player_hp = 3
	get_tree().call_deferred("reload_current_scene")

func update_hp_bar():
	if SceneManager.player_hp >= 3:
		%HPBar.play("3_hp")
	elif SceneManager.player_hp == 2:
		%HPBar.play("2_hp")
	elif SceneManager.player_hp == 1:
		%HPBar.play("1_hp")
	else:
		%HPBar.play("0_hp")

func attack():
	if not $AttackDurationTimer.is_stopped():
		return
	
	is_attacking = true
	velocity = Vector2(0, 0)
	$Sword.visible = true
	%SwordArea2D.monitoring = true
	$AttackDurationTimer.start()
	
	var player_animation: String = $AnimatedSprite2D.animation
	if player_animation == "move_right":
		$AnimatedSprite2D.play("attack_right")
		$AnimationPlayer.play("attack_right")
	elif player_animation == "move_left":
		$AnimatedSprite2D.play("attack_left")
		$AnimationPlayer.play("attack_left")
	elif player_animation == "move_down":
		$AnimatedSprite2D.play("attack_down")
		$AnimationPlayer.play("attack_down")
	elif player_animation == "move_up":
		$AnimatedSprite2D.play("attack_up")
		$AnimationPlayer.play("attack_up")

func _on_sword_area_2d_body_entered(body: Node2D) -> void:
	var distance_to_enemy: Vector2 = body.global_position - global_position
	var knockback_direction: Vector2 = distance_to_enemy.normalized()
	var knockback_strength: float = 150
	
	body.velocity += knockback_direction * knockback_strength

	body.take_damage()

func _on_attack_duration_timer_timeout() -> void:
	is_attacking = false
	$Sword.visible = false
	%SwordArea2D.monitoring = false
	
	var player_animation: String = $AnimatedSprite2D.animation
	if player_animation == "attack_right":
		$AnimatedSprite2D.play("move_right")
	elif player_animation == "attack_left":
		$AnimatedSprite2D.play("move_left")
	elif player_animation == "attack_down":
		$AnimatedSprite2D.play("move_down")
	elif player_animation == "attack_up":
		$AnimatedSprite2D.play("move_up")
