extends StaticBody2D

var can_die = false
var can_open: bool = false
@export var player: Player
@export var stats: Stats
@onready var startup: Timer = $startup

func _ready() -> void:
	stats.initialize()
	startup.start()
func _physics_process(delta: float) -> void:
	if stats.health <= 0 and can_die:
		get_tree().change_scene_to_file("res://Scenes/victory_screen.tscn")



func _on_startup_timeout() -> void:
	can_die = true
