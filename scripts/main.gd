extends Node2D

@export var win_score: int = 3
@export var win_by: int = 1

var score_p1: int = 0
var score_p2: int = 0
var game_over: bool = false

@onready var score_label_p1: Label = $ScoreP1
@onready var score_label_p2: Label = $ScoreP2
@onready var ball: CharacterBody2D = $Ball
@onready var winner_label: Label = $WinnerLabel

func _ready() -> void:
	RCadeInput.enable_classic_controls()
	ball.scored.connect(_on_ball_scored)
	winner_label.hide()
	_update_labels()

func _on_ball_scored(scoring_player: String) -> void:
	if scoring_player == "p1":
		score_p1 += 1
	else:
		score_p2 += 1
	_update_labels()
	_check_win()

func _check_win() -> void:
	var leader_score: int = max(score_p1, score_p2)
	var diff: int = absi(score_p1 - score_p2)
	if leader_score >= win_score and diff >= win_by:
		game_over = true
		ball.game_over = true
		var winner := "P1" if score_p1 > score_p2 else "P2"
		winner_label.text = "%s wins, press R to restart" % winner
		winner_label.show()

func _update_labels() -> void:
	score_label_p1.text = str(score_p1)
	score_label_p2.text = str(score_p2)

func _unhandled_input(event: InputEvent) -> void:
	if not game_over:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()
