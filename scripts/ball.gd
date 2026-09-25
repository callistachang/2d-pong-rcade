extends CharacterBody2D

signal scored(scoring_player: String)

@export var speed: float = 180
@export var speed_increase: float = 25
@export var serve_delay: float = 2

@onready var paddle_hit_sound: AudioStreamPlayer = $PaddleHitSound
@onready var wall_bounce_sound: AudioStreamPlayer = $WallBounceSound
@onready var score_sound: AudioStreamPlayer = $ScoreSound

var base_speed: float
var is_p1_turn: bool = true
var is_waiting_to_serve: bool = false
var game_over: bool = false

func _ready():
	base_speed = speed
	_reset_position()

func _physics_process(delta: float) -> void:
	if is_waiting_to_serve:
		return

	var prev_velocity = velocity

	move_and_slide()

	if get_slide_collision_count() > 0:
		var collision := get_slide_collision(0)
		var collider := collision.get_collider()

		if collider.is_in_group("p1") or collider.is_in_group("p2"):
			speed += speed_increase
			velocity = _bounce_off_paddle(collider)
			paddle_hit_sound.play()
		else:
			velocity = prev_velocity.bounce(collision.get_normal())
			wall_bounce_sound.play()

	var viewport_width := get_viewport_rect().size.x
	if global_position.x < 0:
		_on_goal("p2")
	elif global_position.x > viewport_width:
		_on_goal("p1")

func _on_goal(scoring_player: String) -> void:
	is_waiting_to_serve = true
	velocity = Vector2.ZERO
	hide()
	score_sound.play()
	scored.emit(scoring_player)
	is_p1_turn = not is_p1_turn

	if game_over:
		return

	await get_tree().create_timer(serve_delay).timeout

	_reset_position()
	show()
	is_waiting_to_serve = false

func _reset_position() -> void:
	speed = base_speed

	var viewport_size := get_viewport_rect().size
	global_position = Vector2(
		viewport_size.x / 2,
		randf_range(0, viewport_size.y)
	)

	# Make the ball be +15/-15 degrees off pointing at the player.
	var target_group := "p1" if is_p1_turn else "p2"
	var target_paddle := get_tree().get_first_node_in_group(target_group) as Node2D
	var base_angle := global_position.direction_to(target_paddle.global_position).angle()
	var angle_offset = deg_to_rad(randf_range(-15.0, 15.0))
	var final_angle = base_angle + angle_offset

	velocity = Vector2.from_angle(final_angle) * speed

func _bounce_off_paddle(paddle: Node2D) -> Vector2:
	# Depending on whether it hits the top or bottom of paddle
	# Change the way the paddle bounces off
	# As opposed to just reflecting off the normal.
	var paddle_shape: CollisionShape2D = paddle.get_node("CollisionShape2D")
	var paddle_center: Vector2 = paddle_shape.global_position
	var paddle_height: float = (paddle_shape.shape as RectangleShape2D).size.y

	# -1 (top of paddle) .. 1 (bottom of paddle)
	var relative_y: float = clamp((global_position.y - paddle_center.y) / (paddle_height / 2.0), -1.0, 1.0)

	var max_bounce_angle := deg_to_rad(60.0)
	var bounce_angle := relative_y * max_bounce_angle
	var direction_sign := 1.0 if paddle.is_in_group("p1") else -1.0

	return Vector2(direction_sign * cos(bounce_angle), sin(bounce_angle)) * speed
