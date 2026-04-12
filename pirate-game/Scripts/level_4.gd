extends Node2D

"""
LEVEL 4
"""


@export var player: Player
func _ready() -> void:
	player.pop_up.spearPatchRect.visible = false
	player.camera.zoom = Vector2(1, 1)
	Global.weapon = "Sword"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
