extends Node2D

@onready var grounded: Node2D = $imported_scenes/enemies/grounded

"""
LEVEL 1
"""

func _ready() -> void:
	Global.coins = 100
	Global.weapon = "Sword"
func _process(delta: float) -> void:
	var objective: int = grounded.get_child_count()
	if objective == 0:
		get_tree().change_scene_to_file("res://Scenes/victory_screen.tscn")
