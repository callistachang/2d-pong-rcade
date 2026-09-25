extends CharacterBody2D

@export var player_id: String = "p1"
@export var speed: float = 300

func _ready() -> void:
	add_to_group(player_id)

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("%s_up" % player_id, "%s_down" % player_id)
	velocity.y = direction * speed
	move_and_slide()
