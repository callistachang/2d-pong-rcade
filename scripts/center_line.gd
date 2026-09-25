extends Node2D

@export var top_point: Vector2 = Vector2(168, 0)
@export var bottom_point: Vector2 = Vector2(168, 262)
@export var line_width: float = 1.5
@export var dash_length: float = 6.0
@export var line_color: Color = Color.WHITE

func _draw() -> void:
	draw_dashed_line(top_point, bottom_point, line_color, line_width, dash_length)
